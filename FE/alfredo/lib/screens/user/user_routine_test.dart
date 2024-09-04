import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../api/user/survey_api.dart';
import '../user/loading_screen.dart';

class UserRoutineTestPage extends ConsumerStatefulWidget {
  const UserRoutineTestPage({super.key});

  @override
  _UserRoutineTestPageState createState() => _UserRoutineTestPageState();
}

class _UserRoutineTestPageState extends ConsumerState<UserRoutineTestPage> {
  final List<String> questions = [
    '당신은 아침형 인간이신가요?',
    '당신은 야외활동을 좋아하시나요?',
    '당신은 계획을 촘촘하게 세우시나요?',
    '당신은 정적인 취미를 가지고 계신가요?',
    '당신은 강한 의지를 가지고 계신가요?',
  ];

  final Map<String, int> answers = {};
  int currentQuestionIndex = 0;
  bool isLoading = false;

  void _submitAnswer(int answer) {
    setState(() {
      answers[questions[currentQuestionIndex]] = answer;
      currentQuestionIndex++;
    });

    if (currentQuestionIndex >= questions.length) {
      _submitSurvey();
    }
  }

  Future<void> _submitSurvey() async {
    setState(() {
      isLoading = true;
    });

    await SurveyApi.submitSurvey(answers);
    Navigator.pushReplacementNamed(context, '/survey_save');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xfff0d2338),
        iconTheme: const IconThemeData(color: Color(0xFFF2E9E9)),
        titleTextStyle: const TextStyle(
          color: Color(0xFFF2E9E9),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        title: const Text('설문조사'),
      ),
      body: Container(
        color: const Color(0xFFD6C3C3),
        child: Center(
          child: isLoading
              ? const MyLoadingScreen()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      questions[currentQuestionIndex],
                      style: const TextStyle(
                          fontSize: 23, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () => _submitAnswer(0),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: const Color(0xFFF2E9E9),
                            backgroundColor: const Color(0xfff0d2338),
                            minimumSize: const Size(100, 50), // Button size
                          ),
                          child: const Text(
                            '예',
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: () => _submitAnswer(1),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: const Color(0xFFF2E9E9),
                            backgroundColor: const Color(0xfff0d2338),
                            minimumSize: const Size(100, 50),
                          ),
                          child: const Text(
                            '아니오',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
