import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:weather/providers/weather_provider.dart';
import 'package:weather/utils/temp_converter.dart';

class HoursCardWidget extends ConsumerWidget {
  const HoursCardWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hoursWeather = ref.watch(weatherProvider);

    if (hoursWeather.isLoading) {
      return const CircularProgressIndicator();
    }

    if (hoursWeather.hourlyWeather.isEmpty) {
      return const Text(
        'No Data present',
        style: TextStyle(color: Colors.white70),
      );
    }

    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 24,
        itemBuilder: (context, index) {
          final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
            hoursWeather.hourlyWeather[index]['dt'] * 1000,
          ).toLocal();

          final String formatedDate = DateFormat('hh:mm a').format(dateTime);

          final tempUnit = hoursWeather.tempUnit;
          final String temp = TempConverter.convert(
            (hoursWeather.hourlyWeather[index]['temp'] as num).toDouble(),
            tempUnit,
          ).round().toString();

          final String iconCode = hoursWeather
              .hourlyWeather[index]['weather'][0]['icon']
              .toString();

          final bool isNight = iconCode.endsWith('n');

          // Glass card colors matching the theme
          final Color cardColor = isNight
              ? Colors.white.withValues(alpha: 0.08)  
              : Colors.white.withValues(alpha: 0.18); 

          final Color borderColor = isNight
              ? Colors.white.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.35);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: InkWell(
              splashColor: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              onTap: () {},
              child: Container(
                width: 70,
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor, width: 1),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 8,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Time
                    Text(
                      formatedDate,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),

                    // Weather icon
                    Image.network(
                      'https://openweathermap.org/img/wn/$iconCode@2x.png',
                      height: 32,
                      width: 32,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        isNight ? Icons.nightlight_round : Icons.wb_sunny,
                        color: isNight
                            ? Colors.white60
                            : Colors.yellow.shade300,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Temperature
                    Text(
                      '$temp${TempConverter.label(tempUnit)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}