import 'package:flutter/material.dart';
import 'package:weather/screens/home_screen.dart';
import 'package:weather/screens/setting_screen.dart';
import 'package:weather/screens/weather_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key, required this.name});
  final String name;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late String myName;
  int currentIndex = 0;

  @override
  void initState() {
    myName = widget.name;
    super.initState();
  }
 

  late List<Widget> screensList = [
    HomeScreen(name: myName),
    WeatherScreen(name: myName),
    SettingScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          setState(() => currentIndex = index);
        },
        enableFeedback: true,
        currentIndex: currentIndex,
        selectedItemColor: const Color(0xFF4A90E2),
        unselectedItemColor: Colors.white38,
        backgroundColor: const Color(0xFF1A2940),
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
      body: screensList[currentIndex],
    );
  }
}
