
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String _baseUrl =
      "https://97wxmzld-5000.asse.devtunnels.ms/api/v1";

  static const String _tokenKey = "token";

  // Save login token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Get login token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Remove login token
  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // Request headers
  static Future<Map<String, String>> _headers() async {
    final token = await getToken();

    return {
      "Content-Type": "application/json",
      "Accept": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  // Handle API response
  static dynamic _handleResponse(http.Response response) {
    dynamic body;

    try {
      body = response.body.isNotEmpty
          ? jsonDecode(response.body)
          : null;
    } catch (e) {
      final responseText = response.body.length > 300
          ? response.body.substring(0, 300)
          : response.body;

      throw Exception(
        'Invalid server response. '
        'Status: ${response.statusCode}. '
        'Response: $responseText',
      );
    }

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      return body;
    }

    final message = body is Map ? body['message'] : null;

    throw Exception(
      message ?? 'Request failed: ${response.statusCode}',
    );
  }

  // GET
  static Future<dynamic> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('$_baseUrl$endpoint'),
      headers: await _headers(),
    );

    return _handleResponse(response);
  }

  // POST
  static Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final response = await http.post(
      Uri.parse('$_baseUrl$endpoint'),
      headers: await _headers(),
      body: jsonEncode(data),
    );

    return _handleResponse(response);
  }

  // POST Multipart for image upload
  static Future<dynamic> postMultipart(
    String endpoint,
    Map<String, String> data,
    Uint8List imageBytes,
    String imageName,
    String imageMimeType,
  ) async {
    final token = await getToken();

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl$endpoint'),
    );

    request.headers.addAll({
      "Accept": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    });

    request.fields.addAll(data);

    request.files.add(
      http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: imageName,
        contentType: MediaType.parse(imageMimeType),
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(
      streamedResponse,
    );

    print('UPLOAD STATUS: ${response.statusCode}');
    print('UPLOAD BODY: ${response.body}');

    return _handleResponse(response);
  }

  // PUT
  static Future<dynamic> put(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final response = await http.put(
      Uri.parse('$_baseUrl$endpoint'),
      headers: await _headers(),
      body: jsonEncode(data),
    );

    return _handleResponse(response);
  }

    // PUT Multipart for updating product with image
  static Future<dynamic> putMultipart(
    String endpoint,
    Map<String, String> data,
    Uint8List imageBytes,
    String imageName,
    String imageMimeType,
  ) async {
    final token = await getToken();

    final request = http.MultipartRequest(
      'PUT',
      Uri.parse('$_baseUrl$endpoint'),
    );

    request.headers.addAll({
      "Accept": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    });

    request.fields.addAll(data);

    request.files.add(
      http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: imageName,
        contentType: MediaType.parse(imageMimeType),
      ),
    );

    final streamedResponse = await request.send();

    final response = await http.Response.fromStream(
      streamedResponse,
    );

    return _handleResponse(response);
  }

  // DELETE
  static Future<dynamic> delete(String endpoint) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl$endpoint'),
      headers: await _headers(),
    );

    return _handleResponse(response);
  }

  // GET categories
  static Future<dynamic> getCategories() async {
    return await get('/categories');
  }
}
