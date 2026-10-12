import '../../../../core/config/api_config.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/api_client.dart';
import '../dtos/weather_dto.dart';

class WeatherRemoteDataSource {
  WeatherRemoteDataSource(this._client);

  final ApiClient _client;

  Future<WeatherDto> fetchCurrent(double latitude, double longitude) async {
    final body = await _client.getJson(
      ApiConfig.weatherUrl(latitude, longitude),
    );

    if (body is! Map || body['current'] is! Map) {
      throw const InvalidResponseFailure();
    }

    try {
      return WeatherDto.fromJson(Map<String, dynamic>.from(body['current']));
    } on TypeError {
      throw const InvalidResponseFailure();
    }
  }
}
