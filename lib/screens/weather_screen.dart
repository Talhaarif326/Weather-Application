import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:weather/providers/weather_provider.dart';
import 'package:weather/utils/lottie_helper.dart';
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
  late String formatedDate;
  final k = 273.15;

  @override
  Widget build(BuildContext context) {
    final cityName = ref.watch(weatherProvider).currentWeather;
    final weeklyWeatherprovider = ref
        .watch(weatherProvider)
        .weeklyWeather;
    final tempUnit = ref.watch(weatherProvider).tempUnit;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Weekly Weather Forecast',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF4A90E2),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4A90E2), Color(0xFF1B3A6B)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: weeklyWeatherprovider.length,
              itemBuilder: (context, index) {
                final DateTime dateTime =
                    DateTime.fromMillisecondsSinceEpoch(
                      weeklyWeatherprovider[index]['dt'] * 1000,
                    ).toLocal();

                formatedDate = DateFormat(
                  'EEEE, d MMM yyyy',
                ).format(dateTime);

                String iconCode =
                    weeklyWeatherprovider[index]['weather'][0]['icon']
                        .toString();

                return Card(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  elevation: 0,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on_outlined,
                                      color: Colors.white70,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      cityName['Name'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  formatedDate.toString(),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                          ],
                        ),
                        Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${TempConverter.convert((weeklyWeatherprovider[index]["temp"]['day'] as num).toDouble(), tempUnit).toStringAsFixed(0)}${TempConverter.label(tempUnit)}',
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const Spacer(),
                            Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    WeatherLottie(
                                      weatherId:
                                          weeklyWeatherprovider[index]['weather'][0]['id']
                                              as int,
                                      isDay: iconCode.endsWith('d'),
                                      size: 55,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      weeklyWeatherprovider[index]["weather"][0]['description'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      '${TempConverter.convert((weeklyWeatherprovider[index]["temp"]['max'] as num).toDouble(), tempUnit).toStringAsFixed(0)}°',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Transform.rotate(
                                      angle: 0.3,
                                      child: Container(
                                        height: 20,
                                        width: 1.5,
                                        color: Colors.white54,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${TempConverter.convert((weeklyWeatherprovider[index]["temp"]['min'] as num).toDouble(), tempUnit).toStringAsFixed(0)}°',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  'Feels like ${TempConverter.convert((weeklyWeatherprovider[index]["feels_like"]['day'] as num).toDouble(), tempUnit).toStringAsFixed(0)}°',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (expandedIndex == index)
                          Column(
                            children: [
                              const SizedBox(height: 5),
                              TenDaysWeatherDetailWidget(
                                listIndex: index,
                              ),
                            ],
                          ),
                        const SizedBox(height: 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  expandedIndex =
                                      expandedIndex == index
                                      ? null
                                      : index;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  expandedIndex == index
                                      ? "Less"
                                      : "More",
                                  style: const TextStyle(
                                    color: Colors.lightBlueAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
