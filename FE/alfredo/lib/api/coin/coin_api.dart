import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../../models/coin/coin_model.dart';

class CoinApi {
  final String baseUrl = dotenv.get("COIN_API_URL");

  CoinApi();

  Map<String, String> _authHeaders(String authToken) => {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $authToken',
      };

  Future<Coin> getCoinDetail(String authToken) async {
    final response = await http.get(
      Uri.parse('$baseUrl/detail'),
      headers: _authHeaders(authToken),
    );
    if (response.statusCode == 200) {
      return Coin.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch coin details: ${response.body}');
    }
  }

  Future<void> createCoin(String authToken) async {
    final response = await http.post(
      Uri.parse('$baseUrl/create'),
      headers: _authHeaders(authToken),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to create coin: ${response.body}');
    }
  }

  Future<void> incrementCoin(String authToken) async {
    final response = await http.post(
      Uri.parse('$baseUrl/increment'),
      headers: _authHeaders(authToken),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to increment coin: ${response.body}');
    }
  }

  Future<void> decrementCoin(String authToken) async {
    final response = await http.post(
      Uri.parse('$baseUrl/decrement'),
      headers: _authHeaders(authToken),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to decrement coin: ${response.body}');
    }
  }

  Future<void> decrementTotalCoin(String authToken, int decrementValue) async {
    final response = await http.post(
      Uri.parse('$baseUrl/decrementTotal'),
      headers: _authHeaders(authToken),
      body: jsonEncode({'decrementValue': decrementValue}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to decrement total coin: ${response.body}');
    }
  }
}
