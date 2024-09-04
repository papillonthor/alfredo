import 'dart:async';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ShopApi {
  final String _baseUrl = dotenv.get('SHOP_API_URL');

  // 헤더에 토큰이 필요 없는 경우
  Map<String, String> get _headers => {
        'Content-Type': 'application/json; charset=UTF-8',
      };

  // 헤더에 토큰이 필요한 경우
  Map<String, String> _authHeaders(String authToken) => {
        ..._headers,
        'Authorization': 'Bearer $authToken',
      };

  Future<Map<String, dynamic>> getShopList(String authToken) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/shoplist'),
      headers: _authHeaders(authToken),
    );

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      return jsonDecode(decodedBody);
    } else {
      throw Exception('Failed to load ShopList data');
    }
  }

  Future<Map<String, dynamic>> getShopStatus(String authToken) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/status'),
      headers: _authHeaders(authToken),
    );

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      return jsonDecode(decodedBody);
    } else {
      throw Exception('Failed to load ShopList data');
    }
  }

  Future<void> shopUpdataStatus(
      String authToken, int? background, int? characterType) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/select'),
      headers: _authHeaders(authToken),
      body: jsonEncode(
          {'background': background, 'characterType': characterType}),
    );

    if (response.statusCode == 200) {
    } else {
      throw Exception('Failed to update shopStatus.');
    }
  }

  Future<void> buyUpdataStatus(
      String authToken, int? background, int? characterType) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/buy'),
      headers: _authHeaders(authToken),
      body: jsonEncode(
          {'background': background, 'characterType': characterType}),
    );

    if (response.statusCode == 200) {
    } else {
      throw Exception('Failed to update shopStatus.');
    }
  }
}
