import 'package:equatable/equatable.dart';

import '../../domain/entities/country.dart';

sealed class CountriesState extends Equatable {
  const CountriesState();

  @override
  List<Object?> get props => [];
}

class CountriesLoading extends CountriesState {
  const CountriesLoading();
}

class CountriesFailure extends CountriesState {
  const CountriesFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class CountriesLoaded extends CountriesState {
  const CountriesLoaded({
    required this.countries,
    this.favoriteCodes = const {},
    this.recentSearches = const [],
    this.query = '',
    this.showFavoritesOnly = false,
    this.offlineSavedAt,
  });

  final List<Country> countries;
  final Set<String> favoriteCodes;
  final List<String> recentSearches;
  final String query;
  final bool showFavoritesOnly;
  final DateTime? offlineSavedAt;

  List<Country> get visible {
    final text = query.trim().toLowerCase();

    return countries.where((country) {
      if (showFavoritesOnly && !favoriteCodes.contains(country.code)) {
        return false;
      }
      if (text.isEmpty) return true;
      return country.name.toLowerCase().contains(text);
    }).toList();
  }

  CountriesLoaded copyWith({
    Set<String>? favoriteCodes,
    List<String>? recentSearches,
    String? query,
    bool? showFavoritesOnly,
  }) {
    return CountriesLoaded(
      countries: countries,
      favoriteCodes: favoriteCodes ?? this.favoriteCodes,
      recentSearches: recentSearches ?? this.recentSearches,
      query: query ?? this.query,
      showFavoritesOnly: showFavoritesOnly ?? this.showFavoritesOnly,
      offlineSavedAt: offlineSavedAt,
    );
  }

  @override
  List<Object?> get props => [
    countries,
    favoriteCodes,
    recentSearches,
    query,
    showFavoritesOnly,
    offlineSavedAt,
  ];
}
