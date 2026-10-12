import 'package:equatable/equatable.dart';

import '../../../../core/entities/coordinates.dart';

class Country extends Equatable {
  const Country({
    required this.code,
    required this.name,
    required this.capital,
    required this.region,
    this.coordinates,
  });

  final String code;
  final String name;
  final String capital;
  final String region;
  final Coordinates? coordinates;

  @override
  List<Object?> get props => [code, name, capital, region, coordinates];
}
