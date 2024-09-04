import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final attendanceProvider = Provider((ref) => AttendanceService());

class AttendanceService {
  static final String baseUrl = dotenv.get("ATTENDANCE_API_URL");
  Future<void> checkAttendance(String? authToken) async {
    // print("출석provider 실행중");
    final url = Uri.parse('$baseUrl/check');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to check attendance');
    }
  }

  Future<List<DateTime>> getAttendanceForCurrentWeek(String? authToken) async {
    final url = Uri.parse('$baseUrl/week/history');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch attendance history');
    }

    List<dynamic> data = jsonDecode(response.body);
    return data.map((item) => DateTime.parse(item['date'])).toList();
  }
}
