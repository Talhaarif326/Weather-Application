import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:intl/intl.dart';
import 'package:weather/providers/weather_provider.dart';
import 'package:weather/widgets/hours_card_widget.dart';
import 'package:weather/widgets/today_weather_detail_widget.dart';

// HomeScreen: Jahan user ko current weather aur search ki facility milti hai
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, required this.name});

  final String name; // Welcome screen se pass kiya gaya user ka naam
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late TextEditingController inputControler;
  late String formatedDate;
  final double k = 273.15;

  @override
  void initState() {
    // Current date ko readable format mein set karna
    DateTime date = DateTime.now();
    formatedDate = DateFormat('EEEE, d MMM yyyy').format(date);
    inputControler =
        TextEditingController(); // Search city ke liye controller
    //apiCall method for fetching data

    super.initState();
  }

  @override
  void dispose() {
    inputControler.dispose(); // Controller ko clean up karna
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Screen ka size lene ke liye MediaQuery ka istemal (Responsiveness ke liye)
    Size size = MediaQuery.of(context).size;
    final weatherDate = ref.watch(weatherProvider);

    if (weatherDate.isLoading) {
     
      return Center(child: CircularProgressIndicator());
    }
    if (weatherDate.weatherData.isEmpty ||
        weatherDate.hourlyWeather.isEmpty) {
      return Text('Weather data is empty');
    }

    return Scaffold(
      body: Stack(
        children: [
          // Background Image jo poori screen ko cover karti hai
          Positioned.fill(
            child: Image.network(
              'https://t3.ftcdn.net/jpg/05/73/34/04/360_F_573340433_8Vd5QU2NI450ri2Q7O2lPHvBsnac0H7w.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Foreground UI components
          Positioned(
            child: SafeArea(
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 10,
                    ),
                    child: ListView(
                      children: [
                        // Header: User Profile aur Greeting section
                        Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.center,
                          children: [
                            const CircleAvatar(
                              maxRadius: 30,
                              backgroundImage: NetworkImage(
                                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQf9VRGEzTGaYboycgdNeCkUAxN-7GM-IQykGR_UgzxUA&s',
                              ),
                            ),
                            const SizedBox(width: 15),
                            Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Good Morning!',
                                  style: TextStyle(
                                    color: Colors.blueGrey,
                                  ),
                                ),
                                Text(
                                  widget.name, // Displaying user name
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            // Notification Icon
                            const CircleAvatar(
                              maxRadius: 30,
                              backgroundColor: Colors.transparent,
                              child: Icon(
                                Icons.notifications,
                                size: 30,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Search Bar aur Current Location display
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(
                                    255,
                                    206,
                                    202,
                                    202,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    20,
                                  ),
                                ),
                                padding: const EdgeInsets.all(10),
                                child: TextField(
                                  controller: inputControler,
                                  decoration: const InputDecoration(
                                    hintText: 'Search City',
                                    border: InputBorder.none,
                                    icon: Icon(Icons.search),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Row(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons
                                                .location_on_outlined,
                                          ),
                                          SizedBox(width: 5),
                                          Text(
                                            weatherDate
                                                .weatherData['Name'],
                                            style: TextStyle(
                                              fontWeight:
                                                  FontWeight.bold,
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
                            ),
                          ],
                        ),

                        SizedBox(height: size.height * .02),
                        // Main Weather Card (Temperature aur Visual representation)
                        Container(
                          height: size.height * .35,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: InkWell(
                            onTap: () {},
                            child: Card(
                              elevation: 10,
                              shadowColor: Colors.grey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  30,
                                ),
                              ),
                              clipBehavior: Clip.hardEdge,
                              child: Stack(
                                children: [
                                  // Card background image
                                  Positioned.fill(
                                    child: Image.asset(
                                      'assets/images/backgroundimage4.jpg',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  // Card text data (Temp, Feels like)
                                  Positioned(
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 15,
                                          ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Image.asset(
                                            'assets/images/image1.png', // Weather Icon (Sunny/Cloudy)
                                            height: 100,
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            '${((weatherDate.weatherData['Temp'] as double) - k).toStringAsFixed(0)}°',
                                            style: TextStyle(
                                              fontWeight:
                                                  FontWeight.bold,
                                              fontSize: 55,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            'Feels like ${((weatherDate.weatherData['FeelsLike'] as double) - k).toStringAsFixed(0)}°',
                                            style: TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),
                        // Bottom Card: Hourly forecast aur mazeed details ke liye
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 2,
                              vertical: 5,
                            ),
                            child: Column(
                              children: [
                                // Ghanton ke hisaab se forecast (Horizontal List)
                                HoursCardWidget(),
                                const SizedBox(height: 10),
                                // Mazeed details (Humidity, Wind, etc.)
                                WeatherDetail(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
