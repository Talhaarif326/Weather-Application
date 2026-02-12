import 'package:flutter/material.dart';
import 'package:weather/screens/home_screen.dart';
import 'package:weather/screens/setting_screen.dart';
import 'package:weather/screens/weather_screen.dart';

// MainScreen: Ye class Bottom Navigation ke zariye screens ko switch karne ka kaam karti hai
class MainScreen extends StatefulWidget {
  const MainScreen({super.key, required this.name});

  final String name; // Welcome screen se aaya hua user ka naam

  @override
  State<MainScreen> createState() {
    return _MainScreenState();
  }
}

class _MainScreenState extends State<MainScreen> {
  late String myName;

  // currentIndex: Ye track karta hai ke user ne navigation bar par kaunse icon ko click kiya hai
  int currentIndex = 0;

  @override
  void initState() {
    myName = widget.name; // Initial state mein user ka naam set karna
    super.initState();
  }

  // screensList: Un screens ki list jo navigation bar ke zariye display hongi
  late List<Widget> screensList = [
    HomeScreen(name: myName), // Index 0
    WeatherScreen(name: myName), // Index 1
    SettingScreen(), // Index 2
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Bottom Navigation Bar setup
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          // Jab icon click ho, to currentIndex update karke screen change karna
          setState(() {
            currentIndex = index;
          });
        },
        enableFeedback:
            true, // Click karne par haptic feedback (vibration/sound)
        currentIndex: currentIndex,
        selectedItemColor: const Color.fromARGB(
          255,
          163,
          33,
          243,
        ), // Selected icon color
        unselectedItemColor: Colors.grey, // Non-selected icons color
        items: const [
          BottomNavigationBarItem(
            label: 'Home',
            icon: Icon(Icons.home),
          ),
          BottomNavigationBarItem(
            label: 'Weather',
            icon: Icon(Icons.cloud),
          ),
          BottomNavigationBarItem(
            label: 'Settings',
            icon: Icon(Icons.settings),
          ),
        ],
      ),
      // Body mein wahi screen nazar aayegi jo currentIndex par hogi
      body: screensList[currentIndex],
    );
  }
}
