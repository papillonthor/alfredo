import 'dart:convert';

import 'package:alfredo/models/routine/routine_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class RoutineApi {
  static final String baseUrl = dotenv.get("ROUTINE_API_URL");

  RoutineApi();

  // 헤더에 토큰이 필요 없는 경우
  Map<String, String> get _headers => {
        'Content-Type': 'application/json; charset=UTF-8',
      };

  // 헤더에 토큰이 필요한 경우
  Map<String, String> _authHeaders(String? authToken) => {
        ..._headers,
        'Authorization': 'Bearer $authToken',
      };

  // 로그인한 유저의 전체 일정 조회
  Future<List<Routine>> getAllRoutines(var authToken) async {
    final url = Uri.parse('$baseUrl/all');
    final response = await http.get(url, headers: _authHeaders(authToken));

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      final List<dynamic> routines = jsonDecode(decodedBody);
      // print('잘 읽어왔어용');
      return routines.map((routine) => Routine.fromJson(routine)).toList();
      // return (json.decode(decodedBody) as List)
      //     .map((data) => Routine.fromJson(data))
      //     .toList();
    } else {
      // print('못읽었어용');
      throw Exception('Failed to load routines: ${response.statusCode}');
    }
  }

  // 로그인한 유저의 한개의 일정 조회
  Future<Routine> getRoutine(var authToken, var routineId) async {
    final url = Uri.parse('$baseUrl/$routineId');
    final response = await http.get(url, headers: _authHeaders(authToken));

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      // print('잘 읽어왔어용');
      return Routine.fromJson(json.decode(decodedBody));
    } else {
      // print('못읽었어용');
      throw Exception('Failed to load routine: ${response.statusCode}');
    }
  }

  // 로그인한 유저의 일정 생성
  Future<void> createRoutine(
      String? authToken,
      String routineTitle,
      String startTime,
      List<String> days,
      String alarmSound,
      String memo,
      int? basicRoutineId) async {
    // 기본 루틴 ID 추가
    final url = Uri.parse(baseUrl);

    final body = jsonEncode({
      "routineTitle": routineTitle,
      "startTime": startTime,
      "days": days,
      "alarmSound": alarmSound,
      "memo": memo,
      "basicRoutineId": basicRoutineId, // 기본 루틴 ID 추가
    });

    final response = await http.post(url,
        headers: _authHeaders(authToken), body: utf8.encode(body));

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create routine: ${response.statusCode}');
    }
  }

//기본 루틴 정보 가져오기
  Future<Routine> fetchBasicRoutine(int basicRoutineId) async {
    final url = Uri.parse('$baseUrl/basic-routine/$basicRoutineId');
    final response = await http.get(url, headers: _headers);

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      return Routine.fromJson(json.decode(decodedBody));
    } else {
      throw Exception('Failed to load basic routine: ${response.statusCode}');
    }
  }

  // 일정 삭제
  Future<void> deleteRoutine(int routineId) async {
    // print("삭제");
    final url = Uri.parse('$baseUrl/$routineId');
    final response = await http.delete(url);

    if (response.statusCode != 200 && response.statusCode != 204) {
      // print('Failed to delete. Status: ${response.statusCode}');
      throw Exception('Failed to delete routine: ${response.statusCode}');
    }
  }

  // 일정 수정
  Future<void> updateRoutine(int routineId, String title, String startTime,
      List<String?> days, String alarmSound, String memo) async {
    final url = Uri.parse('$baseUrl/$routineId'); // URL 구성

    try {
      final response = await http.patch(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'routineTitle': title,
          'startTime': startTime,
          'days': days,
          'alarmSound': alarmSound,
          'memo': memo,
        }),
      );

      if (response.statusCode == 200) {
        // print("Routine updated successfully.");
      } else {
        // print('Failed to update routine: ${response.body}');
        throw Exception('Failed to update routine');
      }
    } catch (e) {
      // print('Error updating routine: $e');
      throw Exception('Error updating routine');
    }
  }
}
