<div align="center">

# 🌤️ Weather Application

> A Flutter weather app with live OpenWeatherMap data, 24-hour hourly forecast, 7-day weekly breakdown, and a glassmorphic UI.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.10-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Riverpod](https://img.shields.io/badge/State-Riverpod-blueviolet)](https://riverpod.dev)
[![API](https://img.shields.io/badge/API-OpenWeatherMap-orange)](https://openweathermap.org/api)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey)](https://flutter.dev)
[![Status](https://img.shields.io/badge/Status-🚧%20In%20Progress-yellow)]()
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

[Features](#-implemented-features) · [Planned](#-planned-features) · [Tech Stack](#️-tech-stack) · [Setup](#-setup) · [Structure](#️-project-structure) · [Contributing](#-contributing)

</div>

---

> ## 🚧 Work in Progress
>
> This project is **actively under development** and not yet feature-complete. Core weather functionality is working, but several planned features are still being built. Contributions and feedback are welcome!
>
> **Currently stable:** Live weather data · Hourly forecast · 7-day forecast · Glassmorphic UI
>
> **In progress:** Geolocation · Search · Dark mode · Unit converter · Caching · Backend

---

## 📖 Overview

**Weather Application** is a Flutter app that delivers real-time weather data using the **OpenWeatherMap One Call API 3.0**. It features a glassmorphic welcome screen, current temperature readings, a 24-hour horizontal forecast, and an expandable 7-day weekly view with full day/night detail breakdowns.

State is managed with **Riverpod**, and the API key is handled securely via `flutter_dotenv`.

---

## 📸 Screenshots

> 📸 Screenshots coming soon! Drop some in a `screenshots/` folder and update this section.

<!-- Once you have screenshots:
| Welcome | Home | Weekly Forecast | Settings |
|---------|------|-----------------|----------|
| ![Welcome](screenshots/welcome.png) | ![Home](screenshots/home.png) | ![Weekly](screenshots/weekly.png) | ![Settings](screenshots/settings.png) |
-->

---

## ✅ Implemented Features

These features are **built and working**:

- 🪟 **Glassmorphic Welcome Screen** — Frosted glass UI with a name input and blue gradient background
- 🌡️ **Live Current Weather** — Real-time temperature, feels-like, and weather condition from OpenWeatherMap
- ⏱️ **24-Hour Hourly Forecast** — Horizontally scrollable cards with dynamic day/night theming and OpenWeatherMap icons
- 📅 **7-Day Weekly Forecast** — Expandable cards per day with full detail (sunrise, sunset, humidity, UV index, moonrise, moonset)
- 🌅 **Weather Conditions Panel** — Humidity, UV index, sunrise/sunset, visibility, pressure — all with icons and units
- 🔄 **Manual Refresh** — One-tap weather data reload
- ⚙️ **Settings Screen** — Temperature unit toggle (Celsius/Fahrenheit), notifications switch, weather alerts toggle
- 📱 **Bottom Navigation** — Clean 3-tab navigation (Home, Weather, Settings)
- 🔐 **Secure API Key Management** — API key loaded from `.env` via `flutter_dotenv`

---

## 🔮 Planned Features

These are on the roadmap but **not yet implemented**:

- [ ] 📍 **Geolocation / GPS Auto-Detect** — Automatically resolve device GPS to a city name via reverse geocoding *(packages installed, integration in progress)*
- [ ] 🔍 **City Search** — Search and switch between any city
- [ ] 🌙 **Dark Mode** — Full dark theme support with theme toggle
- [ ] 🌡️ **Unit Converter** — In-app toggle between Celsius, Fahrenheit, and Kelvin
- [ ] 💾 **Response Caching** — Cache last-fetched weather data for offline/slow-network use
- [ ] 🔔 **Weather Alerts & Notifications** — Push notifications for severe weather alerts
- [ ] ☁️ **Backend Integration** — User accounts, saved/favorite locations stored in a backend database

---

## 🛠️ Tech Stack

| Package | Version | Purpose |
|---|---|---|
| Flutter | 3.x | UI Framework |
| Dart | ^3.10.4 | Programming Language |
| flutter_riverpod | ^3.2.1 | State management (StateNotifier) |
| riverpod | ^3.1.0 | Core Riverpod library |
| http | ^1.6.0 | OpenWeatherMap API calls |
| geolocator | ^14.0.2 | Device GPS coordinates *(integration in progress)* |
| geocoding | ^4.0.0 | Reverse geocoding (lat/lon → city name) *(integration in progress)* |
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

Create a `.env` file in the **root** of the project:

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

Contributions are welcome — especially for the planned features above!

1. **Fork** the repository
2. **Create** a branch: `git checkout -b feature/your-feature-name`
3. **Commit** your changes: `git commit -m 'feat: add your feature'`
4. **Push** to your branch: `git push origin feature/your-feature-name`
5. **Open a Pull Request**

---

## 📝 Changelog

### v1.0.0 — April 2026 *(In Progress)*
- 🚧 Project under active development
- ✅ Glassmorphic welcome screen with name input
- ✅ Live OpenWeatherMap current + hourly + 7-day data
- ✅ 24-hour horizontal forecast with day/night theming
- ✅ Expandable weekly forecast cards with full weather detail
- ✅ Settings screen (unit toggle, notification switches)
- ✅ Secure `.env`-based API key management with `flutter_dotenv`
- 🔜 Geolocation, search, dark mode, caching, backend — coming soon

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
  <sub>🚧 Work in Progress — Made with ❤️ using Flutter</sub>
</div>
