import '../../domain/entities/weather.dart';
import '../dtos/weather_dto.dart';

extension WeatherDtoMapper on WeatherDto {
  Weather toEntity() => Weather(
    temperature: temperature?.toDouble(),
    humidity: humidity?.toInt(),
    windSpeed: windSpeed?.toDouble(),
    condition: _conditionFor(weatherCode?.toInt()),
  );
}

// https://open-meteo.com/en/docs - WMO weather codes
WeatherCondition _conditionFor(int? code) {
  return switch (code) {
    0 => WeatherCondition.clear,
    1 => WeatherCondition.mainlyClear,
    2 => WeatherCondition.partlyCloudy,
    3 => WeatherCondition.overcast,
    45 || 48 => WeatherCondition.fog,
    51 || 53 || 55 || 56 || 57 => WeatherCondition.drizzle,
    61 || 63 || 65 || 66 || 67 || 80 || 81 || 82 => WeatherCondition.rain,
    71 || 73 || 75 || 77 || 85 || 86 => WeatherCondition.snow,
    95 || 96 || 99 => WeatherCondition.thunderstorm,
    _ => WeatherCondition.unknown,
  };
}
