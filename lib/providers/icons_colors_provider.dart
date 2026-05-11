import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class IconsColorsProvider {
  Map<String, dynamic> getMetaData(String key, dynamic value) {
    final DateTime time = DateTime.fromMillisecondsSinceEpoch(
      (value as num).toInt() * 1000,
    ).toLocal();
    final String formatedTime = DateFormat('hh:mm a').format(time);
    // Key ko lowercase kar liya taake mismatch na ho
    switch (key.toLowerCase()) {
      case 'sunrise':
        return {
          'icon': Icons.wb_sunny_rounded,
          'color': Colors.orangeAccent,
          'value': formatedTime,
          'unit': '',
          // Helper for time
        };
      case 'sunset':
        return {
          'icon': Icons.wb_twilight_rounded,
          'color': const Color.fromARGB(255, 244, 182, 163),
          'value': formatedTime,
          'unit': '',
        };
      case 'humidity':
        return {
          'icon': Icons.water_drop,
          'color': const Color.fromARGB(255, 177, 212, 241),
          'value': value,
          'unit': '%',
        };
      case 'ultraviolet': // 'uvIndex' becomes 'uvindex' due to .toLowerCase()
        return {
          'icon': Icons.wb_sunny,
          'color': const Color.fromARGB(255, 230, 113, 251),
          'value': value,
          'unit': '',
        };
      case 'visibility':
        return {
          'icon': Icons.remove_red_eye,
          'color': Colors.cyan,
          'value': value / 1000,
          'unit': ' km',

          // Meters to KM
        };
      case 'pressure':
        return {
          'icon': Icons.speed,
          'color': Colors.grey,
          "value": value,
          'unit': ' hPa',
        };
      default:
        return {
          'icon': Icons.info_outline,
          'color': Colors.teal,
          'unit': '',
        };
    }
  }
}

final iconsColorsProvider = Provider((ref) {
  return IconsColorsProvider();
});
