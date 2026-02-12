import 'package:flutter/material.dart';
import 'package:weather/data/dummydata.dart'; // Weather details ka data source (List of Maps)

// Stateless widget kyunke ye screen sirf data display kar rahi hai, state change nahi
class WeatherDetail extends StatelessWidget {
  const WeatherDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // Scrollable view taake agar details zyada hon to screen par fit aa sakein
      // scrollDirection: Axis.vertical,
      child: Column(
        children: [
          // 'weatherDetails' list par loop chala kar har item ke liye ek card generate ho raha hai
          for (final item in weatherDetails)
            InkWell(
              // Tap karne par ripple effect dene ke liye InkWell
              splashColor: Colors.grey.withAlpha(100),
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                // Future implementation ke liye empty tap function
              },
              child: Card(
                // Data se background color pick ho raha hai (e.g., UV Index ya Humidity ke liye alag color)
                color: item['bgColor'],
                elevation: 0.1,
                child: Padding(
                  padding: const EdgeInsets.all(13),
                  child: Row(
                    children: [
                      // Detail se related icon aur uska specific color
                      Icon(item['icon'], color: item['color']),
                      SizedBox(width: 10),
                      // Detail ka title (e.g., "Humidity", "Wind Speed")
                      Text(item['title']),
                      Spacer(), // Title aur Value ke darmiyan saari khali jagah pur karne ke liye
                      // Detail ki actual value (e.g., "60%", "12km/h")
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
