# MacGSolutionTask\_CountryWeatherMap










































<br />

---

# Country & Weather Explorer

A Flutter application built as part of the Flutter Developer Practical Assessment.

The app allows users to log in, explore countries, view country details, check current weather, and view the selected location on a map.

## Features

- Firebase Email/Password Authentication
- Country listing and search
- Country details
- Current weather information
- Map with selected country location
- Loading, empty and error states
- API timeout and network error handling
- Retry handling
- Favorites using SharedPreferences
- Logout

## Tech Stack

- Flutter / Dart
- Firebase Authentication
- REST Countries API
- Weather API
- Flutter Map / OpenStreetMap
- BLoC / Cubit
- GetIt
- HTTP
- Hive CE
- SharedPreferences
- Equatable
- Cached Network Image

## Architecture

```
Presentation
    ↓
BLoC / Cubit
    ↓
Repository
    ↓
Data Source
    ↓
API / Local Storage
```

Business logic is kept separate from UI widgets, with repositories handling data access.

## Error Handling

The app handles:

- Firebase authentication errors
- Network errors
- API failures
- Request timeouts
- Empty responses
- Missing/null data
- Weather API failures

Weather is loaded independently, so a weather failure does not block the country details.

## Local Storage

Favorites are stored locally using **SharedPreferences**.

No backend API is required for the favorites feature.

## Testing

The project uses:

- `flutter_test`
- `bloc_test`
- `mocktail`

for testing and mocking.

## Bonus

The optional backend API was not implemented. The core requirements were implemented using public APIs and local storage.

<br />

<br />

<br />
