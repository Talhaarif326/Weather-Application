import 'package:flutter/material.dart';
import 'package:weather/data/dummydata.dart'; // Hourly weather data (Time, Icon, Temp) yahan se aa raha hai

// Ye widget har ghante ka weather (Hourly Forecast) dikhane ke liye hai
class HoursCardWidget extends StatelessWidget {
  const HoursCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // Horizontal scroll taake user ungli se swipe karke agle ghanton ka weather dekh sake
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // 'hourlyWeather' list mein jitna data hai, utne hi cards loop ke zariye banenge
          for (final item in hourlyWeather)
            InkWell(
              // User tap kare to ripple effect (visual feedback) aaye
              splashColor: Colors.grey.withAlpha(100),
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                // Future updates ke liye click action
              },
              child: Card(
                // Card ka background color dummy data se decide hota hai
                color: item['bgColor'],
                elevation:
                    0, // Flat design aesthetics follow ho rahi hain
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      // Waqt dikhane ke liye (e.g., 10:00 AM)
                      Text(item['time']),
                      const SizedBox(height: 2),
                      // Weather ki halat ke mutabiq icon (e.g., Sun, Cloud, Rain)
                      Icon(item['icon'], color: item['color']),
                      const SizedBox(height: 2),
                      // Us ghante ka temperature (e.g., 22°)
                      Text(item['temp']),
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
