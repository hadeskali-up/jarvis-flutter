import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;

  const ApiService({this.baseUrl = 'https://bridge.alisuhari.top'});

  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String> headers = const {},
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          ...headers,
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        final previewLength = response.body.length.clamp(0, 180).toInt();
        throw Exception(
          'HTTP ${response.statusCode}: '
          '${response.body.substring(0, previewLength)}',
        );
      }

      final decoded = json.decode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
      throw const FormatException('Expected a JSON object');
    } on FormatException catch (e) {
      throw Exception('Invalid server response: ${e.message}');
    } catch (e) {
      throw Exception('Connection failed: $e');
    }
  }
}
