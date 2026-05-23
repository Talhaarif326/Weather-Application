import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import 'package:http/http.dart' as http;
import 'package:weather/database/db_helper.dart';
import 'package:weather/models/weather_model.dart';

/// The main state notifier for all weather data in the app.
/// Extends [StateNotifier] with [WeatherModel] as its state.
/// Automatically calls [fetchWeather] on creation to load data on app launch.
class Weather extends StateNotifier<WeatherModel> {
  Weather() : super(WeatherModel(isLoading: false)) {
    fetchWeather();
  }

  /// API key loaded from the .env file.
  /// Falls back to 'key Not found' if the key is missing.
  final String apiKey =
      dotenv.env['openWeathreApiKey'] ?? 'key Not found';

  /// Maximum number of times we retry requesting location permission
  /// before giving up and throwing an exception.
  static const int _maxRetries = 3;

  /// Singleton instance of the local SQLite database helper.
  final DbHelper _db = DbHelper.instance;

  /// Checks for a real internet connection by attempting to resolve
  /// google.com — more reliable than connectivity_plus which only
  /// checks network state, not actual reachability.
  /// Returns true if online, false if offline or timeout after 5 seconds.
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

  /// Primary entry point — fetches weather for the current GPS location.
  /// Called automatically on app launch from the constructor.
  ///
  /// Flow:
  /// 1. Sets loading state
  /// 2. Checks internet
  /// 3. If offline → loads from SQLite cache
  /// 4. If online → gets GPS position → fetches from OWM API → caches result
  /// 5. On any error → tries cache before showing an error message
  Future<void> fetchWeather() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final locationId = await _db.getCurrentLocationId();
      final online = await _hasInternet();

