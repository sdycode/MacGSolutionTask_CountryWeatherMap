import '../../../../core/entities/coordinates.dart';
import '../../domain/entities/country.dart';
import '../dtos/country_dto.dart';

extension CountryDtoMapper on CountryDto {
  Country? toEntity() {
    final region = (this.region ?? '').trim();
    if (region.isEmpty || region == 'Aggregates') return null;

    final lat = double.tryParse(latitude ?? '');
    final lng = double.tryParse(longitude ?? '');

    return Country(
      code: iso2Code ?? '',
      name: (name ?? '').trim(),
      capital: (capitalCity ?? '').trim(),
      region: region,
      coordinates: lat != null && lng != null ? Coordinates(lat, lng) : null,
    );
  }
}

List<Country> mapCountries(Iterable<CountryDto> dtos) {
  final countries = dtos.map((dto) => dto.toEntity()).nonNulls.toList();
  countries.sort((a, b) => a.name.compareTo(b.name));
  return countries;
}
