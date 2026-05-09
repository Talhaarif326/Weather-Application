import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:weather/database/db_helper.dart';
import 'package:weather/screens/welcome_screen.dart';
import 'package:weather/screens/main_screen.dart';

final kColorScheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF4A90E2),
    brightness: Brightness.light, 
  ),
  scaffoldBackgroundColor: const Color(0xFF1C2E4A),
  cardTheme: CardThemeData(
    color: Colors.white, 
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    foregroundColor: Colors.white,
    centerTitle: true,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xFF1A2940),
    selectedItemColor: Color(0xFF4A90E2),
    unselectedItemColor: Colors.white38,
  ),
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
    

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  await flutterLocalNotificationsPlugin.initialize(
    const InitializationSettings(android: androidSettings),
  );

  final String? savedName = await DbHelper.instance.getUser();

  runApp(
    ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: kColorScheme,
        home: savedName != null
            ? MainScreen(name: savedName)
            : const WelcomeScreen(),
      ),
    ),
  );
}