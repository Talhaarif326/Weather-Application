import 'dart:convert'; // JSON data ko Map mein badalne ke liye library

import 'package:flutter_dotenv/flutter_dotenv.dart'; // Environment variables (.env) use karne ke liye
import 'package:flutter_riverpod/legacy.dart'; // Riverpod state management ke liye
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart'
    as http; // Network calls (API request) karne ke liye
import 'package:weather/models/weather_model.dart'; // Aapka banaya hua data model

// Weather class jo StateNotifier ko extend karti hai taake WeatherModel ki state handle kar sake
class Weather extends StateNotifier<WeatherModel> {
  // Constructor: Shuru mein loading false rakhta hai aur foran fetchWeather() call karta hai
  Weather() : super(WeatherModel(isLoading: false)) {
    fetchWeather();
  }

  // .env file se API Key nikal raha hai, agar nahi mili to "key Not found" save hoga
  final String apiKey = dotenv.env['apiKey'] ?? "key Not found";

  // Static location coordinates (Dargai/Malakand area ke lag bhag)
  final double lat = 34.5075;

  final double lon = 71.8986;

  // API se data mangwane ka asynchronous function
  Future<void> fetchWeather() async {
    // UI ko batane ke liye ke loading shuru ho gayi hai aur purana error khatam kar do
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Reverse Geocoding: Coordinates (lat/lon) ko insani samajh mein aane wale address mein badalna

      List<Placemark> places = await placemarkFromCoordinates(
        lat, // Latitude: 34.5075
        lon, // Longitude: 71.8986
      ).timeout(Duration(seconds: 5));

      // Method aik 'List' return karta hai kyunke aik point ke multiple address formats ho sakte hain.
      // Hum hamesha 'index 0' uthate hain kyunke wo sabse specific aur nazdiki address hota hai.
      Placemark place = places[0];

      // 'locality' ka matlab hai shehar ka naam (e.g. Dargai ya Malakand).
      // '??' (Null Safety) use kiya hai taake agar kisi registan ya samundar ke coordinates hon
      // jahan shehar ka naam na mile, toh app crash hone ki bajaye "unknown city" dikhaye.
      String cityName = place.locality ?? "unknown city";

      // API ka endpoint URL taiyar ho raha hai coordinates aur key ke saath
      final Uri url = Uri.parse(
        'https://api.openweathermap.org/data/3.0/onecall?lat=$lat&lon=$lon&exclude={part}&appid=$apiKey',
      );

      // Internet ke zariye request bhej raha hai aur response ka intezar kar raha hai
      final response = await http.get(url);

      // String response ko Dart Map (JSON) mein convert kar raha hai
      final data = jsonDecode(response.body);

      // Agar server ne 200 (Success) bheja hai
      if (response.statusCode == 200) {
        // Nayi state assign ho rahi hai: loading band aur weatherData mein values save
        state = state.copyWith(
          isLoading: false, // Spinner rokne ke liye
          weatherData: {
            'Name': cityName, // Shehar ka naam
            "Temp":
                data['current']['temp'], // Temperature (Kelvin mein)
            "FeelsLike":
                data['current']['feels_like'], // Mehsus hone wala temp
          },
          hourlyWeather: data['hourly'],
          weatherConditions: {
            "Sunrise": data['current']['sunrise'],
            "Sunset": data['current']['sunset'],
            "Humidity": data['current']["humidity"],
            "ultraviolet": data['current']['uvi'],
            "Visibility": data['current']['visibility'],
            "Pressure": data['current']['pressure'],
          },
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      // Agar internet nahi hai ya koi aur masla hua to error message save hoga

      state = state.copyWith(
        errorMessage: e.toString(),
        isLoading: false,
      );
    }
  }
}

// Global provider jo puri app mein is Weather class ko access karne ki ijazat deta hai
final weatherProvider = StateNotifierProvider<Weather, WeatherModel>((
  ref,
) {
  return Weather(); // Weather class ka naya instance return karta hai
});
