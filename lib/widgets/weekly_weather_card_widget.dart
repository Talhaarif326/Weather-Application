import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather/providers/weather_provider.dart';

class WeeklyWeatherCardWidget extends ConsumerWidget {
  const WeeklyWeatherCardWidget({
    super.key,
    required this.index,
    required this.weatherConditionName,
    
  });
  final int index;
  final String weatherConditionName;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeklyWeatherprovider = ref
        .watch(weatherProvider)
        .weeklyWeather;
    return Card(
      // Dynamic background color jo dummy data se aa raha hai
      color: Colors.amber,
      elevation:
          0, // Flat design look ke liye elevation zero rakhi hai
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 10,
        ),
        child: Column(
          children: [
            Text(weatherConditionName),
            Text(weeklyWeatherprovider[index][weatherConditionName].toString()),
          ],
        ),
      ),
    );
  }
}
