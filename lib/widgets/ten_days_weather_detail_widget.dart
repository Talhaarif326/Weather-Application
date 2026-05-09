import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        // Divider
        Divider(color: Colors.white.withValues(alpha: 0.2), height: 1),
        const SizedBox(height: 10),

        // DAY label
        Text(
          'DAY',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.4,
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 8),

        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 3 / 1.7,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: [
            WeeklyWeatherCardWidget(
                index: listIndex, weatherConditionName: 'sunrise'),
            WeeklyWeatherCardWidget(
                index: listIndex, weatherConditionName: 'humidity'),
            WeeklyWeatherCardWidget(
                index: listIndex, weatherConditionName: 'uvi'),
            WeeklyWeatherCardWidget(
                index: listIndex, weatherConditionName: 'sunset'),
          ],
        ),

        const SizedBox(height: 12),

        // NIGHT label
        Text(
          'NIGHT',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.4,
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 8),

        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 3 / 1.7,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: [
            WeeklyWeatherCardWidget(
                index: listIndex, weatherConditionName: 'moonrise'),
            WeeklyWeatherCardWidget(
                index: listIndex, weatherConditionName: 'pressure'),
            WeeklyWeatherCardWidget(
                index: listIndex, weatherConditionName: 'wind_speed'),
            WeeklyWeatherCardWidget(
                index: listIndex, weatherConditionName: 'moonset'),
          ],
        ),
      ],
    );
  }
}