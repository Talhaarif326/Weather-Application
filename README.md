<div align="center">

# 🌤️ Weather App

> A Flutter weather app with a glassmorphic welcome screen, live OpenWeatherMap data, 24-hour hourly forecast, and a 7-day weekly breakdown.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.10-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Riverpod](https://img.shields.io/badge/State-Riverpod-blueviolet)](https://riverpod.dev)
[![API](https://img.shields.io/badge/API-OpenWeatherMap-orange)](https://openweathermap.org/api)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

[Features](#-features) · [Tech Stack](#️-tech-stack) · [Setup](#-setup) · [Structure](#️-project-structure) · [Contributing](#-contributing)

</div>

---

## 📖 Overview

**Weather App** is a Flutter application that delivers real-time weather data for your current location. It opens with a glassmorphic welcome screen where you enter your name, then drops you into a full weather dashboard — current temperature, feels-like, 24-hour hourly forecast, and a 7-day weekly view with expandable day/night details.

Data is pulled from the **OpenWeatherMap One Call API 3.0**, with reverse geocoding via the `geocoding` package to automatically resolve your GPS coordinates into a readable city name.

**Built with:** Flutter · Riverpod · OpenWeatherMap API · Geolocator · Geocoding

---

## 📸 Screenshots

> 📸 Screenshots coming soon! Drop some in a `screenshots/` folder and update this section.

<!-- Once you have screenshots:
| Welcome | Home | Weekly Forecast | Settings |
|---------|------|-----------------|----------|
| ![Welcome](screenshots/welcome.png) | ![Home](screenshots/home.png) | ![Weekly](screenshots/weekly.png) | ![Settings](screenshots/settings.png) |
-->

---

## ✨ Features

- 🪟 **Glassmorphic Welcome Screen** — Frosted glass UI with a name input and blue gradient background
- 🌡️ **Live Temperature** — Current temp + feels-like, converted from Kelvin to Celsius
- 📍 **Auto Location Detection** — GPS coordinates resolved to city name via reverse geocoding
- ⏱️ **24-Hour Hourly Forecast** — Horizontal scrollable cards with dynamic day/night theming and OpenWeatherMap icons
- 📅 **7-Day Weekly Forecast** — Expandable cards with per-day detail (sunrise, sunset, humidity, UV index, moonrise, moonset)
- 🌅 **Weather Conditions Panel** — Humidity, UV index, sunrise/sunset, visibility, and pressure — all with icons and units
- 🔄 **Manual Refresh** — One-tap weather data reload
- ⚙️ **Settings Screen** — Temperature unit toggle (Celsius/Fahrenheit), notifications switch, weather alerts toggle
- 📱 **Bottom Navigation** — Clean 3-tab navigation (Home, Weather, Settings)

---

## 🛠️ Tech Stack

| Package | Version | Purpose |
|---|---|---|
| Flutter | 3.x | UI Framework |
| Dart | ^3.10.4 | Programming Language |
| flutter_riverpod | ^3.2.1 | State management (StateNotifier) |
| riverpod | ^3.1.0 | Core Riverpod library |
| geolocator | ^14.0.2 | Device GPS coordinates |
| geocoding | ^4.0.0 | Reverse geocoding (lat/lon → city name) |
| http | ^1.6.0 | OpenWeatherMap API calls |
| intl | ^0.20.2 | Date & time formatting |
| flutter_dotenv | ^6.0.0 | API key management via `.env` |
| cupertino_icons | ^1.0.8 | iOS-style icons |

> **Weather data:** [OpenWeatherMap One Call API 3.0](https://openweathermap.org/api/one-call-3) — current, hourly (48hr), and daily (7-day) forecasts.

---

## 🚀 Setup

### Prerequisites

- Flutter SDK `>= 3.x` — [Install Flutter](https://docs.flutter.dev/get-started/install)
- Android Studio / VS Code with Flutter & Dart extensions
- A free [OpenWeatherMap API key](https://home.openweathermap.org/users/sign_up) (One Call API 3.0 access required)

### Clone & Run

```bash
# Clone the repo
git clone https://github.com/Talhaarif326/Weather-Application.git

# Navigate into the project
cd Weather-Application

# Install dependencies
flutter pub get
```

### Environment Setup

Create a `.env` file in the root of the project:

```
apiKey=YOUR_OPENWEATHERMAP_API_KEY_HERE
```

> ⚠️ Never commit your `.env` file — it's already covered by `.gitignore`.

```bash
# Run the app
flutter run
```

### Build for Release

```bash
# Android APK
flutter build apk --release

# iOS (macOS only)
flutter build ios --release
```

---

## 🏗️ Project Structure

```
lib/
├── main.dart                              # App entry point, theme, Riverpod ProviderScope
├── models/
│   └── weather_model.dart                 # Immutable WeatherModel with copyWith pattern
├── providers/
│   ├── weather_provider.dart              # StateNotifier — fetches & manages weather state
│   └── icons_colors_provider.dart         # Maps weather keys to icons, colors & units
├── services/
│   └── api_call.dart                      # OpenWeatherMap API service class
├── screens/
│   ├── welcome_screen.dart                # Glassmorphic name input + entry screen
│   ├── main_screen.dart                   # Bottom navigation controller (3 tabs)
│   ├── home_screen.dart                   # Current weather + hourly forecast + details
│   ├── weather_screen.dart                # 7-day weekly forecast with expandable cards
│   └── setting_screen.dart                # Unit toggle, notifications, weather alerts
├── widgets/
│   ├── hours_card_widget.dart             # 24-hr horizontal scrollable forecast cards
│   ├── today_weather_detail_widget.dart   # Humidity, UV, sunrise/sunset detail list
│   ├── weekly_weather_card_widget.dart    # Individual stat card for weekly detail grid
│   └── ten_days_weather_detail_widget.dart# Day/Night grid layout for expanded weekly card
└── data/
    ├── dummydata.dart                     # Static fallback/mock weather data
    └── hourly_data_genrator.dart          # 7-day data generator with condition mapping
```

---

## 🤝 Contributing

Contributions are welcome!

1. **Fork** the repository
2. **Create** a branch: `git checkout -b feature/your-feature-name`
3. **Commit** your changes: `git commit -m 'feat: add your feature'`
4. **Push** to your branch: `git push origin feature/your-feature-name`
5. **Open a Pull Request**

---

## 📝 Changelog

### v1.0.0 — April 2026
- ✨ Initial release
- 🪟 Glassmorphic welcome screen with name input
- 🌡️ Live OpenWeatherMap current + hourly + weekly data
- 📍 GPS reverse geocoding for automatic city detection
- ⚙️ Settings screen with unit toggle and notification switches

---

## 📄 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

## 🙌 Credits

- Built by [Talhaarif326](https://github.com/Talhaarif326)
- Weather data by [OpenWeatherMap](https://openweathermap.org/)
- Built with [Flutter](https://flutter.dev) & [Riverpod](https://riverpod.dev)

---

<div align="center">
  <sub>Made with ❤️ using Flutter</sub>
</div>
