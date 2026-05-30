class WeatherModel {
  WeatherModel({
    this.currentWeather = const {},
    this.hourlyWeather = const [],
    this.isLoading = false,
    this.errorMessage,
    this.weatherConditions = const {},
    this.weeklyWeather = const [],
    this.tempUnit = 'C',
    this.alerts = const [],
    this.isOffline = false,
    this.lastUpdated,
  });

  final Map<String, dynamic> currentWeather;
  final List<dynamic> hourlyWeather;
  final List<dynamic> weeklyWeather;
  final bool isLoading;
  final String? errorMessage;
  final Map<String, dynamic> weatherConditions;
  final String tempUnit;
  final List<dynamic> alerts;
  final bool isOffline;
  final DateTime? lastUpdated;

  WeatherModel copyWith({
    Map<String, dynamic>? currentWeather,
    List<dynamic>? hourlyWeather,
    List<dynamic>? weeklyWeather,
    bool? isLoading,
    Object? errorMessage = _sentinel,
    Map<String, dynamic>? weatherConditions,
    String? tempUnit,
    List<dynamic>? alerts,
    bool? isOffline,
    Object? lastUpdated = _sentinel,
  }) {
    return WeatherModel(
      currentWeather: currentWeather ?? this.currentWeather,
      hourlyWeather: hourlyWeather ?? this.hourlyWeather,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage == _sentinel
          ? this.errorMessage
          : errorMessage as String?,
      weatherConditions: weatherConditions ?? this.weatherConditions,
      weeklyWeather: weeklyWeather ?? this.weeklyWeather,
      tempUnit: tempUnit ?? this.tempUnit,
      alerts: alerts ?? this.alerts,
      isOffline: isOffline ?? this.isOffline,
      lastUpdated: lastUpdated == _sentinel
          ? this.lastUpdated
          : lastUpdated as DateTime?,
    );
  }
}

const Object _sentinel = Object();
