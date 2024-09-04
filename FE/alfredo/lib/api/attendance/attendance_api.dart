import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AttendanceApi {
  static final String baseUrl = dotenv.get("ATTENDANCE_API_URL");

  AttendanceApi();

  // 헤더에 토큰이 필요 없는 경우
  Map<String, String> get _headers => {
        'Content-Type': 'application/json; charset=UTF-8',
      };

  // 헤더에 토큰이 필요한 경우
  Map<String, String> _authHeaders(String? authToken) => {
        ..._headers,
        'Authorization': 'Bearer $authToken',
      };

  // 이번 주 출석 일수 조회
  Future<int> getTotalAttendanceDaysForWeek(String? authToken) async {
    final url = Uri.parse('$baseUrl/week/count');
    final response = await http.get(
      url,
      headers: _authHeaders(authToken),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch total attendance days for week');
    }

    return int.parse(response.body);
  }

  // 이번 주 연속 출석 일수 조회
  Future<int> getConsecutiveAttendanceDays(String? authToken) async {
    final url = Uri.parse('$baseUrl/week/consecutive');
    final response = await http.get(
      url,
      headers: _authHeaders(authToken),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch consecutive attendance days');
    }

    return int.parse(response.body);
  }

  // 총 출석 일수 조회
  Future<int> getTotalAttendanceDays(String? authToken) async {
    final url = Uri.parse('$baseUrl/total/count');
    final response = await http.get(
      url,
      headers: _authHeaders(authToken),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch total attendance days');
    }
    return int.parse(response.body);
  }
}
