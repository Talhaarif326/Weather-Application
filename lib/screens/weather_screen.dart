import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:weather/providers/weather_provider.dart';
import 'package:weather/widgets/ten_days_weather_detail_widget.dart';
import 'package:weather/utils/temp_converter.dart';

class WeatherScreen extends ConsumerStatefulWidget {
  const WeatherScreen({super.key, required this.name});
  final String name;

  @override
  ConsumerState<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends ConsumerState<WeatherScreen> {
  int? expandedIndex;

  @override
  Widget build(BuildContext context) {
    final weeklyWeatherprovider = ref.watch(weatherProvider).weeklyWeather;
    final tempUnit = ref.watch(weatherProvider).tempUnit;
    final cityName =
        ref.watch(weatherProvider).currentWeather['Name'] ?? 'Unknown';

    return Scaffold(
      // Gradient background matching home screen
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4A90E2), Color(0xFF1B3A6B)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom AppBar
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 12, horizontal: 16),
                child: Text(
                  'Weekly Forecast',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: weeklyWeatherprovider.length,
                    itemBuilder: (context, index) {
                      final dt =
                          weeklyWeatherprovider[index]['dt'] as int;
                      final cardDate =
                          DateFormat('EEEE, d MMM yyyy').format(
                        DateTime.fromMillisecondsSinceEpoch(dt * 1000),
                      );

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Location + Date row
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on_outlined,
                                    color: Colors.white70,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 5),
                                  Flexible(
                                    child: Text(
                                      cityName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                cardDate,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.65),
                                  fontSize: 12,
                                ),
                              ),

                              const SizedBox(height: 10),

                              // Temp + weather info row
                              Row(
                                children: [
                                  Text(
                                    '${TempConverter.convert((weeklyWeatherprovider[index]["temp"]['day'] as num).toDouble(), tempUnit).toStringAsFixed(0)}${TempConverter.label(tempUnit)}',
                                    style: const TextStyle(
                                      fontSize: 42,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const Spacer(),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        weeklyWeatherprovider[index]
                                                ["weather"][0]["description"]
                                            .toString(),
                                        style: TextStyle(
                                          color: Colors.white
                                              .withValues(alpha: 0.85),
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Text(
                                            TempConverter.convert(
                                                      (weeklyWeatherprovider[index]
                                                                  ["temp"]
                                                              ['max']
                                                          as num)
                                                          .toDouble(),
                                                      tempUnit,
                                                    ).toStringAsFixed(0) +
                                                TempConverter.label(tempUnit),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets
                                                .symmetric(horizontal: 6),
                                            child: Transform.rotate(
                                              angle: 0.3,
                                              child: Container(
                                                height: 16,
                                                width: 1.5,
                                                color: Colors.white54,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            TempConverter.convert(
                                                      (weeklyWeatherprovider[index]
                                                                  ["temp"]
                                                              ['min']
                                                          as num)
                                                          .toDouble(),
                                                      tempUnit,
                                                    ).toStringAsFixed(0) +
                                                TempConverter.label(tempUnit),
                                            style: TextStyle(
                                              color: Colors.white
                                                  .withValues(alpha: 0.7),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        'Feels like ${TempConverter.convert((weeklyWeatherprovider[index]["feels_like"]['day'] as num).toDouble(), tempUnit).toStringAsFixed(0)}${TempConverter.label(tempUnit)}',
                                        style: TextStyle(
                                          color: Colors.white
                                              .withValues(alpha: 0.65),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              // Expanded detail section
                              if (expandedIndex == index)
                                Column(
                                  children: [
                                    const SizedBox(height: 10),
                                    TenDaysWeatherDetailWidget(
                                        listIndex: index),
                                  ],
                                ),

                              const SizedBox(height: 4),

                              // More/Less button
                              Center(
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      expandedIndex =
                                          expandedIndex == index
                                              ? null
                                              : index;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(20),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 6),
                                    child: Text(
                                      expandedIndex == index
                                          ? 'Less'
                                          : 'More',
                                      style: TextStyle(
                                        color: Colors.white
                                            .withValues(alpha: 0.85),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}