import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:country_weather_app/core/entities/cached.dart';
import 'package:country_weather_app/core/entities/coordinates.dart';
import 'package:country_weather_app/core/error/failure.dart';
import 'package:country_weather_app/core/error/result.dart';
import 'package:country_weather_app/features/weather/domain/entities/weather.dart';
import 'package:country_weather_app/features/weather/domain/repositories/weather_repository.dart';
import 'package:country_weather_app/features/weather/presentation/cubit/weather_cubit.dart';
import 'package:mocktail/mocktail.dart';

class _MockWeatherRepository extends Mock implements WeatherRepository {}

void main() {
  late _MockWeatherRepository repository;

  const point = Coordinates(28.63, 77.22);
  const weather = Weather(
    temperature: 27.9,
    humidity: 67,
    windSpeed: 8.9,
    condition: WeatherCondition.mainlyClear,
  );
  final savedAt = DateTime(2026, 10, 10);

  setUpAll(() => registerFallbackValue(point));
  setUp(() => repository = _MockWeatherRepository());

  blocTest<WeatherCubit, WeatherState>(
    'loading then loaded',
    build: () {
      when(
        () => repository.getWeather(any()),
      ).thenAnswer((_) async => Success(Cached(weather, savedAt: savedAt)));
      return WeatherCubit(repository);
    },
    act: (cubit) => cubit.load(point),
    expect: () => [
      const WeatherState(status: WeatherStatus.loading),
      WeatherState(
        status: WeatherStatus.loaded,
        weather: weather,
        updatedAt: savedAt,
      ),
    ],
  );

  blocTest<WeatherCubit, WeatherState>(
    'loading then failure',
    build: () {
      when(
        () => repository.getWeather(any()),
      ).thenAnswer((_) async => const Err(TimeoutFailure()));
      return WeatherCubit(repository);
    },
    act: (cubit) => cubit.load(point),
    expect: () => [
      const WeatherState(status: WeatherStatus.loading),
      const WeatherState(
        status: WeatherStatus.failure,
        errorMessage: 'Request timed out. Please try again.',
      ),
    ],
  );
}
