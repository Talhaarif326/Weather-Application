import 'package:flutter/material.dart'; // Flutter Material library zaruri hai taake 'Icons' aur 'Colors' recognize ho sakein

// --- HOURLY FORECAST DATA ---
// Ye list 'HoursCardWidget' mein use hoti hai horizontal scrolling ke liye
final List<Map<String, dynamic>> hourlyWeather = [
  // --- NIGHT (Chaand Raat) ---
  {
    "time": "12:00 AM",
    "temp": "15°",
    "icon": Icons.nightlight_round,
    "color": Colors.deepPurpleAccent,
    "bgColor": Colors
        .deepPurple
        .shade50, // Night theme ke liye light purple tint
  },
  {
    "time": "01:00 AM",
    "temp": "14°",
    "icon": Icons.nightlight_round,
    "color": Colors.deepPurpleAccent,
    "bgColor": Colors.deepPurple.shade50,
  },
  {
    "time": "02:00 AM",
    "temp": "14°",
    "icon": Icons.cloud,
    "color": Colors.grey,
    "bgColor":
        Colors.grey.shade100, // Cloudy feel ke liye grey background
  },
  {
    "time": "03:00 AM",
    "temp": "13°",
    "icon": Icons.nightlight_round,
    "color": Colors.deepPurpleAccent,
    "bgColor": Colors.deepPurple.shade50,
  },
  {
    "time": "04:00 AM",
    "temp": "13°",
    "icon": Icons.cloud,
    "color": Colors.grey,
    "bgColor": Colors.grey.shade100,
  },
  {
    "time": "05:00 AM",
    "temp": "13°",
    "icon": Icons.wb_twilight,
    "color": Colors.indigo,
    "bgColor": Colors
        .indigo
        .shade50, // Subah hone se pehle ka thora dark blue tone
  },

  // --- MORNING (Suraj Chachu) ---
  {
    "time": "06:00 AM",
    "temp": "14°",
    "icon": Icons.wb_twilight,
    "color": Colors.indigo,
    "bgColor": Colors.indigo.shade50,
  },
  {
    "time": "07:00 AM",
    "temp": "15°",
    "icon": Icons.wb_sunny,
    "color": Colors.orange,
    "bgColor":
        Colors.orange.shade50, // Taza subah ke liye orange shade
  },
  {
    "time": "08:00 AM",
    "temp": "17°",
    "icon": Icons.wb_sunny,
    "color": Colors.orange,
    "bgColor": Colors.orange.shade50,
  },
  {
    "time": "09:00 AM",
    "temp": "19°",
    "icon": Icons.wb_sunny,
    "color": Colors.orange,
    "bgColor": Colors.orange.shade50,
  },
  {
    "time": "10:00 AM",
    "temp": "21°",
    "icon": Icons.wb_cloudy,
    "color": Colors.amber,
    "bgColor": Colors.amber.shade50,
  },
  {
    "time": "11:00 AM",
    "temp": "23°",
    "icon": Icons.wb_sunny,
    "color": Colors.orange,
    "bgColor": Colors.orange.shade50,
  },

  // --- AFTERNOON (Tez Dhoop aur Mausam ki tabdeeli) ---
  {
    "time": "12:00 PM",
    "temp": "25°",
    "icon": Icons.wb_sunny,
    "color": Colors.orange,
    "bgColor": Colors.orange.shade50,
  },
  {
    "time": "01:00 PM",
    "temp": "26°",
    "icon": Icons.wb_sunny,
    "color": Colors.orange,
    "bgColor": Colors.orange.shade50,
  },
  {
    "time": "02:00 PM",
    "temp": "27°",
    "icon": Icons.thunderstorm,
    "color": Colors.deepPurple,
    "bgColor":
        Colors.deepPurple.shade100, // Toofan ke liye dark background
  },
  {
    "time": "03:00 PM",
    "temp": "26°",
    "icon": Icons.water_drop,
    "color": Colors.blue,
    "bgColor": Colors.blue.shade50, // Barish ke liye blue theme
  },
  {
    "time": "04:00 PM",
    "temp": "25°",
    "icon": Icons.water_drop,
    "color": Colors.blue,
    "bgColor": Colors.blue.shade50,
  },

  // --- EVENING (Sham ka haseen waqt) ---
  {
    "time": "05:00 PM",
    "temp": "24°",
    "icon": Icons.cloud,
    "color": Colors.grey,
    "bgColor": Colors.grey.shade100,
  },
  {
    "time": "06:00 PM",
    "temp": "22°",
    "icon": Icons.cloud,
    "color": Colors.grey,
    "bgColor": Colors.grey.shade100,
  },
  {
    "time": "07:00 PM",
    "temp": "20°",
    "icon": Icons.nightlight_round,
    "color": Colors.deepPurpleAccent,
    "bgColor": Colors.deepPurple.shade50,
  },

  // --- NIGHT AGAIN ---
  {
    "time": "08:00 PM",
    "temp": "19°",
    "icon": Icons.nightlight_round,
    "color": Colors.deepPurpleAccent,
    "bgColor": Colors.deepPurple.shade50,
  },
  {
    "time": "09:00 PM",
    "temp": "18°",
    "icon": Icons.nightlight_round,
    "color": Colors.deepPurpleAccent,
    "bgColor": Colors.deepPurple.shade50,
  },
  {
    "time": "10:00 PM",
    "temp": "17°",
    "icon": Icons.cloud,
    "color": Colors.grey,
    "bgColor": Colors.grey.shade100,
  },
  {
    "time": "11:00 PM",
    "temp": "16°",
    "icon": Icons.nightlight_round,
    "color": Colors.deepPurpleAccent,
    "bgColor": Colors.deepPurple.shade50,
  },
];

