import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // Date formatting ke liye library

// Aapke custom files aur widgets

import 'package:weather/providers/weather_provider.dart';

import 'package:weather/widgets/ten_days_weather_detail_widget.dart';

class WeatherScreen extends ConsumerStatefulWidget {
  const WeatherScreen({super.key, required this.name});

  final String
  name; // User ka naam ya city name jo pichli screen se pass hua
  @override
  ConsumerState<WeatherScreen> createState() {
    return _WeatherScreenState();
  }
}

class _WeatherScreenState extends ConsumerState<WeatherScreen> {
  // expandedIndex track karta hai ke kaunsa card currently "More" state mein open hai.
  // Agar ye null hai, to koi bhi card expanded nahi hai.
  int? expandedIndex;
  late String formatedDate;

  @override
  void initState() {
    // Screen load hote hi aaj ki date ko specific format (e.g., Friday, 12 Feb 2026) mein convert karna
    DateTime date = DateTime.now();
    formatedDate = DateFormat('EEEE, d MMM yyyy').format(date);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final weeklyWeatherprovider = ref
        .watch(weatherProvider)
        .weeklyWeather;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Weekly weather Forecast'),
        backgroundColor: Colors.transparent,
        elevation: 0, // Clean look ke liye elevation zero
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView.builder(
            shrinkWrap: true,
            physics: BouncingScrollPhysics(),
            itemCount: weeklyWeatherprovider.length,
            itemBuilder: (context, index) {
              return Card(
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
                                children: const [
                                  Icon(Icons.location_on_outlined),
                                  SizedBox(width: 5),
                                  Text(
                                    'Dargai', // Hardcoded location, isay aap dynamic kar sakte hain
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                formatedDate.toString(),
                                style: const TextStyle(
                                  color: Colors.blueGrey,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                        ],
                      ),
                      Row(
                        children: [
                          const Text(
                            '18°', // Current Temp
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.end,
                            children: [
                              const Text('clear'), // Weather status
                              Row(
                                children: [
                                  const Text('18°'),
                                  const SizedBox(width: 4),
                                  // Vertical divider line (Thora rotate kiya hua design ke liye)
                                  Transform.rotate(
                                    angle: 0.3,
                                    child: Container(
                                      height: 20,
                                      width: 1.5,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Text('7°'),
                                ],
                              ),
                              const Text('Feels like 9°'),
                            ],
                          ),
                        ],
                      ),
                      if (expandedIndex == index)
                        SizedBox(
                          child: Column(
                            children: [
                              // Hourly Forecast Horizontal List
                              const SizedBox(height: 5),
                              // mazeed weather details (Humidity, Wind, etc.)
                              TenDaysWeatherDetailWidget(
                                listIndex: index,
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 2),
                      // --- More/Less Toggle Button ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                // Agar wahi card dubara click ho to band kar do (null), warna naya index set karo
                                expandedIndex = expandedIndex == index
                                    ? null
                                    : index;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                expandedIndex == index
                                    ? "less"
                                    : "More",
                                style: const TextStyle(
                                  color: Colors.blue,
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
    );
  }
}
