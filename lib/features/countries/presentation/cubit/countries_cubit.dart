import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/result.dart';
import '../../../favorites/domain/favorites_repository.dart';
import '../../domain/entities/country.dart';
import '../../domain/repositories/countries_repository.dart';
import '../../domain/repositories/recent_search_repository.dart';
import '../../domain/usecases/add_recent_search.dart';
import 'countries_state.dart';

class CountriesCubit extends Cubit<CountriesState> {
  CountriesCubit(
    this._countries,
    this._favorites,
    this._recentSearches,
    this._addRecentSearch,
  ) : super(const CountriesLoading()) {
    _favoritesSubscription = _favorites.changes.listen((codes) {
      final current = state;
      if (current is CountriesLoaded) {
        emit(current.copyWith(favoriteCodes: codes));
      }
    });
  }

  final CountriesRepository _countries;
  final FavoritesRepository _favorites;
  final RecentSearchRepository _recentSearches;
  final AddRecentSearch _addRecentSearch;

  StreamSubscription<Set<String>>? _favoritesSubscription;

  Future<void> load() async {
    final previous = state is CountriesLoaded ? state as CountriesLoaded : null;
    emit(const CountriesLoading());

    final recent = await _recentSearches.getAll();
    final result = await _countries.getCountries();

    if (isClosed) return;

    switch (result) {
      case Success(:final value):
        emit(
          CountriesLoaded(
            countries: value.data,
            favoriteCodes: _favorites.favorites,
            recentSearches: recent,
            query: previous?.query ?? '',
            showFavoritesOnly: previous?.showFavoritesOnly ?? false,
            offlineSavedAt: value.isOutdated ? value.savedAt : null,
          ),
        );
      case Err(:final failure):
        emit(CountriesFailure(failure.message));
    }
  }

  void search(String query) {
    final current = state;
    if (current is CountriesLoaded) emit(current.copyWith(query: query));
  }

  void toggleFavoritesOnly() {
    final current = state;
    if (current is CountriesLoaded) {
      emit(current.copyWith(showFavoritesOnly: !current.showFavoritesOnly));
    }
  }

  Future<void> openCountry(Country country) async {
    final current = state;
    if (current is! CountriesLoaded || current.query.trim().isEmpty) return;

    final updated = await _addRecentSearch(country.name);
    if (isClosed) return;

    final latest = state;
    if (latest is CountriesLoaded) {
      emit(latest.copyWith(recentSearches: updated));
    }
  }

  Future<void> clearRecentSearches() async {
    await _recentSearches.clear();
    if (isClosed) return;

    final current = state;
    if (current is CountriesLoaded) {
      emit(current.copyWith(recentSearches: const []));
    }
  }

  @override
  Future<void> close() {
    _favoritesSubscription?.cancel();
    return super.close();
  }
}
