import 'package:flutter/material.dart';
import 'package:weather/data/dummydata.dart'; // Weather details (Humidity, Wind, etc.) ka data source

// Ye widget 10 days forecast ke andar mazeed details ko horizontal list mein dikhata hai
class TenDaysWeatherDetailWidget extends StatelessWidget {
  const TenDaysWeatherDetailWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // Horizontal scroll enabled taake details side-by-side nazar aayein
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Loop ke zariye data list se cards generate ho rahe hain
          for (final item in weatherDetails)
            InkWell(
              splashColor: Colors.grey.withAlpha(100),
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                // Future tap action placeholder
              },
              child: Card(
                // Dynamic background color jo dummy data se aa raha hai
                color: item['bgColor'],
                elevation: 0, // Flat design look ke liye elevation zero rakhi hai
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 13 , vertical: 10),
                  child: Column(
                    children: [
                      // Detail ka title (e.g., Wind)
                      Text(item['title']),
                      const SizedBox(height: 2),
                      // Detail se mutalliqa icon aur uska color
                      Icon(item['icon'], color: item['color']),
                      const SizedBox(height: 2),
                      // Detail ki value (e.g., 5 km/h)
                      Text(item['value']),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}