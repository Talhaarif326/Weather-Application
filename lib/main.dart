import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:weather/screens/welcome_screen.dart'; // Sab se pehle WelcomeScreen load hogi

// kColorScheme: Poori app ka color palette yahan define ho raha hai
// 'fromSeed' use karne ka faida ye hai ke Flutter khud hi primary aur secondary colors generate kar leta hai
final kColorScheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color.fromARGB(
      255,
      249,
      247,
      247,
    ), // Base color for the app theme
  ),
  // App ki har screen ka default background color
  scaffoldBackgroundColor: const Color.fromARGB(255, 231, 228, 228),
);

// main(): Flutter app ka entry point, jahan se execution shuru hoti hai
Future<void> main() async {
  await dotenv.load(fileName: '.env');
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner:
          false, // (Tip) Is se top-right corner ka red banner hat jayega
      theme: kColorScheme, // Upar define kiya gaya theme apply kiya
      home:
          const WelcomeScreen(), // App khulte hi sab se pehle WelcomeScreen nazar aayegi
    ),
  );
}
