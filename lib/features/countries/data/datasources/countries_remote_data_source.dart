import '../../../../core/config/api_config.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/api_client.dart';
import '../dtos/country_dto.dart';

class CountriesRemoteDataSource {
  CountriesRemoteDataSource(this._client);

  final ApiClient _client;

  Future<List<CountryDto>> fetchCountries() async {
    final body = await _client.getJson(ApiConfig.countriesUrl);

    // World Bank sends [pageInfo, countries], errors come as [{message: ...}]
    if (body is! List || body.length < 2 || body[1] is! List) {
      throw const InvalidResponseFailure();
    }

    try {
      return [
        for (final item in body[1] as List)
          if (item is Map) CountryDto.fromJson(Map<String, dynamic>.from(item)),
      ];
    } on TypeError {
      throw const InvalidResponseFailure();
    }
  }

  Future<int?> fetchPopulation(String code) async {
    final body = await _client.getJson(ApiConfig.populationUrl(code));

    if (body is! List || body.length < 2 || body[1] is! List) return null;

    final rows = body[1] as List;
    if (rows.isEmpty || rows.first is! Map) return null;

    final value = (rows.first as Map)['value'];
    return value is num ? value.toInt() : null;
  }

  Future<String?> fetchCurrency(String code) async {
    final body = await _client.getJson(
      ApiConfig.currencyUrl(code),
      nullOnStatus: {404},
    );

    if (body is! Map || body['data'] is! Map) return null;
    return (body['data'] as Map)['currency']?.toString();
  }
}
