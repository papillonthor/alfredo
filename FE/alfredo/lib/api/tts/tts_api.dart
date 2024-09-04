import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TtsApi {
  final String baseUrl = dotenv.get("TTS_API_URL");

  TtsApi();

  // 헤더에 토큰이 필요 없는 경우
  Map<String, String> get _headers => {
        'Content-Type': 'application/json; charset=UTF-8',
      };

  // 헤더에 토큰이 필요한 경우
  Map<String, String> _authHeaders(String authToken) => {
        ..._headers,
        'Authorization': 'Bearer $authToken',
      };

  // 텍스트 음성 변환 데이터 가져오기
  Future<String> fetchSummary(String authToken) async {
    final response = await http.get(Uri.parse('$baseUrl/listen'),
        headers: _authHeaders(authToken));

    if (response.statusCode == 200) {
      // UTF-8로 디코딩하여 한글 깨짐 문제 해결
      final decodedBody = utf8.decode(response.bodyBytes);
      return decodedBody;  // 직접 사용할 텍스트 데이터를 반환
    } else {
      throw Exception('Failed to load TTS data');
    }
  }
}
