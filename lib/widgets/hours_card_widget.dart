import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:weather/providers/weather_provider.dart';
// Hourly weather data (Time, Icon, Temp) yahan se aa raha hai

// Ye widget har ghante ka weather (Hourly Forecast) dikhane ke liye hai
class HoursCardWidget extends ConsumerWidget {
  const HoursCardWidget({super.key});

  @override
  build(context, WidgetRef ref) {
    // Weather provider se data watch kiya ja raha hai
    final hoursWeather = ref.watch(weatherProvider);

    // Debugging ke liye data console par print kiya
  

    // Agar data load ho raha ho to spinner dikhayein
    if (hoursWeather.isLoading) {
      return CircularProgressIndicator();
    }

    // Agar list khali mile to error message dikhayein
    if (hoursWeather.hourlyWeather.isEmpty) {
      return Text('No Data present');
    }

    return SizedBox(
      height: 120, // Horizontal list ke liye fixed height
      child: ListView.builder(
        scrollDirection: Axis
            .horizontal, // List ko left-to-right scrollable banaya
        itemCount: 24, // Agle 24 ghanton ka forecast limit kiya
        itemBuilder: (context, index) {
          // Unix timestamp ko local DateTime mein badla (seconds to milliseconds)
          final DateTime dateTime =
              DateTime.fromMillisecondsSinceEpoch(
                hoursWeather.hourlyWeather[index]['dt'] * 1000,
              ).toLocal();

          // Time ko "hh:mm AM/PM" format mein convert kiya
          String formatedDate = DateFormat(
            'hh:mm a',
          ).format(dateTime);

          // Kelvin temperature ko Celsius mein badal kar round kiya
          String temp =
              ((hoursWeather.hourlyWeather[index]['temp'] as double) -
                      273.15)
                  .round()
                  .toString();

          // API se icon ka specific code uthaya (e.g., 01d, 10n)
          String iconCode = hoursWeather
              .hourlyWeather[index]['weather'][0]['icon']
              .toString();

          // Background color variable define kiya
          Color backgroundColor;

          // Day aur Night ke liye alag alag theme colors set kiye
          if (iconCode.endsWith('n')) {
            // Raat ke liye greyish tone
            backgroundColor = Colors.grey.shade300;
          } else {
            // Din ke liye yellowish/orange tone
            backgroundColor = Colors.orange.shade50;
          }

          return InkWell(
            // User tap kare to ripple effect (visual feedback) aaye
            splashColor: Colors.grey.withAlpha(100),
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              // Future updates ke liye click action
            },
            child: Card(
              // Elevation aur card ki styling
              elevation: 1,
              color:
                  backgroundColor, // Din aur raat ke mutabiq dynamic color
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    // Waqt dikhane ke liye (e.g., 10:00 AM)
                    Text(formatedDate),
                    const SizedBox(height: 2),
                    // Weather ki halat ke mutabiq icon (Image server se load ho rahi hai)
                    Image.network(
                      'https://openweathermap.org/img/wn/$iconCode@2x.png',

                      height: 30,
                      width: 50,
                    ),
                    const SizedBox(height: 2),
                    // Us ghante ka temperature degree symbol ke saath
                    Text("$temp°"),
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
