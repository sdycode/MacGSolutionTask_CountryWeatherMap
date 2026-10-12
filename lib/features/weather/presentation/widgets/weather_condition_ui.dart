import 'package:flutter/material.dart';

import '../../domain/entities/weather.dart';

extension WeatherConditionUi on WeatherCondition {
  String get label => switch (this) {
    WeatherCondition.clear => 'Clear sky',
    WeatherCondition.mainlyClear => 'Mainly clear',
    WeatherCondition.partlyCloudy => 'Partly cloudy',
    WeatherCondition.overcast => 'Overcast',
    WeatherCondition.fog => 'Fog',
    WeatherCondition.drizzle => 'Drizzle',
    WeatherCondition.rain => 'Rain',
    WeatherCondition.snow => 'Snow',
    WeatherCondition.thunderstorm => 'Thunderstorm',
    WeatherCondition.unknown => 'Unknown',
  };

  IconData get icon => switch (this) {
    WeatherCondition.clear => Icons.wb_sunny,
    WeatherCondition.mainlyClear => Icons.wb_sunny_outlined,
    WeatherCondition.partlyCloudy => Icons.wb_cloudy,
    WeatherCondition.overcast => Icons.cloud,
    WeatherCondition.fog => Icons.foggy,
    WeatherCondition.drizzle => Icons.grain,
    WeatherCondition.rain => Icons.water_drop,
    WeatherCondition.snow => Icons.ac_unit,
    WeatherCondition.thunderstorm => Icons.thunderstorm,
    WeatherCondition.unknown => Icons.help_outline,
  };
}
