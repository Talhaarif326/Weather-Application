

class WeatherSummaryBuilder {
  static String build(Map<String, dynamic> day,) {
    final List<String> parts = [];

    final pop = ((day['pop'] as num) * 100).toInt();
    if (pop > 0) parts.add('$pop% rain');

    final uvi = (day['uvi'] as num).toDouble();
    if (uvi >= 8)
      parts.add('Extreme UV — wear sunscreen');
    else if (uvi >= 6)
      parts.add('High UV — stay covered');
    else if (uvi >= 3)
      parts.add('Moderate UV');

    final gust = (day['wind_gust'] as num).toDouble();
    final wind = (day['wind_speed'] as num).toDouble();
    if (gust > 10)
      parts.add('Strong gusts — hold onto your hat');
    else if (wind > 6)
      parts.add('Breezy');

    final humidity = day['humidity'] as int;
    if (humidity > 70)
      parts.add('Humid — stay hydrated');
    else if (humidity < 20)
      parts.add('Very dry — moisturise');

    final clouds = day['clouds'] as int;
    if (clouds > 80)
      parts.add('Overcast');
    else if (clouds > 40)
      parts.add('Partly cloudy');
    else if (clouds > 10)
      parts.add('Few clouds');
    else
      parts.add('Clear skies');

    return parts.join(' · ');
  }
}
