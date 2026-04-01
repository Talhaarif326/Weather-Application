import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
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
    var value = weeklyWeatherprovider[index][weatherConditionName];

    if (weatherConditionName == "sunrise") {
      value = DateTime.fromMillisecondsSinceEpoch(
        value * 1000,
      ).toLocal();
      value = DateFormat('hh:mm a').format(value);
    }

    if (weatherConditionName == "sunset") {
      value = DateTime.fromMillisecondsSinceEpoch(
        value * 1000,
      ).toLocal();
      value = DateFormat('hh:mm a').format(value);
    }

    if (weatherConditionName == "moonrise") {
      value = DateTime.fromMillisecondsSinceEpoch(
        value * 1000,
      ).toLocal();
      value = DateFormat('hh:mm a').format(value);
    }
    if (weatherConditionName == "moonset") {
      value = DateTime.fromMillisecondsSinceEpoch(
        value * 1000,
      ).toLocal();
      value = DateFormat('hh:mm a').format(value);
    } else {
      weeklyWeatherprovider[index][weatherConditionName];
    }

    return Card(
      // Dynamic background color jo dummy data se aa raha hai
      color: const Color.fromARGB(200, 168, 166, 166),
      elevation:
          0, // Flat design look ke liye elevation zero rakhi hai
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 10,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              weatherConditionName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 5),
            Text(value.toString()),
          ],
        ),
      ),
    );
  }
}
