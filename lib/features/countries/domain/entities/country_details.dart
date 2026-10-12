import 'package:equatable/equatable.dart';

class CountryDetails extends Equatable {
  const CountryDetails({this.population, this.currency});

  final int? population;
  final String? currency;

  @override
  List<Object?> get props => [population, currency];
}
