import 'package:flutter/material.dart';

// Yeh class SettingScreen ka entry point hai.
// StatefulWidget isliye hai kyunke yahan units change karne aur switches toggle karne se UI update hogi.
class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() {
    return _SettingScreenState();
  }
}

class _SettingScreenState extends State<SettingScreen> {
  // ExpansionTile ko programmatically close karne ke liye controller.
  // (Note: Make sure aapne 'expansible_tile' ya similar package add kiya ho agar yeh custom controller hai)
  ExpansibleController tilecontroler = ExpansibleController();

  // App ki state maintain karne ke liye variables
  bool isNotificationEnabled =
      false; // Notification switch ki halat (On/Off)
  bool isWeatherAleartEnabled =
      false; // Weather alert switch ki halat
  String selectedUnit = "Celsius (°C)"; // Default temperature unit

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Top bar setup
      appBar: AppBar(
        title: Text(
          'Settings',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors
            .transparent, // Glassy look dene ke liye transparent rakha hai
      ),
      body: SafeArea(
        // Column widgets ko vertically align karta hai
        child: Column(
          children: [
            // Temperature units select karne ke liye drop-down jaisa tile
            ExpansionTile(
              controller: tilecontroler,
              leading: const Icon(
                Icons.thermostat,
                color: Colors.blue,
              ), // Left side icon
              title: Text(
                'Units',
                style: Theme.of(context).textTheme.titleMedium!
                    .copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
              subtitle: Text(
                selectedUnit,
              ), // Filhal jo unit select hai wo show karega
              children: [
                // Celsius option
                ListTile(
                  title: const Text("Celsius (°C)"),
                  onTap: () {
                    setState(() {
                      selectedUnit = "Celsius (°C)";
                      tilecontroler
                          .collapse(); // Unit select hone ke baad tile ko band kar do
                    });
                  },
                ),
                // Fahrenheit option
                ListTile(
                  title: const Text("Fahrenheit (°F)"),
                  onTap: () {
                    setState(() {
                      selectedUnit = "Fahrenheit (°F)";
                      tilecontroler.collapse(); // Collapse logic
                    });
                  },
                ),
              ],
            ),

            // General Notifications toggle switch
            SwitchListTile(
              secondary: const Icon(
                Icons.notifications,
                color: Colors.amber,
              ),
              value: isNotificationEnabled,
              title: Text(
                'Notifications',
                style: Theme.of(context).textTheme.titleMedium!
                    .copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
              onChanged: (value) {
                // Switch press karne par state update
                setState(() {
                  isNotificationEnabled = value;
                });
              },
            ),

            // Critical Weather Alerts toggle switch
            SwitchListTile(
              secondary: const Icon(
                Icons.warning_amber,
                color: Colors.redAccent,
              ),
              value: isWeatherAleartEnabled,
              title: Text(
                'Weather Alerts',
                style: Theme.of(context).textTheme.titleMedium!
                    .copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
              onChanged: (value) {
                setState(() {
                  isWeatherAleartEnabled = value;
                });
              },
            ),

            // Locations manage karne ke liye tile (Under Construction lag raha hai)
            ExpansionTile(
              leading: const Icon(
                Icons.location_on_outlined,
                color: Colors.green,
              ),
              title: Text(
                'Manage Locations',
                style: Theme.of(context).textTheme.titleMedium!
                    .copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
              onExpansionChanged: (value) {
                // Click handle karne ke liye placeholder
              },
            ),

            const SizedBox(
              height: 60,
            ), // Thora gap dene ke liye takay button neche miley
            // Logout Button - User session end karne ke liye
            ElevatedButton(
              onPressed: () {
                // Yahan logout ka logic aayega (Clear SharedPreferences, etc.)
              },
              child: const Text('Log Out'),
            ),
          ],
        ),
      ),
    );
  }
}
