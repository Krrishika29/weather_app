# Weather App

Basic weather app built with Flutter for the internship assignment.

## Technology
- Flutter 3.x (Dart)

## Setup
1. Install Flutter and run `flutter doctor`.
2. In the project folder run `flutter create .` (generates android/ios folders).
3. Run `flutter pub get`.
4. Run `flutter run`.

## Features completed
- Search a city by name
- Current weather (temperature, condition, humidity, wind)
- 5-day forecast
- Loading indicator
- Empty state before first search

## Architecture / Libraries
- Everything is in `lib/main.dart`, using `setState`.
- Library: `http`

## Assumptions
- The first geocoding result is used when several cities match.

## Known limitations
- No offline support or caching
- Error handling is a generic message only
- Empty or invalid input is not handled specially
- Only some weather codes are mapped; others show "Unknown"
- No tests, no unit toggle, no dark mode
- Not tested on rotation or restart; rapid repeated searches are not handled
- No timeout on requests

## With more time
- Split the code into UI, logic, and data layers
- Add models, caching, better errors, and tests