// --- GENERAL WEATHER STATS ---
// Ye Map sirf summary ke liye hai
final welcomeData = {
  "humidity": "45%", // <--- Nami ka tanasub
  "windSpeed": "12 km/h", // <--- Hawa ki raftar
  "uvIndex": "4 (Medium)", // <--- Suraj ki shuaon ki shiddat
  "aqi": "52 (Fair)", // <--- Hawa ki safai (Air Quality)
  "pressure": "1012 hPa", // <--- Fizayi dabao
  "visibility": "10 km", // <--- Kitni door tak nazar aata hai
  "sunrise": "05:24 AM",
  "sunset": "07:12 PM",
};

// --- DETAILED WEATHER SECTION DATA ---
// Ye list 'WeatherDetail' aur 'TenDaysWeatherDetailWidget' mein loops ke liye use hoti hai
final List<Map<String, dynamic>> weatherDetails = [
  {
    "title": "Humidity",
    "value": "45%",
    "icon": Icons.water_drop,
    "color": Colors.blueAccent, // Icon ka color dark hai
    "bgColor": Colors
        .blue
        .shade50, // Card ka background light hai (Modern UI)
  },
  {
    "title": "Wind",
    "value": "12 km/h",
    "icon": Icons.air,
    "color": Colors.teal,
    "bgColor": Colors.teal.shade50,
  },
  {
    "title": "UV Index",
    "value": "4",
    "icon": Icons.wb_sunny,
    "color": Colors.orangeAccent,
    "bgColor": Colors.orange.shade50,
  },
  {
    "title": "AQI",
    "value": "52",
    "icon":
        Icons.local_florist, // Hawa ki safai ke liye leaf/flower icon
    "color": Colors.green,
    "bgColor": Colors.green.shade50,
  },
  {
    "title": "Pressure",
    "value": "1012 hPa",
    "icon": Icons.speed,
    "color": Colors.deepPurple,
    "bgColor": Colors.deepPurple.shade50,
  },
  {
    "title": "Visibility",
    "value": "10 km",
    "icon": Icons.visibility,
    "color": Colors.blueGrey,
    "bgColor": Colors.blueGrey.shade50,
  },
  {
    "title": "Sunrise",
    "value": "05:24 AM",
    "icon": Icons.wb_twilight,
    "color": Colors.amber,
    "bgColor": Colors.amber.shade50,
  },
  {
    "title": "Sunset",
    "value": "07:12 PM",
    "icon": Icons.nightlight_round,
    "color": Colors.indigo,
    "bgColor": Colors.indigo.shade50,
  },
];