      if (!online) {
        // No internet — try loading last saved data from SQLite
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

      // Online — get fresh GPS coordinates
      final position = await _getLiveLocation();

      // Update the current location row in DB with latest coordinates
      await _db.updateCurrentLocation(
        cityName: 'Current Location',
        lat: position.latitude,
        lon: position.longitude,
      );

      // Fetch weather from OWM API using the live coordinates
      await _fetchByCoordinates(
        position.latitude,
        position.longitude,
        locationId: locationId,
      );
    } catch (e) {
      // Something went wrong (GPS, network, etc.) — fall back to cache
      final locationId = await _db.getCurrentLocationId();
      final loaded = await _loadFromCache(
        locationId,
        error: e.toString(),
      );
      if (!loaded) {
        // Cache also empty — show the actual error to the user
        state = state.copyWith(
          errorMessage: e.toString(),
          isLoading: false,
        );
      }
    }
  }

  /// Fetches weather for a city the user searched by name.
  /// Called from the search bar on the Home screen.
  ///
  /// Flow:
  /// 1. Converts city name → coordinates using [locationFromAddress]
  /// 2. Saves city to the locations table in SQLite
  /// 3. Checks internet → fetches from API or loads from cache
  Future<void> fetchWeatherByCity(String cityName) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      // Convert city name string to lat/lon coordinates
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

      // Persist this city to the SQLite locations table so it appears
      // in Manage Locations on the Settings screen
      final locationId = await _db.saveLocation(
        cityName: cityName,
        lat: lat,
        lon: lon,
      );

      final online = await _hasInternet();
      if (!online) {
        // Offline — try to serve cached data for this city
        await _loadFromCache(locationId);
        return;
      }

      // Online — fetch fresh data for these coordinates
      await _fetchByCoordinates(
        lat,
        lon,
        locationId: locationId,
        overrideCityName: cityName, // skip reverse geocoding, we already have the name
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString(),
        isLoading: false,
      );
    }
  }

  /// Fetches weather for a previously saved city tapped from the
  /// Manage Locations list in Settings.
  ///
  /// We already have the coordinates from SQLite so we skip geocoding
  /// and go straight to the API call (or cache if offline).
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
      // On error, fall back to cache silently
      await _loadFromCache(locationId, error: e.toString());
    }
  }

  /// Core API call — hits the OpenWeatherMap OneCall 3.0 endpoint
  /// with the given coordinates and processes the response.
  ///
  /// [overrideCityName] skips reverse geocoding when we already know
  /// the city name (e.g. from search or saved locations).
  ///
  /// On success → caches the full JSON response in SQLite, then calls
  /// [_applyWeatherData] to push data into Riverpod state.
  /// On failure → tries cache before showing an error.
  Future<void> _fetchByCoordinates(
    double lat,
    double lon, {
    required int locationId,
    String? overrideCityName,
  }) async {
    try {
      String cityName = overrideCityName ?? 'Unknown City';

      if (overrideCityName == null) {
        // No city name provided — reverse geocode the coordinates to get one
        final List<Placemark> places = await placemarkFromCoordinates(
          lat,
          lon,
        ).timeout(const Duration(seconds: 30));
        cityName = places[0].locality ?? 'Unknown City';

        // Update the current location row with the resolved city name
        await _db.updateCurrentLocation(
          cityName: cityName,
          lat: lat,
          lon: lon,
        );
      }

      // Build the OWM OneCall 3.0 request URL
      final Uri url = Uri.parse(
        'https://api.openweathermap.org/data/3.0/onecall?lat=$lat&lon=$lon&appid=$apiKey',
      );

      final response = await http
          .get(url)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Immediately cache the raw API response + city name in SQLite
        // so it's available next time the user is offline
        await _db.cacheWeather(
          locationId: locationId,
          data: {'cityName': cityName, 'apiResponse': data},
        );

        // Parse and push data into Riverpod state
        _applyWeatherData(cityName, data, isOffline: false);
      } else {
        // Non-200 response (e.g. 401 bad key, 429 rate limit) — try cache
        final loaded = await _loadFromCache(locationId);
        if (!loaded) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: 'Server error: ${response.statusCode}',
          );
        }
      }
    } catch (e) {
      // Network exception (timeout, no route, etc.) — try cache
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

  /// Loads the last cached weather response from SQLite for a given location.
  ///
  /// Returns true if cache was found and state was updated successfully.
  /// Returns false if no cache exists for this location.
  ///
  /// Sets [isOffline: true] and [lastUpdated] so the Home screen can
  /// show the orange "Offline — Last updated: X min ago" banner.
  Future<bool> _loadFromCache(int locationId, {String? error}) async {
    try {
      final cached = await _db.getCachedWeather(locationId);
      if (cached == null) {
        // Nothing in cache — propagate the error if one was passed
        if (error != null) {
          state = state.copyWith(
            errorMessage: error,
            isLoading: false,
          );
        }
        return false;
      }

      // Extract the raw API response and metadata from the cache row
      final data =
          cached['data']['apiResponse'] as Map<String, dynamic>;
      final cityName = cached['data']['cityName'] as String;

      // Convert the stored timestamp to a DateTime for the offline banner
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

  /// Parses the raw OWM API response and maps it into [WeatherModel].
  /// Called after both a successful API fetch and a successful cache load.
  ///
  /// [isOffline] controls whether the orange offline banner shows.
  /// [lastUpdated] is only passed when loading from cache — it stores
  /// the original fetch time so the banner shows accurate elapsed time.
  void _applyWeatherData(
    String cityName,
    Map<String, dynamic> data, {
    required bool isOffline,
    DateTime? lastUpdated,
  }) {
    state = state.copyWith(
      isLoading: false,
      isOffline: isOffline,

      // Use the cache timestamp if offline, otherwise use now
      lastUpdated: lastUpdated ?? DateTime.now(),

      // Flat map of current conditions used by HomeScreen and GeminiScreen
      currentWeather: {
        'Name': cityName,
        'Temp': (data['current']['temp'] as num).toDouble(),
        'FeelsLike': (data['current']['feels_like'] as num).toDouble(),
        'Condition': data['current']['weather'][0]['main'] as String,
        'WeatherId': data['current']['weather'][0]['id'] as int,
        'Icon': data['current']['weather'][0]['icon'] as String,
      },

      // Full 48-hour list — used by the hourly scroll strip on HomeScreen
      hourlyWeather: data['hourly'] as List<dynamic>,

      // Flat map of specific current conditions for the detail grid
      // (Sunrise, Sunset, Humidity, UV Index, Visibility, Pressure)
      weatherConditions: {
        'Sunrise': data['current']['sunrise'],
        'Sunset': data['current']['sunset'],
        'Humidity': data['current']['humidity'],
        'ultraviolet': data['current']['uvi'],
        'Visibility': data['current']['visibility'],
        'Pressure': data['current']['pressure'],
      },

      // Full 7-day list — used by WeatherScreen forecast cards
      weeklyWeather: data['daily'] as List<dynamic>,

      // Active weather alerts — shown in Settings and can trigger notifications
      alerts: data['alerts'] ?? [],
    );
  }

  /// Returns a list of up to 5 city name suggestions for the search dropdown.
  /// Triggered after the user types 2+ characters in the search bar.
  ///
  /// Converts the query string → coordinates → readable place name
  /// in the format "City, State, Country" (e.g. "Karachi, Sindh, Pakistan").
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

          // Build a readable label from available placemark fields,
          // skipping any that are null or empty
          final name = [
            place.locality,
            place.administrativeArea,
            place.country,
          ].where((e) => e != null && e.isNotEmpty).join(', ');

          // Avoid duplicates in the suggestion list
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

  /// Requests location permission and returns the device's current GPS position.
  /// Retries up to [_maxRetries] times if permission is denied (but not permanently).
  ///
  /// Throws an exception if:
  /// - Location services are disabled on the device
  /// - Permission is permanently denied (user selected "Never")
  /// - All retry attempts are exhausted without getting permission
  Future<Position> _getLiveLocation() async {
    final bool serviceEnabled =
        await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      LocationPermission permission =
          await Geolocator.checkPermission();

      // Permanently denied — no point retrying, throw immediately
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permission permanently denied.');
      }

      // Denied but not permanently — ask the user again
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      // Permission granted — return the current position
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        return await Geolocator.getCurrentPosition(
          locationSettings: AndroidSettings(
            accuracy: LocationAccuracy.high,
          ),
        );
      }

      // Wait 1 second between retries (except after the last attempt)
      if (attempt < _maxRetries) {
        await Future.delayed(const Duration(seconds: 1));
      }
    }

    throw Exception(
      'Location permission denied after $_maxRetries attempts.',
    );
  }

  /// Toggles the temperature unit between Celsius and Fahrenheit.
  /// Does NOT re-fetch from API — all screens convert on the fly
  /// using TempConverter so a simple state update is enough.
  void toggleUnit() {
    state = state.copyWith(
      tempUnit: state.tempUnit == 'C' ? 'F' : 'C',
    );
  }

  /// Clears all SQLite data (users, locations, weather cache) and
  /// resets Riverpod state to the initial empty model.
  /// Called from the Log Out button in Settings.
  Future<void> clearData() async {
    await _db.clearAll();
    state = WeatherModel(isLoading: false);
  }
}

/// The global Riverpod provider for weather state.
/// Any widget that calls ref.watch(weatherProvider) will rebuild
/// automatically whenever the WeatherModel state changes.
final weatherProvider = StateNotifierProvider<Weather, WeatherModel>(
  (ref) => Weather(),
);