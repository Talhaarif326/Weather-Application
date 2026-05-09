import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather/database/db_helper.dart';
import 'package:weather/main.dart';
import 'package:weather/providers/weather_provider.dart';
import 'package:weather/screens/welcome_screen.dart';

class SettingScreen extends ConsumerStatefulWidget {
  const SettingScreen({super.key});

  @override
  ConsumerState<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends ConsumerState<SettingScreen> {
  ExpansibleController tilecontroler = ExpansibleController();
  bool isNotificationEnabled = false;
  bool isWeatherAlertEnabled = false;
  List<Map<String, dynamic>> _savedLocations = [];

  @override
  void initState() {
    super.initState();
    _loadSavedLocations();
  }

  Future<void> _loadSavedLocations() async {
    final locations = await DbHelper.instance.getSavedLocations();
    setState(() => _savedLocations = locations);
  }

  Future<void> _deleteLocation(int id) async {
    await DbHelper.instance.deleteLocation(id);
    await _loadSavedLocations();
  }

  Future<void> _showWeatherNotification(
    String cityName,
    String temp,
  ) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'weather_channel',
          'Weather Updates',
          channelDescription: 'Daily weather updates',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        );
    await flutterLocalNotificationsPlugin.show(
      0,
      'Weather Update — $cityName',
      'Current temperature: $temp',
      const NotificationDetails(android: androidDetails),
    );
  }

  Future<void> _showAlertNotification(
    String alertTitle,
    String alertDesc,
  ) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'weather_alerts_channel',
          'Weather Alerts',
          channelDescription: 'Critical weather alerts',
          importance: Importance.high,
          priority: Priority.high,
        );
    await flutterLocalNotificationsPlugin.show(
      1,
      alertTitle,
      alertDesc,
      const NotificationDetails(android: androidDetails),
    );
  }

  // Clears everything and goes back to welcome screen
  Future<void> _logout() async {
    // Show confirmation dialog first
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1C3A6A),
        title: const Text(
          'Log Out',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'This will clear all your data including saved name, locations and cached weather. Are you sure?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Log Out',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // Clear DB
    await DbHelper.instance.clearAll();

    // Reset provider state
    await ref.read(weatherProvider.notifier).clearData();

    // Revoke location permission info (can't revoke programmatically,
    // but we reset the app state fully)
    await flutterLocalNotificationsPlugin.cancelAll();

    if (!mounted) return;

    // Navigate to welcome screen, remove all previous routes
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (route) => false,
    );
  }

  BoxDecoration _glassTile() => BoxDecoration(
    color: Colors.white.withValues(alpha: 0.08),
    border: Border(
      bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final weatherModel = ref.watch(weatherProvider);
    final tempUnit = weatherModel.tempUnit;
    final selectedUnit = tempUnit == 'C'
        ? 'Celsius (°C)'
        : 'Fahrenheit (°F)';
    final alerts = weatherModel.alerts;
    final cityName = weatherModel.currentWeather['Name'] ?? 'Unknown';
    final temp = weatherModel.currentWeather['Temp'];
    final tempDisplay = temp != null
        ? '${((temp as double) - 273.15).toStringAsFixed(0)}°$tempUnit'
        : '--';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4A90E2), Color(0xFF1B3A6B)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
                child: Text(
                  'Settings',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              Expanded(
                child: ListView(
                  children: [
                    // Temperature Unit
                    Container(
                      decoration: _glassTile(),
                      child: Theme(
                        data: Theme.of(
                          context,
                        ).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          controller: tilecontroler,
                          leading: const Icon(
                            Icons.thermostat,
                            color: Colors.orange,
                          ),
                          iconColor: Colors.white70,
                          collapsedIconColor: Colors.white54,
                          title: const Text(
                            'Temperature Unit',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            selectedUnit,
                            style: TextStyle(
                              color: Colors.white.withValues(
                                alpha: 0.65,
                              ),
                              fontSize: 12,
                            ),
                          ),
                          children: [
                            _unitTile(
                              label: 'Celsius (°C)',
                              selected: tempUnit == 'C',
                              onTap: () {
                                if (tempUnit != 'C') {
                                  ref
                                      .read(weatherProvider.notifier)
                                      .toggleUnit();
                                }
                                tilecontroler.collapse();
                              },
                            ),
                            _unitTile(
                              label: 'Fahrenheit (°F)',
                              selected: tempUnit == 'F',
                              onTap: () {
                                if (tempUnit != 'F') {
                                  ref
                                      .read(weatherProvider.notifier)
                                      .toggleUnit();
                                }
                                tilecontroler.collapse();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Notifications
                    Container(
                      decoration: _glassTile(),
                      child: SwitchListTile(
                        secondary: const Icon(
                          Icons.notifications,
                          color: Colors.amber,
                        ),
                        value: isNotificationEnabled,
                        title: const Text(
                          'Notifications',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          isNotificationEnabled
                              ? 'Weather updates are on'
                              : 'Weather updates are off',
                          style: TextStyle(
                            color: Colors.white.withValues(
                              alpha: 0.6,
                            ),
                            fontSize: 12,
                          ),
                        ),
                        activeColor: const Color(0xFF4A90E2),
                        inactiveTrackColor: Colors.white.withValues(
                          alpha: 0.2,
                        ),
                        onChanged: (value) async {
                          setState(
                            () => isNotificationEnabled = value,
                          );
                          if (value) {
                            await _showWeatherNotification(
                              cityName,
                              tempDisplay,
                            );
                          } else {
                            await flutterLocalNotificationsPlugin
                                .cancel(0);
                          }
                        },
                      ),
                    ),

                    // Weather Alerts
                    Container(
                      decoration: _glassTile(),
                      child: SwitchListTile(
                        secondary: const Icon(
                          Icons.warning_amber,
                          color: Colors.redAccent,
                        ),
                        value: isWeatherAlertEnabled,
                        title: const Text(
                          'Weather Alerts',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          isWeatherAlertEnabled
                              ? 'Critical alerts are on'
                              : 'Critical alerts are off',
                          style: TextStyle(
                            color: Colors.white.withValues(
                              alpha: 0.6,
                            ),
                            fontSize: 12,
                          ),
                        ),
                        activeColor: const Color(0xFF4A90E2),
                        inactiveTrackColor: Colors.white.withValues(
                          alpha: 0.2,
                        ),
                        onChanged: (value) async {
                          setState(
                            () => isWeatherAlertEnabled = value,
                          );
                          if (value && alerts.isNotEmpty) {
                            final alert = alerts.first;
                            await _showAlertNotification(
                              alert['event'] ?? 'Weather Alert',
                              alert['description'] ??
                                  'Check current conditions.',
                            );
                          } else if (value && alerts.isEmpty) {
                            if (mounted) {
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(
                                SnackBar(
                                  backgroundColor: Colors.white
                                      .withValues(alpha: 0.15),
                                  content: const Text(
                                    'No active weather alerts right now.',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              );
                            }
                          } else {
                            await flutterLocalNotificationsPlugin
                                .cancel(1);
                          }
                        },
                      ),
                    ),

                    // Active Alerts
                    Container(
                      decoration: _glassTile(),
                      child: Theme(
                        data: Theme.of(
                          context,
                        ).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          leading: Icon(
                            Icons.cloud_outlined,
                            color: Colors.lightBlue.shade300,
                          ),
                          iconColor: Colors.white70,
                          collapsedIconColor: Colors.white54,
                          title: const Text(
                            'Active Weather Alerts',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            alerts.isEmpty
                                ? 'No active alerts'
                                : '${alerts.length} alert${alerts.length > 1 ? 's' : ''} active',
                            style: TextStyle(
                              fontSize: 12,
                              color: alerts.isEmpty
                                  ? Colors.white.withValues(
                                      alpha: 0.5,
                                    )
                                  : Colors.redAccent.shade100,
                            ),
                          ),
                          children: alerts.isEmpty
                              ? [
                                  ListTile(
                                    leading: const Icon(
                                      Icons.check_circle_outline,
                                      color: Colors.greenAccent,
                                    ),
                                    title: const Text(
                                      'No active weather alerts',
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    subtitle: Text(
                                      'All clear in your area',
                                      style: TextStyle(
                                        color: Colors.white
                                            .withValues(alpha: 0.55),
                                      ),
                                    ),
                                  ),
                                ]
                              : alerts.map<Widget>((alert) {
                                  return ListTile(
                                    leading: const Icon(
                                      Icons.warning_amber,
                                      color: Colors.orange,
                                    ),
                                    title: Text(
                                      alert['event'] ?? 'Alert',
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    subtitle: Text(
                                      alert['description'] ?? '',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white
                                            .withValues(alpha: 0.6),
                                      ),
                                    ),
                                    trailing: const Icon(
                                      Icons.chevron_right,
                                      color: Colors.white54,
                                    ),
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          backgroundColor:
                                              const Color(0xFF1C3A6A),
                                          title: Text(
                                            alert['event'] ?? 'Alert',
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          content: SingleChildScrollView(
                                            child: Text(
                                              alert['description'] ??
                                                  '',
                                              style: TextStyle(
                                                color: Colors.white
                                                    .withValues(
                                                      alpha: 0.85,
                                                    ),
                                              ),
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(
                                                    context,
                                                  ),
                                              child: const Text(
                                                'Close',
                                                style: TextStyle(
                                                  color: Color(
                                                    0xFF4A90E2,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                }).toList(),
                        ),
                      ),
                    ),

                    // Manage Locations
                    Container(
                      decoration: _glassTile(),
                      child: Theme(
                        data: Theme.of(
                          context,
                        ).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          onExpansionChanged: (expanded) {
                            if (expanded) _loadSavedLocations();
                          },
                          leading: const Icon(
                            Icons.location_on_outlined,
                            color: Colors.greenAccent,
                          ),
                          iconColor: Colors.white70,
                          collapsedIconColor: Colors.white54,
                          title: const Text(
                            'Manage Locations',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            _savedLocations.isEmpty
                                ? 'No saved locations'
                                : '${_savedLocations.length} location${_savedLocations.length > 1 ? 's' : ''} saved',
                            style: TextStyle(
                              color: Colors.white.withValues(
                                alpha: 0.6,
                              ),
                              fontSize: 12,
                            ),
                          ),
                          children: [
                            if (_savedLocations.isEmpty)
                              ListTile(
                                leading: const Icon(
                                  Icons.add_location_alt,
                                  color: Colors.greenAccent,
                                ),
                                title: const Text(
                                  'No saved locations yet',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                subtitle: Text(
                                  'Search a city on Home screen to save it',
                                  style: TextStyle(
                                    color: Colors.white.withValues(
                                      alpha: 0.55,
                                    ),
                                    fontSize: 12,
                                  ),
                                ),
                              )
                            else
                              ..._savedLocations.map((loc) {
                                return ListTile(
                                  leading: const Icon(
                                    Icons.location_on,
                                    color: Colors.greenAccent,
                                  ),
                                  title: Text(
                                    loc['city_name'] as String,
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Lat: ${(loc['lat'] as double).toStringAsFixed(2)}, Lon: ${(loc['lon'] as double).toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.55,
                                      ),
                                      fontSize: 11,
                                    ),
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.redAccent,
                                      size: 20,
                                    ),
                                    onPressed: () => _deleteLocation(
                                      loc['id'] as int,
                                    ),
                                  ),
                                  onTap: () {
                                    // Load weather for this saved location
                                    ref
                                        .read(
                                          weatherProvider.notifier,
                                        )
                                        .fetchWeatherByLocationId(
                                          loc['id'] as int,
                                          loc['city_name'] as String,
                                          loc['lat'] as double,
                                          loc['lon'] as double,
                                        );
                                    ScaffoldMessenger.of(
                                      context,
                                    ).showSnackBar(
                                      SnackBar(
                                        backgroundColor: Colors.white
                                            .withValues(alpha: 0.15),
                                        content: Text(
                                          'Loading ${loc['city_name']}...',
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Log Out
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                      ),
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent.shade100,
                          side: BorderSide(
                            color: Colors.redAccent.withValues(
                              alpha: 0.5,
                            ),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                        ),
                        onPressed: _logout,
                        icon: const Icon(Icons.logout),
                        label: const Text('Log Out'),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _unitTile({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      title: Text(
        label,
        style: TextStyle(
          color: selected ? const Color(0xFF4A90E2) : Colors.white,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: selected
          ? const Icon(
              Icons.check,
              color: Color(0xFF4A90E2),
              size: 18,
            )
          : null,
    );
  }
}
