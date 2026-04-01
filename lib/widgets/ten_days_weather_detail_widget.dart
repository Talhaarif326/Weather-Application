import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:weather/widgets/weekly_weather_card_widget.dart'; // Weather details (Humidity, Wind, etc.) ka data source

// Ye widget 10 days forecast ke andar mazeed details ko horizontal list mein dikhata hai
class TenDaysWeatherDetailWidget extends ConsumerWidget {
  const TenDaysWeatherDetailWidget({
    super.key,
    required this.listIndex,
  });
  final int listIndex;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Day',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        
        SizedBox(height: 10),
        GridView.count(
          shrinkWrap: true,
          physics: PageScrollPhysics(),

          crossAxisCount: 2,
          childAspectRatio: 3 / 1.7,
          children: [
            WeeklyWeatherCardWidget(
              index: listIndex,
              weatherConditionName: 'sunrise',
            ),
            WeeklyWeatherCardWidget(
              index: listIndex,
              weatherConditionName: 'humidity',
            ),
            WeeklyWeatherCardWidget(
              index: listIndex,
              weatherConditionName: 'uvi',
            ),
            WeeklyWeatherCardWidget(
              index: listIndex,
              weatherConditionName: 'sunset',
            ),
          ],
        ),
        SizedBox(height: 10),
        Text(
          'Night',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),

        GridView.count(
          shrinkWrap: true,
          physics: PageScrollPhysics(),

          crossAxisCount: 2,
          childAspectRatio: 3 / 1.7,
          children: [
            WeeklyWeatherCardWidget(
              index: listIndex,
              weatherConditionName: 'moonrise',
            ),
            WeeklyWeatherCardWidget(
              index: listIndex,
              weatherConditionName: 'humidity',
            ),
            WeeklyWeatherCardWidget(
              index: listIndex,
              weatherConditionName: 'uvi',
            ),
            WeeklyWeatherCardWidget(
              index: listIndex,
              weatherConditionName: 'moonset',
            ),
          ],
        ),
      ],
    );
  }
}
