import '../../../../core/entities/cached.dart';
import '../../../../core/entities/coordinates.dart';
import '../../../../core/error/result.dart';
import '../entities/weather.dart';

abstract interface class WeatherRepository {
  Future<Result<Cached<Weather>>> getWeather(Coordinates coordinates);
}
