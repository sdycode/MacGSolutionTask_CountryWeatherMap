import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../error/failure.dart';

class ApiClient {
  ApiClient(this._client);

  final http.Client _client;

  Future<dynamic> getJson(
    String url, {
    Set<int> nullOnStatus = const {},
  }) async {
    try {
      final response = await _client
          .get(Uri.parse(url))
          .timeout(ApiConfig.requestTimeout);

      if (nullOnStatus.contains(response.statusCode)) return null;
      if (response.statusCode != 200) throw ServerFailure(response.statusCode);

      return jsonDecode(response.body);
    } on Failure {
      rethrow;
    } on TimeoutException {
      throw const TimeoutFailure();
    } on http.ClientException {
      throw const NetworkFailure();
    } on FormatException {
      throw const InvalidResponseFailure();
    } catch (_) {
      throw const UnknownFailure();
    }
  }
}
