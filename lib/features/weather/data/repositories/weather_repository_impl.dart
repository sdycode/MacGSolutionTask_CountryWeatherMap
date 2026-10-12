import '../../../../core/cache/cache_store.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/entities/cached.dart';
import '../../../../core/entities/coordinates.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/weather.dart';
import '../../domain/repositories/weather_repository.dart';
import '../datasources/weather_remote_data_source.dart';
import '../dtos/weather_dto.dart';
import '../mappers/weather_mapper.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  WeatherRepositoryImpl(this._remote, this._cache);

  static const keyPrefix = 'weather_';

  final WeatherRemoteDataSource _remote;
  final CacheStore _cache;

  @override
  Future<Result<Cached<Weather>>> getWeather(Coordinates coordinates) async {
    // 2 decimals is roughly 1 km, so nearby taps share one cache entry
    final latitude = coordinates.latitude.toStringAsFixed(2);
    final longitude = coordinates.longitude.toStringAsFixed(2);
    final key = '$keyPrefix${latitude}_$longitude';

    final entry = _cache.read(key);
    final saved = entry == null ? null : _readSaved(entry.data);

    if (entry != null &&
        saved != null &&
        entry.isYoungerThan(ApiConfig.weatherCacheAge)) {
      return Success(Cached(saved, savedAt: entry.savedAt));
    }

    try {
      final dto = await _remote.fetchCurrent(
        double.parse(latitude),
        double.parse(longitude),
      );
      await _cache.write(key, dto.toJson());

      return Success(Cached(dto.toEntity(), savedAt: DateTime.now()));
    } on Failure catch (failure) {
      if (entry != null && saved != null) {
        return Success(Cached(saved, savedAt: entry.savedAt, isOutdated: true));
      }
      return Err(failure);
    }
  }

  Weather? _readSaved(dynamic data) {
    if (data is! Map) return null;
    try {
      return WeatherDto.fromJson(Map<String, dynamic>.from(data)).toEntity();
    } catch (_) {
      return null;
    }
  }
}
