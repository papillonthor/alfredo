import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AlarmApi {
  final String baseUrl = dotenv.get("ALARM_API_URL");

  // 헤더에 토큰이 필요 없는 경우
  Map<String, String> get _headers => {
        'Content-Type': 'application/json; charset=UTF-8',
      };

  /// 토큰과 일정 정보를 서버로 전송합니다.
  Future<void> sendTokenAndScheduleData(
      String token, String title, String body) async {
    var url = Uri.parse('$baseUrl/send');
    var response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'targetToken': token,
        'title': title,
        'body': body,
      }),
    );
    if (response.statusCode == 200) {
      print("Data successfully sent to the server");
    } else {
      print(
          "Failed to send data to server: ${response.statusCode} - ${response.body}");
    }
  }

  /// 토큰과 일정 정보를 서버로 전송합니다.
  Future<void> updateAlarm(
      String token, String title, String body, int id) async {
    var url = Uri.parse('$baseUrl/update/$id');
    var response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'targetToken': token,
        'title': title,
        'body': body,
      }),
    );

    if (response.statusCode == 200) {
      print("Data successfully sent to the server");
    } else {
      print(
          "Failed to send data to server: ${response.statusCode} - ${response.body}");
    }
  }

  Future<void> deleteAlarm(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/delete/$id'),
          headers: _headers);

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('Successfully deleted. Status: ${response.statusCode}');
      } else {
        print('Failed to delete. Status: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception(
            'Failed to delete schedule. Status: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Exception caught: $e');
      throw Exception('Exception occurred during delete operation: $e');
    }
  }

  /// 시작 날짜와 시간을 문자열로 포매팅합니다.
  String formatScheduleDateTime(DateTime? alarmDate, TimeOfDay? startTime) {
    final dateStr = DateFormat('yyyy-MM-dd').format(alarmDate!);
    final timeStr = startTime != null
        ? '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}'
        : 'All Day';
    return '$dateStr $timeStr';
  }

  /// 문자열로부터 TimeOfDay를 생성합니다.
  static TimeOfDay _timeFromString(String timeStr) {
    final timeParts = timeStr.split(':').map(int.parse).toList();
    return TimeOfDay(hour: timeParts[0], minute: timeParts[1]);
  }
}
