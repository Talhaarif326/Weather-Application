import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class WeatherLottie extends StatelessWidget {
  final int weatherId;
  final bool isDay;
  final double size;
  final bool repeat;

  const WeatherLottie({
    super.key,
    required this.weatherId,
    required this.isDay,
    this.size = 80,
    this.repeat = true,
  });

  static String getLottiePath(int weatherId, bool isDay) {
    if (weatherId >= 200 && weatherId < 300) {
      return 'assets/lottie/thunderstorm.json';
    }
    if (weatherId >= 300 && weatherId < 400) {
      return 'assets/lottie/drizzle.json';
    }
    if (weatherId >= 500 && weatherId < 600) {
      return 'assets/lottie/rainy.json';
    }
    if (weatherId >= 600 && weatherId < 700) {
      return 'assets/lottie/snowy.json';
    }
    if (weatherId >= 700 && weatherId < 800) {
      return 'assets/lottie/foggy.json';
    }
    if (weatherId == 800) {
      return isDay ? 'assets/lottie/sunny.json' : 'assets/lottie/night_clear.json';
    }
    if (weatherId == 801) {
      return isDay ? 'assets/lottie/cloudy.json' : 'assets/lottie/night_cloudy.json';
    }
    if (weatherId >= 802 && weatherId <= 804) {
      return 'assets/lottie/overcast.json';
    }
    return 'assets/lottie/cloudy.json';
  }

  @override
  Widget build(BuildContext context) {
    final path = getLottiePath(weatherId, isDay);
    return Lottie.asset(
      path,
      width: size,
      height: size,
      fit: BoxFit.contain,
      repeat: repeat,
      errorBuilder: (context, error, stackTrace) {
        return SizedBox(width: size, height: size);
      },
    );
  }
}