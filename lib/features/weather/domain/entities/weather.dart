import 'package:equatable/equatable.dart';

enum WeatherCondition {
  clear,
  mainlyClear,
  partlyCloudy,
  overcast,
  fog,
  drizzle,
  rain,
  snow,
  thunderstorm,
  unknown,
}

class Weather extends Equatable {
  const Weather({
    this.temperature,
    this.humidity,
    this.windSpeed,
    required this.condition,
  });

  final double? temperature;
  final int? humidity;
  final double? windSpeed;
  final WeatherCondition condition;

  @override
  List<Object?> get props => [temperature, humidity, windSpeed, condition];
}
