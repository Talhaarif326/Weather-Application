import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather/providers/weather_provider.dart'; // Weather details ka data source (List of Maps)

// Stateless widget kyunke ye screen sirf data display kar rahi hai, state change nahi
class WeatherDetail extends ConsumerWidget {
  const WeatherDetail({super.key});

  Map<String, dynamic> _getMetaData(String key , dynamic value) {
  
    // Key ko lowercase kar liya taake mismatch na ho
    switch (key.toLowerCase()) {
      case 'sunrise':
        return {
          'icon': Icons.wb_sunny_rounded,
          'color': Colors.orangeAccent,
          'value': '',
          'unit': '',
          // Helper for time
        };
      case 'sunset':
        return {
          'icon': Icons.wb_twilight_rounded,
          'color': Colors.deepOrange,
          'unit': '',
        };
      case 'humidity':
        return {
          'icon': Icons.water_drop,
          'color': Colors.blue,
          'unit': '%',
        };
      case 'uvindex': // 'uvIndex' becomes 'uvindex' due to .toLowerCase()
        return {
          'icon': Icons.wb_sunny,
          'color': Colors.purple,
          'unit': '',
        };
      case 'visibility':
        return {
          'icon': Icons.remove_red_eye,
          'color': Colors.cyan,
          'unit': ' km',

          // Meters to KM
        };
      case 'pressure':
        return {
          'icon': Icons.speed,
          'color': Colors.grey,
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherModel = ref.watch(weatherProvider);
    final weatherConditions = weatherModel.weatherConditions.entries
        .toList();
    return SizedBox(
      height: 350,
      child: ListView.builder(
        itemCount: weatherConditions.length,
        itemBuilder: (context, index) {
          var entry = weatherConditions[index];
          var metaData = _getMetaData(entry.key , entry.value);
          return ListTile(
            leading: Icon(metaData["icon"] , color:metaData["color"] ,),
            title: Text(entry.key),
            trailing: Text(entry.value.toString()),
          );
        },
      ),
    );
  }
}
