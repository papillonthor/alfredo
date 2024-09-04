import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class SurveyApi {
  static Future<void> submitSurvey(Map<String, int> answers) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      String? idToken = await user?.getIdToken(true);

      if (idToken == null) {
        throw Exception('No ID Token found');
      }

      final response = await http.put(
        Uri.parse('${dotenv.env['USER_API_URL']}/survey'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: json.encode({
          'question1': answers['당신은 아침형 인간이신가요?'],
          'question2': answers['당신은 야외활동을 좋아하시나요?'],
          'question3': answers['당신은 계획을 촘촘하게 세우시나요?'],
          'question4': answers['당신은 정적인 취미를 가지고 계신가요?'],
          'question5': answers['당신은 강한 의지를 가지고 계신가요?'],
        }),
      );

      if (response.statusCode == 200) {
        print('Survey submitted successfully');
      } else {
        print('Failed to submit survey: ${response.body}');
      }
    } catch (e) {
      print('Error submitting survey: $e');
    }
  }
}
