import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather/providers/icons_colors_provider.dart';
import 'package:weather/providers/weather_provider.dart'; // Weather details ka data source (List of Maps)

// Stateless widget kyunke ye screen sirf data display kar rahi hai, state change nahi
class WeatherDetail extends ConsumerWidget {
  const WeatherDetail({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherModel = ref.watch(weatherProvider);
    final iconsColors = ref.watch(iconsColorsProvider);
    final weatherConditions = weatherModel.weatherConditions.entries
        .toList();
    return SizedBox(
      height: 350,
      child: ListView.builder(
        itemCount: weatherConditions.length,
        itemBuilder: (context, index) {
          var entry = weatherConditions[index];
          var metaData = iconsColors.getMetaData(
            entry.key,
            entry.value,
          );
          print('${entry.key} ${entry.value}');
          return ListTile(
            leading: Icon(metaData["icon"], color: metaData["color"]),
            title: Text(entry.key),
            trailing: Text(
              '${metaData['value']} ${metaData['unit']} ',
            ),
          );
        },
      ),
    );
  }
}
