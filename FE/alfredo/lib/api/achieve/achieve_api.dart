import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../../models/achieve/achieve_model.dart'; // 모델 클래스 경로 수정

class AchieveApi {
  final String baseUrl = dotenv.get("ACHIEVE_API_URL");

  AchieveApi();

  // 헤더에 토큰이 필요한 경우
  Map<String, String> _authHeaders(String authToken) => {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $authToken',
      };

  // 업적 테이블 생성
  Future<void> createAchieve(String authToken) async {
    final response = await http.post(
      Uri.parse('$baseUrl/create'),
      headers: _authHeaders(authToken),
    );
    if (response.statusCode == 200) {
      print('Achieve created successfully.');
    } else {
      throw Exception('Failed to create achieve: ${response.body}');
    }
  }

  // 업적 테이블 조회
  Future<Achieve> detailAchieve(String authToken) async {
    final response = await http.get(
      Uri.parse('$baseUrl/detail'),
      headers: _authHeaders(authToken),
    );
    if (response.statusCode == 200) {
      print(response.body);
      return Achieve.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch achieve details: ${response.body}');
    }
  }

// 1번째 업적 - 총 수행 시간
  Future<void> checkTimeAchieve(String authToken) async {
    final response = await http.post(
      Uri.parse('$baseUrl/one'),
      headers: _authHeaders(authToken),
    );
    if (response.statusCode == 200) {
      print('First iCal achieve checked successfully.');
    } else {
      throw Exception('Failed to check first iCal achieve: ${response.body}');
    }
  }

  // 2번째 업적 - 첫 ical 등록
  Future<void> checkFirstIcal(String authToken) async {
    final response = await http.post(
      Uri.parse('$baseUrl/two'),
      headers: _authHeaders(authToken),
    );
    if (response.statusCode == 200) {
      print('First iCal achieve checked successfully.');
    } else {
      throw Exception('Failed to check first iCal achieve: ${response.body}');
    }
  }

  // 3번째 업적 - day 풀 참가
  Future<void> checkWeekendAchieve(String authToken) async {
    final response = await http.post(
      Uri.parse('$baseUrl/three'),
      headers: _authHeaders(authToken),
    );
    if (response.statusCode == 200) {
      print('Weekend achieve checked successfully.');
    } else {
      throw Exception('Failed to check weekend achieve: ${response.body}');
    }
  }

  // 4번째 업적 - 총 루틴 갯수
  Future<void> checkTotalRoutineAchieve(String authToken) async {
    final response = await http.post(
      Uri.parse('$baseUrl/four'),
      headers: _authHeaders(authToken),
    );
    if (response.statusCode == 200) {
      print('Total routine achieve checked successfully.');
    } else {
      throw Exception(
          'Failed to check total routine achieve: ${response.body}');
    }
  }

  // 5번째 업적 - 총 투두 갯수
  Future<void> checkTotalTodoAchieve(String authToken) async {
    final response = await http.post(
      Uri.parse('$baseUrl/five'),
      headers: _authHeaders(authToken),
    );
    if (response.statusCode == 200) {
      print('Total todo achieve checked successfully.');
    } else {
      throw Exception('Failed to check total todo achieve: ${response.body}');
    }
  }

  // 6번째 업적 - 총 일정 갯수
  Future<void> checkTotalScheduleAchieve(String authToken) async {
    final response = await http.post(
      Uri.parse('$baseUrl/six'),
      headers: _authHeaders(authToken),
    );
    if (response.statusCode == 200) {
      print('Total schedule achieve checked successfully.');
    } else {
      throw Exception(
          'Failed to check total schedule achieve: ${response.body}');
    }
  }

  // 9번째 업적 - 생일인 경우
  Future<void> checkBirthAchieve(String authToken) async {
    final response = await http.post(
      Uri.parse('$baseUrl/nine'),
      headers: _authHeaders(authToken),
    );
    if (response.statusCode == 200) {
      print('Birth achieve checked successfully.');
    } else {
      throw Exception('Failed to check birth achieve: ${response.body}');
    }
  }
}
