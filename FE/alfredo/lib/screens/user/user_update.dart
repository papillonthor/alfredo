import 'package:alfredo/provider/coin/coin_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/user/user_update_dto.dart';
import '../../provider/achieve/achieve_provider.dart';
import '../../provider/user/user_state_provider.dart';

class UserUpdateScreen extends ConsumerStatefulWidget {
  const UserUpdateScreen({super.key});

  @override
  _UserUpdateScreenState createState() => _UserUpdateScreenState();
}

class _UserUpdateScreenState extends ConsumerState<UserUpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _googleCalendarUrlController =
      TextEditingController();
  DateTime? _birthDate;

  @override
  void initState() {
    super.initState();

    ref.read(userProvider.future).then((user) {
      if (mounted) {
        _nicknameController.text = user.nickname;
        _birthDate = user.birth;
        _googleCalendarUrlController.text = user.googleCalendarUrl ?? '';
      }
    });
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _googleCalendarUrlController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _birthDate) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  Future<void> _checkAchievements() async {
    try {
      final achieveController = ref.read(achieveControllerProvider);

      // 2번째 업적 체크
      await achieveController.checkFirstIcal();

      // 9번째 업적 체크
      await achieveController.checkBirthAchieve();
      ref.refresh(coinProvider);
    } catch (e) {
      // 예외 처리
      print('Error checking achievements: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff0D2338),
        iconTheme: const IconThemeData(color: Color(0xFFF2E9E9)),
        title: const Text(
          '유저 정보 수정',
          style: TextStyle(
            color: Color(0xFFF2E9E9),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      backgroundColor: const Color(0xFFF2E9E9),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nicknameController,
                decoration: const InputDecoration(labelText: '닉네임'),
                validator: (value) => value!.isEmpty ? '닉네임을 입력하세요' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _googleCalendarUrlController,
                decoration: const InputDecoration(labelText: '외부 캘린더 URL'),
                validator: (value) {
                  if (value!.isNotEmpty && !value.endsWith('.ics')) {
                    return '유효한 캘린더 URL을 입력하세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ListTile(
                title: const Text("생일"),
                subtitle: Text(
                  _birthDate == null
                      ? '생일을 선택하세요'
                      : DateFormat('yyyy-MM-dd').format(_birthDate!),
                ),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final userUpdateDto = UserUpdateDto(
                      nickname: _nicknameController.text,
                      birth: _birthDate,
                      googleCalendarUrl: _googleCalendarUrlController.text,
                    );
                    await ref.read(userUpdateProvider(userUpdateDto).future);
                    await _checkAchievements(); // 업적 체크 추가
                    Navigator.pop(context);
                  }
                },
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(const Color(0xFF0D2338)),
                  foregroundColor:
                      MaterialStateProperty.all(const Color(0xFFF2E9E9)),
                ),
                child: const Text('정보 업데이트'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
