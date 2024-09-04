import 'package:http/http.dart' as http;

class TTSController {
  final String baseUrl;
  TTSController(this.baseUrl);

  Future<String> fetchSummary(String authToken) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/tts'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception('Failed to load summary');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }
}
