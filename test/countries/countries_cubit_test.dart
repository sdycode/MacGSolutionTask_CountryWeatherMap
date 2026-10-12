import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:country_weather_app/core/entities/cached.dart';
import 'package:country_weather_app/core/error/failure.dart';
import 'package:country_weather_app/core/error/result.dart';
import 'package:country_weather_app/features/countries/domain/entities/country.dart';
import 'package:country_weather_app/features/countries/domain/repositories/countries_repository.dart';
import 'package:country_weather_app/features/countries/domain/repositories/recent_search_repository.dart';
import 'package:country_weather_app/features/countries/domain/usecases/add_recent_search.dart';
import 'package:country_weather_app/features/countries/presentation/cubit/countries_cubit.dart';
import 'package:country_weather_app/features/countries/presentation/cubit/countries_state.dart';
import 'package:country_weather_app/features/favorites/domain/favorites_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockCountries extends Mock implements CountriesRepository {}

class _MockFavorites extends Mock implements FavoritesRepository {}

class _MockRecent extends Mock implements RecentSearchRepository {}

void main() {
  late _MockCountries countries;
  late _MockFavorites favorites;
  late _MockRecent recent;

  const india = Country(
    code: 'IN',
    name: 'India',
    capital: 'New Delhi',
    region: 'South Asia',
  );
  const japan = Country(
    code: 'JP',
    name: 'Japan',
    capital: 'Tokyo',
    region: 'East Asia',
  );

  CountriesCubit buildCubit() =>
      CountriesCubit(countries, favorites, recent, AddRecentSearch(recent));

  setUp(() {
    countries = _MockCountries();
    favorites = _MockFavorites();
    recent = _MockRecent();

    when(() => favorites.favorites).thenReturn({});
    when(() => favorites.changes).thenAnswer((_) => const Stream.empty());
    when(() => recent.getAll()).thenAnswer((_) async => []);
  });

  blocTest<CountriesCubit, CountriesState>(
    'loading then loaded',
    build: () {
      when(
        () => countries.getCountries(),
      ).thenAnswer((_) async => const Success(Cached([india, japan])));
      return buildCubit();
    },
    act: (cubit) => cubit.load(),
    expect: () => [
      const CountriesLoading(),
      const CountriesLoaded(countries: [india, japan]),
    ],
  );

  blocTest<CountriesCubit, CountriesState>(
    'loading then failure when the api fails',
    build: () {
      when(
        () => countries.getCountries(),
      ).thenAnswer((_) async => const Err(NetworkFailure()));
      return buildCubit();
    },
    act: (cubit) => cubit.load(),
    expect: () => [
      const CountriesLoading(),
      const CountriesFailure(
        'No internet connection. Please check your network.',
      ),
    ],
  );

  blocTest<CountriesCubit, CountriesState>(
    'loaded with an empty list stays empty',
    build: () {
      when(
        () => countries.getCountries(),
      ).thenAnswer((_) async => const Success(Cached(<Country>[])));
      return buildCubit();
    },
    act: (cubit) => cubit.load(),
    verify: (cubit) {
      expect((cubit.state as CountriesLoaded).countries, isEmpty);
    },
  );

  blocTest<CountriesCubit, CountriesState>(
    'search filters by name and can return no results',
    build: () {
      when(
        () => countries.getCountries(),
      ).thenAnswer((_) async => const Success(Cached([india, japan])));
      return buildCubit();
    },
    act: (cubit) async {
      await cubit.load();
      cubit.search('jap');
      cubit.search('xyz');
    },
    verify: (cubit) {
      final state = cubit.state as CountriesLoaded;
      expect(state.query, 'xyz');
      expect(state.visible, isEmpty);
    },
  );
}
