class WeatherDto {
  const WeatherDto({
    this.temperature,
    this.humidity,
    this.windSpeed,
    this.weatherCode,
  });

  factory WeatherDto.fromJson(Map<String, dynamic> json) => WeatherDto(
    temperature: json['temperature_2m'] as num?,
    humidity: json['relative_humidity_2m'] as num?,
    windSpeed: json['wind_speed_10m'] as num?,
    weatherCode: json['weather_code'] as num?,
  );

  final num? temperature;
  final num? humidity;
  final num? windSpeed;
  final num? weatherCode;

  Map<String, dynamic> toJson() => {
    'temperature_2m': temperature,
    'relative_humidity_2m': humidity,
    'wind_speed_10m': windSpeed,
    'weather_code': weatherCode,
  };
}
