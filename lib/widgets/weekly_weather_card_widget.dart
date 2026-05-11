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

  IconData _getIcon(String condition) {
    switch (condition) {
      case 'sunrise':
        return Icons.wb_twilight;
      case 'sunset':
        return Icons.nights_stay_outlined;
      case 'moonrise':
        return Icons.brightness_2_outlined;
      case 'moonset':
        return Icons.brightness_3;
      case 'humidity':
        return Icons.water_drop_outlined;
      case 'uvi':
        return Icons.wb_sunny_outlined;
      case 'pressure':
        return Icons.speed_outlined;
      case 'wind_speed':
        return Icons.air;
      default:
        return Icons.info_outline;
    }
  }

  Color _getIconColor(String condition) {
  switch (condition) {
    case 'sunrise':
      return Colors.orange;
    case 'sunset':
      return Colors.deepOrange;
    case 'moonrise':
      return Colors.lightBlueAccent;
    case 'moonset':
      return Colors.indigo.shade200;
    case 'humidity':
      return const Color.fromARGB(255, 225, 227, 228);
    case 'uvi':
      return Colors.yellow;
    case 'pressure':
      return Colors.greenAccent;
    case 'wind_speed':
      return const Color.fromARGB(255, 137, 216, 227);
    default:
      return Colors.white70;
  }
}

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeklyWeatherprovider = ref.watch(weatherProvider).weeklyWeather;
    var value = weeklyWeatherprovider[index][weatherConditionName];

    if (weatherConditionName == "sunrise") {
      value = DateTime.fromMillisecondsSinceEpoch(value * 1000).toLocal();
      value = DateFormat('hh:mm a').format(value);
    }
    if (weatherConditionName == "sunset") {
      value = DateTime.fromMillisecondsSinceEpoch(value * 1000).toLocal();
      value = DateFormat('hh:mm a').format(value);
    }
    if (weatherConditionName == "moonrise") {
      value = DateTime.fromMillisecondsSinceEpoch(value * 1000).toLocal();
      value = DateFormat('hh:mm a').format(value);
    }
    if (weatherConditionName == "moonset") {
      value = DateTime.fromMillisecondsSinceEpoch(value * 1000).toLocal();
      value = DateFormat('hh:mm a').format(value);
    } else {
      weeklyWeatherprovider[index][weatherConditionName];
    }

    return Card(
      color: Colors.white.withValues(alpha: 0.1),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.white.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getIcon(weatherConditionName),
                  color: _getIconColor(weatherConditionName),
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  weatherConditionName,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: Colors.white70,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              value.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}