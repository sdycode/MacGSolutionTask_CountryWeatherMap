import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:country_weather_app/core/cache/cache_store.dart';
import 'package:country_weather_app/core/error/failure.dart';
import 'package:country_weather_app/core/error/result.dart';
import 'package:country_weather_app/features/countries/data/datasources/countries_remote_data_source.dart';
import 'package:country_weather_app/features/countries/data/dtos/country_dto.dart';
import 'package:country_weather_app/features/countries/data/repositories/countries_repository_impl.dart';
import 'package:mocktail/mocktail.dart';

class _MockRemote extends Mock implements CountriesRemoteDataSource {}

void main() {
  late _MockRemote remote;
  late CacheStore cache;
  late CountriesRepositoryImpl repository;

  const dtos = [
    CountryDto(iso2Code: 'IN', name: 'India', region: 'South Asia'),
  ];

  Future<void> saveCache(DateTime savedAt) => cache.write(
    CountriesRepositoryImpl.countriesKey,
    [for (final dto in dtos) dto.toJson()],
    savedAt: savedAt,
  );

  setUp(() async {
    remote = _MockRemote();
    final box = await Hive.openBox(
      'test_${DateTime.now().microsecondsSinceEpoch}',
      bytes: Uint8List(0),
    );
    cache = CacheStore(box);
    repository = CountriesRepositoryImpl(remote, cache);
  });

  test('fresh cache is used without calling the api', () async {
    await saveCache(DateTime.now());

    final result = await repository.getCountries();

    expect(result, isA<Success>());
    verifyNever(() => remote.fetchCountries());
  });

  test('old cache is refreshed from the api', () async {
    await saveCache(DateTime.now().subtract(const Duration(days: 2)));
    when(() => remote.fetchCountries()).thenAnswer((_) async => dtos);

    final result = await repository.getCountries();

    expect((result as Success).value.isOutdated, isFalse);
    verify(() => remote.fetchCountries()).called(1);
  });

  test('falls back to old cache when the api fails', () async {
    await saveCache(DateTime.now().subtract(const Duration(days: 2)));
    when(() => remote.fetchCountries()).thenThrow(const NetworkFailure());

    final result = await repository.getCountries();

    final cached = (result as Success).value;
    expect(cached.isOutdated, isTrue);
    expect(cached.data.single.name, 'India');
  });

  test('returns a failure when the api fails and there is no cache', () async {
    when(() => remote.fetchCountries()).thenThrow(const TimeoutFailure());

    final result = await repository.getCountries();

    expect((result as Err).failure, const TimeoutFailure());
  });
}
