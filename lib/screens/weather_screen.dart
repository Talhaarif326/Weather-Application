import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Date formatting ke liye library

// Aapke custom files aur widgets
import 'package:weather/data/hourly_data_genrator.dart';
import 'package:weather/screens/main_screen.dart';
import 'package:weather/widgets/hours_card_widget.dart';
import 'package:weather/widgets/ten_days_weather_detail_widget.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key, required this.name});

  final String
  name; // User ka naam ya city name jo pichli screen se pass hua
  @override
  State<WeatherScreen> createState() {
    return _WeatherScreenState();
  }
}

class _WeatherScreenState extends State<WeatherScreen> {
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
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('14 Days weather Forecast'),
        backgroundColor: Colors.transparent,
        elevation: 0, // Clean look ke liye elevation zero
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: [
              // --- Header Card: Aaj ka weather aur location display karne ke liye ---
              SizedBox(
                child: InkWell(
                  splashColor: Colors.grey.withAlpha(100),
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    // Main Screen par wapas jane ke liye logic
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (constext) =>
                            MainScreen(name: widget.name),
                      ),
                    );
                  },
                  child: Card(
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
                                      Icon(
                                        Icons.location_on_outlined,
                                      ),
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
                                  const Text(
                                    'clear',
                                  ), // Weather status
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
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // --- Forecast List: Agle dino ka weather dikhane ke liye loop ---
              // weekWeatherDate list se data map ho raha hai (asMap use kiya taake index mil sake)
              for (final entry in weekWeatherDate.asMap().entries)
                Builder(
                  builder: (context) {
                    final index = entry.key; // Current item ka index
                    final item =
                        entry.value; // Current item ka data (Map)

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 15,
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['Name'], // Din ka naam (e.g., Monday)
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              crossAxisAlignment:
                                  CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Text(
                                        item['Weather'],
                                      ), // Weather description
                                      const Spacer(),
                                      Icon(
                                        item['Icon'],
                                        color: item['Icon Color'],
                                      ), // Weather Icon
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${item['Temp']}°',
                                      ), // Main Temp
                                      const SizedBox(width: 4),
                                      // Divider rotate logic
                                      Transform.rotate(
                                        angle: 0.3,
                                        child: Container(
                                          height: 20,
                                          width: 1.5,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${item['FeelLike']}°',
                                      ), // Feels like Temp
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            // --- Conditional Expansion: "More" details dikhane ka section ---
                            const SizedBox(height: 10),
                            // Agar ye card select hua hai (expandedIndex == index), to details dikhao
                            if (expandedIndex == index)
                              SizedBox(
                                child: Column(
                                  children: [
                                    // Hourly Forecast Horizontal List
                                    SingleChildScrollView(
                                      scrollDirection:
                                          Axis.horizontal,
                                      child: Row(
                                        children: const [
                                          HoursCardWidget(),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    // mazeed weather details (Humidity, Wind, etc.)
                                    const TenDaysWeatherDetailWidget(),
                                  ],
                                ),
                              ),

                            const SizedBox(height: 2),
                            // --- More/Less Toggle Button ---
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      // Agar wahi card dubara click ho to band kar do (null), warna naya index set karo
                                      expandedIndex =
                                          expandedIndex == index
                                          ? null
                                          : index;
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(
                                      8.0,
                                    ),
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
            ],
          ),
        ),
      ),
    );
  }
}
