// WeatherModel class jo app ki weather state ko hold karti hai
class WeatherModel {
  WeatherModel({
    this.weatherData =
        const {}, // Current weather details (e.g. Temp, City Name)
    this.hourlyWeather =
        const [], // Agle 48 ghanton ka raw data list format mein
    this.isLoading =
        false, // UI mein spinner dikhane ya chupane ke liye flag
    this.errorMessage, // Agar API fail ho jaye to error message store karne ke liye
  });

  // Final variables jo state change hone par naye object mein copy hotay hain
  final Map<String, dynamic> weatherData;
  final List<dynamic>
  hourlyWeather; // Dynamic type list parsing crashes se bachati hai
  final bool isLoading;
  final String? errorMessage;

  // copyWith method jo Riverpod state ko immutably update karne mein madad deta hai
  WeatherModel copyWith({
    Map<String, dynamic>? weatherData,
    List<dynamic>? hourlyWeather,
    bool? isLoading,
    String? errorMessage,
  }) {
    return WeatherModel(
      // Agar nayi value provide ki gayi hai to wo use karein, warna purani hi rehne dein
      weatherData: weatherData ?? this.weatherData,
      hourlyWeather: hourlyWeather ?? this.hourlyWeather,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
