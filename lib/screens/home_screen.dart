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
  final double k = 273.15; // Kelvin to Celsius conversion constant

  @override
  void initState() {
    // Current date ko readable format (Day, Date Month Year) mein set karna
    DateTime date = DateTime.now();
    formatedDate = DateFormat('EEEE, d MMM yyyy').format(date);

    // Search city functionality ke liye controller initialize kiya
    inputControler = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    // Memory leaks se bachne ke liye controller ko dispose karna zaroori hai
    inputControler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Screen ka size lene ke liye MediaQuery ka istemal (Responsiveness ke liye)
    Size size = MediaQuery.of(context).size;

    // weatherProvider se current state watch karna
    final weatherDate = ref.watch(weatherProvider);
    // Agar data load ho raha ho to loading spinner dikhayein
    if (weatherDate.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    // Agar API response khali ho to fallback text dikhayein
    if (weatherDate.currentWeather.isEmpty) {
      return Text('Weather data is empty');
    }

    return Scaffold(
      body: Stack(
        children: [
          // Background Image jo poori screen ko cover karti hai (Wallpaper effect)
          Positioned.fill(
            child: Image.network(
              'https://t3.ftcdn.net/jpg/05/73/34/04/360_F_573340433_8Vd5QU2NI450ri2Q7O2lPHvBsnac0H7w.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // Foreground UI components jo SafeArea ke andar honge
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
                        // Header: User Profile, Greeting aur Notification icon
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
                                  widget
                                      .name, // Displaying user name from constructor
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            // Notification Icon for visual aesthetics
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

                        // Search Bar aur Current Location display section
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
                                          // API se aya hua shehar ka naam (e.g. Dargai)
                                          Text(
                                            weatherDate
                                                .currentWeather['Name'],
                                            style: TextStyle(
                                              fontWeight:
                                                  FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                          // Manual Refresh button to trigger fetchWeather
                                          IconButton(
                                            onPressed: () {
                                              ref
                                                  .read(
                                                    weatherProvider
                                                        .notifier,
                                                  )
                                                  .fetchWeather();
                                            },
                                            iconSize: 20,
                                            icon: Icon(Icons.refresh),
                                          ),
                                        ],
                                      ),
                                      // Aaj ki formatted date
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

                        // Main Weather Card: Temperature aur visual background display
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
                                  // Card ke andar ki specific background image
                                  Positioned.fill(
                                    child: Image.asset(
                                      'assets/images/backgroundimage4.jpg',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  // Card ke upar temperature aur feels-like data display
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
                                          // Weather state ka representation image
                                          Image.asset(
                                            'assets/images/image1.png',
                                            height: 100,
                                          ),
                                          const SizedBox(height: 5),
                                          // Kelvin ko Celsius mein convert karke display kiya
                                          Text(
                                            '${((weatherDate.currentWeather['Temp'] as double) - k).toStringAsFixed(0)}°',
                                            style: TextStyle(
                                              fontWeight:
                                                  FontWeight.bold,
                                              fontSize: 55,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          // Feels Like temperature calculation
                                          Text(
                                            'Feels like ${((weatherDate.currentWeather['FeelsLike'] as double) - k).toStringAsFixed(0)}°',
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

                        // Bottom Card: Hourly forecast horizontal list aur extra weather details
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 2,
                              vertical: 5,
                            ),
                            child: Column(
                              children: [
                                // Ghanton ke hisaab se forecast (Custom Horizontal ListView widget)
                                HoursCardWidget(),
                                const SizedBox(height: 10),
                                // Mazeed details (Humidity, Wind Speed, UV Index, etc.)
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
