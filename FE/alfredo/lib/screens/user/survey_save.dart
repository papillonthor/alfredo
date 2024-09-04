import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SurveySavePage extends ConsumerStatefulWidget {
  const SurveySavePage({super.key});

  @override
  _SurveySavePageState createState() => _SurveySavePageState();
}

class _SurveySavePageState extends ConsumerState<SurveySavePage> {
  Future<void> _fetchAndSaveRoutines() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      String? idToken = await user?.getIdToken(true);

      if (idToken == null) {
        throw Exception('No ID Token found');
      }

      final recommendResponse = await http.get(
        Uri.parse('${dotenv.env['USER_API_URL']}/basic'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $idToken',
        },
      );

      if (recommendResponse.statusCode == 200) {
        final recommendData = json.decode(recommendResponse.body);
        final basicRoutineIds = List<int>.from(recommendData['basicRoutineId']);

        final registerResponse = await http.post(
          Uri.parse('${dotenv.env['ROUTINE_API_URL']}/add-basic-routines'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $idToken',
          },
          body: json.encode({
            'basicRoutineIds': basicRoutineIds,
          }),
        );

        if (registerResponse.statusCode == 200) {
          Navigator.pushReplacementNamed(context, '/main');
        } else {
          print('Failed to register routines: ${registerResponse.body}');
        }
      } else {
        print(
            'Failed to fetch recommended routines: ${recommendResponse.body}');
      }
    } catch (e) {
      print('Error fetching and saving routines: $e');
    }
  }

  void _onStartPressed() {
    Navigator.pushReplacementNamed(context, '/main');
    _fetchAndSaveRoutines();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/opendoor.png',
            fit: BoxFit.cover,
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: ElevatedButton(
                onPressed: _onStartPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xfff0d2338),
                  foregroundColor: const Color(0xFFF2E9E9),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 25),
                ),
                child: const Text(
                  '알프레도와 함께하기',
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
