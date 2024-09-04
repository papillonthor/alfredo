import 'dart:convert';
import 'package:alfredo/provider/user/future_provider.dart';
import 'package:http/http.dart' as http;
import '../../models/schedule/schedule_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ScheduleApi {
  final String baseUrl = dotenv.get("SCHEDULE_API_URL");

  ScheduleApi();

  // 헤더에 토큰이 필요 없는 경우
  Map<String, String> get _headers => {
        'Content-Type': 'application/json; charset=UTF-8',
      };

  // 헤더에 토큰이 필요한 경우
  Map<String, String> _authHeaders(String authToken) => {
        ..._headers,
        'Authorization': 'Bearer $authToken',
      };

  // 사용자가 작성한 전체 일정 조회
  Future<List<Schedule>> fetchSchedules(String authToken) async {
    final response = await http.get(Uri.parse('$baseUrl/list'),
        headers: _authHeaders(authToken));

    if (response.statusCode == 200) {
      // UTF-8로 디코딩하여 한글 깨짐 문제 해결
      final decodedBody = utf8.decode(response.bodyBytes);

      // 디코딩된 문자열을 JSON으로 파싱하여 Schedule 객체 리스트로 변환
      return (json.decode(decodedBody) as List)
          .map((data) => Schedule.fromJson(data))
          .toList();
    } else {
      throw Exception('Failed to load schedules');
    }
  }

  // 상세 일정 조회
  Future<Schedule> getScheduleDetail(int id) async {
    final response =
        await http.get(Uri.parse('$baseUrl/detail/$id'), headers: _headers);
    if (response.statusCode == 200) {
      // UTF-8로 디코딩하여 한글 깨짐 문제 해결
      final decodedBody = utf8.decode(response.bodyBytes);
      return Schedule.fromJson(json.decode(decodedBody));
    } else {
      throw Exception(
          'Failed to load schedule detail. Status: ${response.statusCode}');
    }
  }

  // 일정 생성
  Future<Schedule> createSchedule(Schedule schedule, String authToken) async {
    final requestBody = jsonEncode(schedule.toJson()); // JSON 변환
    final response = await http.post(Uri.parse('$baseUrl/save'),
        headers: _authHeaders(authToken), body: requestBody); // 요청 보내기
    if (response.statusCode == 201) {
      return Schedule.fromJson(json.decode(response.body)); // 성공적으로 생성된 일정 반환
    } else {
      throw Exception('Failed to create schedule');
    }
  }

  // Update and delete do not require authorization in this setup
  Future<void> updateSchedule(int id, Schedule schedule) async {
    String jsonString = jsonEncode(schedule.toJson());
    final response = await http.patch(
      Uri.parse('$baseUrl/detail/$id'),
      headers: _headers,
      body: jsonString,
    );

    if (response.statusCode == 200) {
      print('Update successful. Status: ${response.statusCode}');
    } else {
      print('Failed to update. Status: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to update schedule');
    }
  }

  Future<void> deleteSchedule(int id) async {
    final response =
        await http.delete(Uri.parse('$baseUrl/detail/$id'), headers: _headers);

    // 성공적인 응답으로 200 OK와 204 No Content를 모두 처리
    if (response.statusCode != 200 && response.statusCode != 204) {
      print('Failed to delete. Status: ${response.statusCode}');
      throw Exception(
          'Failed to delete schedule. Status: ${response.statusCode}');
    }
  }
}
