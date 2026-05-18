import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather/providers/weather_provider.dart';
import 'package:weather/utils/weather_summary_builder.dart';
import 'package:weather/widgets/weekly_weather_card_widget.dart';

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
            color: Colors.white,
          ),
        ),
        ListTile(
          leading: const Icon(
            Icons.info_outline,
            color: Colors.white70,
            size: 20,
          ),
          title: Text(WeatherSummaryBuilder.build(
            ref.watch(weatherProvider).weeklyWeather[listIndex],
             
          ),
          style: TextStyle(color: Colors.white70, fontSize: 12),),
          
          dense: true,
          contentPadding: EdgeInsets.zero,
        ),
        const SizedBox(height: 10),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 3 / 1.7,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
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
        const SizedBox(height: 10),
        Text(
          'Night',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 3 / 1.7,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: [
            WeeklyWeatherCardWidget(
              index: listIndex,
              weatherConditionName: 'moonrise',
            ),
            WeeklyWeatherCardWidget(
              index: listIndex,
              weatherConditionName: 'pressure',
            ),
            WeeklyWeatherCardWidget(
              index: listIndex,
              weatherConditionName: 'wind_speed',
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
