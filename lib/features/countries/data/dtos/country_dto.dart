class CountryDto {
  const CountryDto({
    this.iso2Code,
    this.name,
    this.region,
    this.capitalCity,
    this.latitude,
    this.longitude,
  });

  factory CountryDto.fromJson(Map<String, dynamic> json) {
    final region = json['region'];

    return CountryDto(
      iso2Code: json['iso2Code'] as String?,
      name: json['name'] as String?,
      region: region is Map ? region['value'] as String? : null,
      capitalCity: json['capitalCity'] as String?,
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
    );
  }

  final String? iso2Code;
  final String? name;
  final String? region;
  final String? capitalCity;
  final String? latitude;
  final String? longitude;

  Map<String, dynamic> toJson() => {
    'iso2Code': iso2Code,
    'name': name,
    'region': {'value': region},
    'capitalCity': capitalCity,
    'latitude': latitude,
    'longitude': longitude,
  };
}
