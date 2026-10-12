import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/entities/coordinates.dart';
import '../../../../core/error/result.dart';
import '../../../favorites/domain/favorites_repository.dart';
import '../../domain/entities/country.dart';
import '../../domain/entities/country_details.dart';
import '../../domain/repositories/countries_repository.dart';

enum InfoStatus { loading, loaded, failure }

class CountryDetailsState extends Equatable {
  const CountryDetailsState({
    this.infoStatus = InfoStatus.loading,
    this.details,
    this.errorMessage,
    this.isFavorite = false,
    this.pinnedPoint,
  });

  final InfoStatus infoStatus;
  final CountryDetails? details;
  final String? errorMessage;
  final bool isFavorite;
  final Coordinates? pinnedPoint;

  CountryDetailsState copyWith({
    InfoStatus? infoStatus,
    CountryDetails? details,
    String? errorMessage,
    bool? isFavorite,
    Coordinates? pinnedPoint,
  }) {
    return CountryDetailsState(
      infoStatus: infoStatus ?? this.infoStatus,
      details: details ?? this.details,
      errorMessage: errorMessage,
      isFavorite: isFavorite ?? this.isFavorite,
      pinnedPoint: pinnedPoint ?? this.pinnedPoint,
    );
  }

  @override
  List<Object?> get props => [
    infoStatus,
    details,
    errorMessage,
    isFavorite,
    pinnedPoint,
  ];
}

class CountryDetailsCubit extends Cubit<CountryDetailsState> {
  CountryDetailsCubit(this.country, this._countries, this._favorites)
    : super(
        CountryDetailsState(
          isFavorite: _favorites.favorites.contains(country.code),
          pinnedPoint: country.coordinates,
        ),
      );

  final Country country;
  final CountriesRepository _countries;
  final FavoritesRepository _favorites;

  Future<void> load() async {
    emit(state.copyWith(infoStatus: InfoStatus.loading));

    final result = await _countries.getCountryDetails(country.code);
    if (isClosed) return;

    switch (result) {
      case Success(:final value):
        emit(state.copyWith(infoStatus: InfoStatus.loaded, details: value));
      case Err(:final failure):
        emit(
          state.copyWith(
            infoStatus: InfoStatus.failure,
            errorMessage: failure.message,
          ),
        );
    }
  }

  Future<void> toggleFavorite() async {
    final isFavorite = await _favorites.toggle(country.code);
    if (!isClosed) emit(state.copyWith(isFavorite: isFavorite));
  }

  void pinTo(Coordinates point) => emit(state.copyWith(pinnedPoint: point));

  void resetPin() => pinTo(country.coordinates!);
}
