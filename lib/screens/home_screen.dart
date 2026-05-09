import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:weather/providers/weather_provider.dart';

import 'package:weather/widgets/hours_card_widget.dart';
import 'package:weather/widgets/today_weather_detail_widget.dart';
import 'package:weather/utils/temp_converter.dart';


class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, required this.name});
  final String name;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late TextEditingController inputControler;
  late String formatedDate;
  List<String> _suggestions = [];
  bool _showSuggestions = false;

  @override
  void initState() {
    DateTime date = DateTime.now();
    formatedDate = DateFormat('EEEE, d MMM yyyy').format(date);
    inputControler = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    inputControler.dispose();
    super.dispose();
  }

  Future<void> _onSearchChanged(String query) async {
    if (query.length < 2) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      return;
    }
    final results = await ref
        .read(weatherProvider.notifier)
        .getCitySuggestions(query);
    setState(() {
      _suggestions = results;
      _showSuggestions = results.isNotEmpty;
    });
  }

  void _onSuggestionTap(String city) {
    inputControler.clear();
    setState(() {
      _suggestions = [];
      _showSuggestions = false;
    });
    FocusScope.of(context).unfocus();
    ref.read(weatherProvider.notifier).fetchWeatherByCity(city);
  }

  Widget? _buildOfflineBanner(bool isOffline, DateTime? lastUpdated) {
    if (!isOffline || lastUpdated == null) return null;
    final diff = DateTime.now().difference(lastUpdated);
    final label = diff.inMinutes < 60
        ? '${diff.inMinutes} min ago'
        : '${diff.inHours}h ago';
    return Container(
      width: double.infinity,
      color: Colors.orange.shade700,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Row(
        children: [
          const Icon(Icons.wifi_off, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(
            'Offline — Last updated: $label',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final weatherDate = ref.watch(weatherProvider);
    final tempUnit = weatherDate.tempUnit;

    if (weatherDate.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (weatherDate.errorMessage != null) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF4A90E2), Color(0xFF1B3A6B)],
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_off,
                    size: 60,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    weatherDate.errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      foregroundColor: Colors.white,
                      side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.4)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: () =>
                        ref.read(weatherProvider.notifier).fetchWeather(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (weatherDate.currentWeather.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Weather data is empty')),
      );
    }

    final offlineBanner = _buildOfflineBanner(
      weatherDate.isOffline,
      weatherDate.lastUpdated,
    );

    return Scaffold(
      body: Container(
        // Glassmorphism gradient background — works offline
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4A90E2), Color(0xFF1B3A6B)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                children: [
                  // Offline banner pinned at top
                  if (offlineBanner != null) offlineBanner,

                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final availableHeight = constraints.maxHeight;
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 10,
                          ),
                          child: ListView(
                            children: [
                              // Header row
                              Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                children: [
                                  // Profile avatar — glass style, offline safe
                                  CircleAvatar(
                                    maxRadius: 30,
                                    backgroundColor:
                                        Colors.white.withValues(alpha: 0.2),
                                    child: const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Good Morning!',
                                        style: TextStyle(
                                          color: Colors.white
                                              .withValues(alpha: 0.7),
                                        ),
                                      ),
                                      Text(
                                        widget.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  // Notification bell — taps to settings
                                  CircleAvatar(
                                    maxRadius: 30,
                                    backgroundColor:
                                        Colors.white.withValues(alpha: 0.15),
                                    child: const Icon(
                                      Icons.notifications,
                                      size: 26,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              // Search box — glass style
                              Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.3),
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10),
                                child: TextField(
                                  controller: inputControler,
                                  onChanged: _onSearchChanged,
                                  style: const TextStyle(color: Colors.white),
                                  onSubmitted: (val) {
                                    if (val.isNotEmpty) _onSuggestionTap(val);
                                  },
                                  decoration: const InputDecoration(
                                    hintText: 'Search City',
                                    border: InputBorder.none,
                                    icon: Icon(Icons.search,
                                        color: Colors.white70),
                                  ),
                                ),
                              ),

                              // Suggestions dropdown
                              if (_showSuggestions)
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1C3A6A),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color:
                                          Colors.white.withValues(alpha: 0.2),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Colors.black.withValues(alpha: 0.3),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: _suggestions.length,
                                    itemBuilder: (context, index) => ListTile(
                                      leading: const Icon(
                                        Icons.location_on_outlined,
                                        size: 18,
                                        color: Colors.white70,
                                      ),
                                      title: Text(
                                        _suggestions[index],
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                      onTap: () =>
                                          _onSuggestionTap(_suggestions[index]),
                                    ),
                                  ),
                                ),

                              const SizedBox(height: 8),

                              // Location row
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on_outlined,
                                    color: Colors.white70,
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      weatherDate.currentWeather['Name'] ?? '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => ref
                                        .read(weatherProvider.notifier)
                                        .fetchWeather(),
                                    iconSize: 20,
                                    icon: const Icon(Icons.refresh,
                                        color: Colors.white70),
                                  ),
                                ],
                              ),

                              Text(
                                formatedDate,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                ),
                              ),

                              SizedBox(height: availableHeight * 0.02),

                              // Main weather card — keeps local asset background
                              SizedBox(
                                height: availableHeight * 0.25,
                                width: double.infinity,
                                child: Card(
                                  elevation: 10,
                                  shadowColor:
                                      Colors.black.withValues(alpha: 0.4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    side: BorderSide(
                                      color:
                                          Colors.white.withValues(alpha: 0.2),
                                    ),
                                  ),
                                  clipBehavior: Clip.hardEdge,
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: Image.asset(
                                          'assets/images/backgroundimage4.jpg',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Image.asset(
                                              'assets/images/image1.png',
                                              height: 100,
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              '${TempConverter.convert(weatherDate.currentWeather['Temp'] as double, tempUnit).toStringAsFixed(0)}${TempConverter.label(tempUnit)}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 55,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              'Feels like ${TempConverter.convert(weatherDate.currentWeather['FeelsLike'] as double, tempUnit).toStringAsFixed(0)}${TempConverter.label(tempUnit)}',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 10),

                              // Bottom glass card: hourly + weather detail
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.2),
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 2, vertical: 5),
                                child: Column(
                                  children: [
                                    HoursCardWidget(),
                                    const SizedBox(height: 10),
                                    WeatherDetail(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}