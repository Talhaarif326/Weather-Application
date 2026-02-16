class WeatherModel {
  WeatherModel({
    this.weatherData = const {},
    this.isLoading = false,
    this.errorMessage,
  });

  final Map<String, dynamic> weatherData;
  final bool isLoading;
  final String? errorMessage;

  WeatherModel copyWith({
    Map<String, dynamic>? weatherData,
    bool? isLoading,
    String? errorMessage,
  }) {
    return WeatherModel(
      weatherData: weatherData ?? this.weatherData,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
