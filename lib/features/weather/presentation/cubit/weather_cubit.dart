import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/entities/coordinates.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/weather.dart';
import '../../domain/repositories/weather_repository.dart';

enum WeatherStatus { loading, loaded, failure }

class WeatherState extends Equatable {
  const WeatherState({
    this.status = WeatherStatus.loading,
    this.weather,
    this.updatedAt,
    this.isOutdated = false,
    this.errorMessage,
  });

  final WeatherStatus status;
  final Weather? weather;
  final DateTime? updatedAt;
  final bool isOutdated;
  final String? errorMessage;

  @override
  List<Object?> get props => [
    status,
    weather,
    updatedAt,
    isOutdated,
    errorMessage,
  ];
}

class WeatherCubit extends Cubit<WeatherState> {
  WeatherCubit(this._repository) : super(const WeatherState());

  final WeatherRepository _repository;
  Coordinates? _last;
  int _requestId = 0;

  Future<void> load(Coordinates coordinates) async {
    _last = coordinates;
    final requestId = ++_requestId;

    emit(
      WeatherState(
        status: WeatherStatus.loading,
        weather: state.weather,
        updatedAt: state.updatedAt,
        isOutdated: state.isOutdated,
      ),
    );

    final result = await _repository.getWeather(coordinates);

    if (isClosed || requestId != _requestId) return;

    switch (result) {
      case Success(:final value):
        emit(
          WeatherState(
            status: WeatherStatus.loaded,
            weather: value.data,
            updatedAt: value.savedAt,
            isOutdated: value.isOutdated,
          ),
        );
      case Err(:final failure):
        emit(
          WeatherState(
            status: WeatherStatus.failure,
            errorMessage: failure.message,
          ),
        );
    }
  }

  Future<void> retry() async {
    final coordinates = _last;
    if (coordinates != null) await load(coordinates);
  }
}
