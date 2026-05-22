import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import 'package:http/http.dart' as http;
import 'package:weather/database/db_helper.dart';
import 'package:weather/models/weather_model.dart';

class Weather extends StateNotifier<WeatherModel> {
  Weather() : super(WeatherModel(isLoading: false)) {
    fetchWeather();
  }

  final String apiKey =
      dotenv.env['openWeathreApiKey'] ?? 'key Not found';
  static const int _maxRetries = 3;
  final DbHelper _db = DbHelper.instance;

  // Reliable internet check — actually tries to reach a server
  Future<bool> _hasInternet() async {
    try {
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> fetchWeather() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final locationId = await _db.getCurrentLocationId();
      final online = await _hasInternet();

      if (!online) {
        final loaded = await _loadFromCache(locationId);
        if (!loaded) {
          state = state.copyWith(
            isLoading: false,
            errorMessage:
                'No internet connection and no cached data available.',
          );
        }
        return;
      }

      final position = await _getLiveLocation();
      await _db.updateCurrentLocation(
        cityName: 'Current Location',
        lat: position.latitude,
        lon: position.longitude,
      );
      await _fetchByCoordinates(
        position.latitude,
        position.longitude,
        locationId: locationId,
      );
    } catch (e) {
      final locationId = await _db.getCurrentLocationId();
      final loaded = await _loadFromCache(
        locationId,
        error: e.toString(),
      );
      if (!loaded) {
        state = state.copyWith(
          errorMessage: e.toString(),
          isLoading: false,
        );
      }
    }
  }

