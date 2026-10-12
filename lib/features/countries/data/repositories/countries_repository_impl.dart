import '../../../../core/cache/cache_store.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/entities/cached.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/country.dart';
import '../../domain/entities/country_details.dart';
import '../../domain/repositories/countries_repository.dart';
import '../datasources/countries_remote_data_source.dart';
import '../dtos/country_dto.dart';
import '../mappers/country_mapper.dart';

class CountriesRepositoryImpl implements CountriesRepository {
  CountriesRepositoryImpl(this._remote, this._cache);

  static const countriesKey = 'countries';

  final CountriesRemoteDataSource _remote;
  final CacheStore _cache;

  @override
  Future<Result<Cached<List<Country>>>> getCountries() async {
    final saved = _readSavedCountries();

    if (saved != null &&
        DateTime.now().difference(saved.savedAt) <
            ApiConfig.countriesCacheAge) {
      return Success(Cached(saved.countries, savedAt: saved.savedAt));
    }

    try {
      final dtos = await _remote.fetchCountries();
      await _cache.write(countriesKey, [for (final dto in dtos) dto.toJson()]);

      return Success(Cached(mapCountries(dtos), savedAt: DateTime.now()));
    } on Failure catch (failure) {
      if (saved != null) {
        return Success(
          Cached(saved.countries, savedAt: saved.savedAt, isOutdated: true),
        );
      }
      return Err(failure);
    }
  }

  @override
  Future<Result<CountryDetails>> getCountryDetails(String code) async {
    final key = 'country_info_$code';
    final entry = _cache.read(key);
    final saved = entry == null ? null : _detailsFromJson(entry.data);

    if (entry != null &&
        saved != null &&
        entry.isYoungerThan(ApiConfig.countryInfoCacheAge)) {
      return Success(saved);
    }

    try {
      final results = await Future.wait([
        _remote.fetchPopulation(code),
        _remote.fetchCurrency(code),
      ]);

      final details = CountryDetails(
        population: results[0] as int?,
        currency: results[1] as String?,
      );
      await _cache.write(key, {
        'population': details.population,
        'currency': details.currency,
      });

      return Success(details);
    } on Failure catch (failure) {
      if (saved != null) return Success(saved);
      return Err(failure);
    }
  }

  ({List<Country> countries, DateTime savedAt})? _readSavedCountries() {
    final entry = _cache.read(countriesKey);
    if (entry == null || entry.data is! List) return null;

    try {
      final dtos = (entry.data as List).map(
        (item) => CountryDto.fromJson(Map<String, dynamic>.from(item as Map)),
      );
      return (countries: mapCountries(dtos), savedAt: entry.savedAt);
    } catch (_) {
      return null;
    }
  }

  CountryDetails? _detailsFromJson(dynamic data) {
    if (data is! Map) return null;
    return CountryDetails(
      population: data['population'] as int?,
      currency: data['currency'] as String?,
    );
  }
}
