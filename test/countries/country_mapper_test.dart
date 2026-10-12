import 'package:flutter_test/flutter_test.dart';
import 'package:country_weather_app/core/entities/coordinates.dart';
import 'package:country_weather_app/features/countries/data/dtos/country_dto.dart';
import 'package:country_weather_app/features/countries/data/mappers/country_mapper.dart';

void main() {
  CountryDto dto({
    String? name = 'India',
    String? region = 'South Asia',
    String? capital = 'New Delhi',
    String? lat = '28.6353',
    String? lng = '77.225',
  }) => CountryDto(
    iso2Code: 'IN',
    name: name,
    region: region,
    capitalCity: capital,
    latitude: lat,
    longitude: lng,
  );

  test('maps a country and parses string coordinates', () {
    final country = dto().toEntity()!;

    expect(country.code, 'IN');
    expect(country.name, 'India');
    expect(country.capital, 'New Delhi');
    expect(country.coordinates, const Coordinates(28.6353, 77.225));
  });

  test('trims the region', () {
    expect(
      dto(region: 'Latin America & Caribbean ').toEntity()!.region,
      'Latin America & Caribbean',
    );
  });

  test('skips aggregates and entries without a region', () {
    expect(dto(region: 'Aggregates').toEntity(), isNull);
    expect(dto(region: '').toEntity(), isNull);
    expect(dto(region: null).toEntity(), isNull);
  });

  test('missing capital and coordinates do not crash', () {
    final country = dto(capital: null, lat: '', lng: '').toEntity()!;

    expect(country.capital, '');
    expect(country.coordinates, isNull);
  });

  test('mapCountries drops aggregates and sorts by name', () {
    final countries = mapCountries([
      dto(name: 'Japan'),
      dto(name: 'World', region: 'Aggregates'),
      dto(name: 'India'),
    ]);

    expect(countries.map((c) => c.name), ['India', 'Japan']);
  });
}