  Future<void> fetchWeatherByCity(String cityName) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final List<Location> locations = await locationFromAddress(
        cityName,
      ).timeout(const Duration(seconds: 15));
      if (locations.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'City not found.',
        );
        return;
      }
      final lat = locations.first.latitude;
      final lon = locations.first.longitude;
      final locationId = await _db.saveLocation(
        cityName: cityName,
        lat: lat,
        lon: lon,
      );
      final online = await _hasInternet();
      if (!online) {
        await _loadFromCache(locationId);
        return;
      }
      await _fetchByCoordinates(
        lat,
        lon,
        locationId: locationId,
        overrideCityName: cityName,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> fetchWeatherByLocationId(
    int locationId,
    String cityName,
    double lat,
    double lon,
  ) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final online = await _hasInternet();
      if (!online) {
        await _loadFromCache(locationId);
        return;
      }
      await _fetchByCoordinates(
        lat,
        lon,
        locationId: locationId,
        overrideCityName: cityName,
      );
    } catch (e) {
      await _loadFromCache(locationId, error: e.toString());
    }
  }

  Future<void> _fetchByCoordinates(
    double lat,
    double lon, {
    required int locationId,
    String? overrideCityName,
  }) async {
    try {
      String cityName = overrideCityName ?? 'Unknown City';
      if (overrideCityName == null) {
        final List<Placemark> places = await placemarkFromCoordinates(
          lat,
          lon,
        ).timeout(const Duration(seconds: 30));
        cityName = places[0].locality ?? 'Unknown City';
        await _db.updateCurrentLocation(
          cityName: cityName,
          lat: lat,
          lon: lon,
        );
      }

      final Uri url = Uri.parse(
        'https://api.openweathermap.org/data/3.0/onecall?lat=$lat&lon=$lon&appid=$apiKey',
      );
      final response = await http
          .get(url)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Save to cache immediately after successful fetch
        await _db.cacheWeather(
          locationId: locationId,
          data: {'cityName': cityName, 'apiResponse': data},
        );
        _applyWeatherData(cityName, data, isOffline: false);
      } else {
        // API failed — try cache before showing error
        final loaded = await _loadFromCache(locationId);
        if (!loaded) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: 'Server error: ${response.statusCode}',
          );
        }
      }
    } catch (e) {
      // Network error — try cache
      final loaded = await _loadFromCache(
        locationId,
        error: e.toString(),
      );
      if (!loaded) {
        state = state.copyWith(
          errorMessage: e.toString(),
          isLoading: false,
        );
      }
    }
  }

  Future<bool> _loadFromCache(int locationId, {String? error}) async {
    try {
      final cached = await _db.getCachedWeather(locationId);
      if (cached == null) {
        if (error != null) {
          state = state.copyWith(
            errorMessage: error,
            isLoading: false,
          );
        }
        return false;
      }
      final data =
          cached['data']['apiResponse'] as Map<String, dynamic>;
      final cityName = cached['data']['cityName'] as String;
      final lastUpdated = DateTime.fromMillisecondsSinceEpoch(
        cached['last_updated'] as int,
      );
      _applyWeatherData(
        cityName,
        data,
        isOffline: true,
        lastUpdated: lastUpdated,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
        isLoading: false,
      );
      return false;
    }
  }

  void _applyWeatherData(
    String cityName,
    Map<String, dynamic> data, {
    required bool isOffline,
    DateTime? lastUpdated,
  }) {
    state = state.copyWith(
      isLoading: false,
      isOffline: isOffline,
      lastUpdated: lastUpdated ?? DateTime.now(),
      currentWeather: {
        'Name': cityName,
        'Temp': (data['current']['temp'] as num).toDouble(),
        'FeelsLike': (data['current']['feels_like'] as num)
            .toDouble(),
        'Condition': data['current']['weather'][0]['main'] as String,
        'WeatherId': data['current']['weather'][0]['id'] as int,
        'Icon': data['current']['weather'][0]['icon'] as String,
      },
      hourlyWeather: data['hourly'] as List<dynamic>,
      weatherConditions: {
        'Sunrise': data['current']['sunrise'],
        'Sunset': data['current']['sunset'],
        'Humidity': data['current']['humidity'],
        'ultraviolet': data['current']['uvi'],
        'Visibility': data['current']['visibility'],
        'Pressure': data['current']['pressure'],
      },
      weeklyWeather: data['daily'] as List<dynamic>,
      alerts: data['alerts'] ?? [],
    );
  }

  Future<List<String>> getCitySuggestions(String query) async {
    if (query.length < 2) return [];
    try {
      final List<Location> locations = await locationFromAddress(
        query,
      ).timeout(const Duration(seconds: 10));
      final List<String> suggestions = [];
      for (var loc in locations.take(5)) {
        final List<Placemark> places = await placemarkFromCoordinates(
          loc.latitude,
          loc.longitude,
        );
        if (places.isNotEmpty) {
          final place = places.first;
          final name = [
            place.locality,
            place.administrativeArea,
            place.country,
          ].where((e) => e != null && e.isNotEmpty).join(', ');
          if (name.isNotEmpty && !suggestions.contains(name)) {
            suggestions.add(name);
          }
        }
      }
      return suggestions;
    } catch (_) {
      return [];
    }
  }

  Future<Position> _getLiveLocation() async {
    final bool serviceEnabled =
        await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled)
      throw Exception('Location services are disabled.');

    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      LocationPermission permission =
          await Geolocator.checkPermission();
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permission permanently denied.');
      }
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        return await Geolocator.getCurrentPosition(
          locationSettings: AndroidSettings(
            accuracy: LocationAccuracy.high,
          ),
        );
      }
      if (attempt < _maxRetries) {
        await Future.delayed(const Duration(seconds: 1));
      }
    }
    throw Exception(
      'Location permission denied after $_maxRetries attempts.',
    );
  }

  void toggleUnit() {
    state = state.copyWith(
      tempUnit: state.tempUnit == 'C' ? 'F' : 'C',
    );
  }

  Future<void> clearData() async {
    await _db.clearAll();
    state = WeatherModel(isLoading: false);
  }
}

final weatherProvider = StateNotifierProvider<Weather, WeatherModel>(
  (ref) => Weather(),
);
