import 'package:flutter/material.dart'; // Icons aur Colors ke liye essential library

// Hafte ke dino ki list
List<String> weekDays = [
  'Monday',
  'Tuseday', // Note: Examiner ke samne 'Tuesday' ki spelling sahi kar lena
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

// Mausam ki mukhtalif soort-e-haal (Conditions)
List<String> weatherConditions = [
  'Sunny',
  'Cloudy',
  'Rainy',
  'Thunderstorm',
  'Partly Cloudy',
  'Clear',
  'Windy',
];

// Har condition ke mutabiq icon map kiya gaya hai
Map<String, IconData> weatherIcons = {
  'Sunny': Icons.wb_sunny_rounded,
  'Cloudy': Icons.cloud_rounded,
  'Rainy': Icons.umbrella_rounded,
  'Thunderstorm': Icons.thunderstorm_rounded,
  'Partly Cloudy': Icons.cloud_queue_rounded,
  'Clear': Icons.wb_sunny_outlined,
  'Windy': Icons.air_rounded,
};

// Har mausam ke liye ek makhsoos rang (Color) taake UI attractive lage
Map<String, Color> weatherColors = {
  'Sunny': Colors.orangeAccent,
  'Cloudy': Colors.blueGrey,
  'Rainy': Colors.blue,
  'Thunderstorm': Colors.deepPurpleAccent,
  'Partly Cloudy': Colors.lightBlueAccent,
  'Clear': Colors.yellow,
  'Windy': Colors.teal,
};

// List.generate ka istemal kar ke 7 dino ka data automate kiya gaya hai
List<Map<String, dynamic>> weekWeatherDate = List.generate(7, (
  index,
) {
  // Aaj ki date mein index (0 se 6) add kar ke agle 7 din nikalna
  DateTime date = DateTime.now().add(Duration(days: index));

  // Modulo (%) operator use kiya taake agar list khatam ho to dubara start se condition uthaye
  final weatherCondition =
      weatherConditions[index % weatherConditions.length];

  // Fake temperature logic: 18 base hai aur index ke hisab se thora upar niche
  final temp = 18 + (index % 3);
  final feelsLike =
      temp -
      3; // FeelLike hamesha real temp se 3 degree kam rakha hai

  // Final map jo 'WeatherScreen' ki list mein display hoga
  return {
    "Weather": weatherCondition, // Mausam ka haal
    "Name": weekDays[index], // Din ka naam
    "Time": date, // Mukammal date aur time object
    "Temp": temp, // Temperature
    "FeelLike": feelsLike, // Ehsas-e-hararat
    'Icon':
        weatherIcons[weatherCondition], // Icon dynamically uthaya gaya hai
    'Icon Color':
        weatherColors[weatherCondition], // Color bhi condition ke mutabiq
  };
});
