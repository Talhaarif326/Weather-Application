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

  String _formatValue(String key, dynamic value) {
    if (key == 'sunrise' ||
        key == 'sunset' ||
        key == 'moonrise' ||
        key == 'moonset') {
      if ((value as int) == 0) return '--';
      final dt = DateTime.fromMillisecondsSinceEpoch(value * 1000);
      return DateFormat('h:mm a').format(dt);
    }
    if (key == 'humidity') return '$value%';
    if (key == 'uvi') return value.toString();
    if (key == 'wind_speed') {
      return '${(value as num).toStringAsFixed(1)} m/s';
    }
    if (key == 'pressure') return '$value hPa';
    return value.toString();
  }

  IconData _getIcon(String key) {
    switch (key) {
      case 'sunrise':
        return Icons.wb_twilight;
      case 'sunset':
        return Icons.nights_stay_outlined;
      case 'humidity':
        return Icons.water_drop_outlined;
      case 'uvi':
        return Icons.wb_sunny_outlined;
      case 'wind_speed':
        return Icons.air;
      case 'pressure':
        return Icons.speed;
      case 'moonrise':
        return Icons.mode_night;
      case 'moonset':
        return Icons.nights_stay_sharp;
      default:
        return Icons.info_outline;
    }
  }

  // Accent color per card type
  Color _getAccentColor(String key) {
    switch (key) {
      case 'sunrise':
        return Colors.orange.shade300;
      case 'sunset':
        return Colors.deepOrange.shade300;
      case 'humidity':
        return Colors.lightBlue.shade300;
      case 'uvi':
        return Colors.yellow.shade300;
      case 'wind_speed':
        return Colors.teal.shade300;
      case 'pressure':
        return Colors.grey.shade400;
      case 'moonrise':
        return Colors.indigo.shade200;
      case 'moonset':
        return Colors.blueGrey.shade300;
      default:
        return Colors.white70;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeklyWeatherprovider = ref
        .watch(weatherProvider)
        .weeklyWeather;
    final raw = weeklyWeatherprovider[index][weatherConditionName];
    final displayValue = _formatValue(weatherConditionName, raw);
    final accentColor = _getAccentColor(weatherConditionName);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getIcon(weatherConditionName),
                size: 14,
                color: accentColor,
              ),
              const SizedBox(width: 5),
              Text(
                weatherConditionName.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withValues(
                    alpha: 0.85,
                  ), 
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w500, 
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            displayValue,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }
}
