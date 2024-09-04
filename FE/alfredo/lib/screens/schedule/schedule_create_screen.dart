import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../controller/schedule/schedule_controller.dart';
import '../../models/schedule/schedule_model.dart';
import 'schedule_list_screen.dart';
import '../../provider/schedule/schedule_provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../services/firebase_messaging_service.dart';
import '../../api/alarm/alarm_api.dart';
import '../../provider/achieve/achieve_provider.dart';

class ScheduleCreateScreen extends ConsumerWidget {
  const ScheduleCreateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(scheduleControllerProvider);
    return _ScheduleCreateScreenBody(
      controller: controller,
      ref: ref,
    ); // ref를 전달합니다.
  }
}

class _ScheduleCreateScreenBody extends ConsumerStatefulWidget {
  final ScheduleController controller;
  final WidgetRef ref; // ref 추가

  const _ScheduleCreateScreenBody(
      {super.key, required this.controller, required this.ref});

  @override
  _ScheduleCreateScreenState createState() => _ScheduleCreateScreenState();
}

class _ScheduleCreateScreenState
    extends ConsumerState<_ScheduleCreateScreenBody> {
  final _formKey = GlobalKey<FormState>();

  String title = '';
  DateTime startDate = DateTime.now();
  DateTime? endDate;
  bool startAlarm = false;
  TimeOfDay? alarmTime; // 사용자가 설정한 알람 시간
  DateTime? alarmDate; // 추가된 알람 날짜 필드
  String? place;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  bool withTime = true;
  int? selectedAlarmOption;

  @override
  void initState() {
    super.initState();
    endDate = startDate; // 종료 날짜의 초기값을 시작 날짜와 동일하게 설정합니다.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("일정 생성",
            style: TextStyle(
                color: Colors.white)), // Set title text color to white
        backgroundColor: const Color(0xfff0d2338),
        iconTheme: const IconThemeData(
            color: Colors.white), // Set back button and other icons to white
      ),
      backgroundColor: const Color(0xFFF2E9E9),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            TextFormField(
              decoration: const InputDecoration(labelText: '일정 제목'),
              onSaved: (value) => title = value ?? '',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '제목을 입력해주세요';
                }
                return null;
              },
            ),
            _buildDatePicker('시작 날짜', startDate, isStartDate: true),
            _buildDatePicker('종료 날짜', endDate ?? startDate, isStartDate: false),
            _buildSwitchTile('알람 사용', startAlarm, (value) {
              setState(() {
                startAlarm = value;
                selectedAlarmOption = null; // 알람 사용이 변경될 때 선택 옵션 초기화
                if (!value) {
                  alarmTime =
                      null; // Ensure alarmTime is reset when alarm is disabled
                  alarmDate = null; // Reset alarmDate as well
                }
              });
            }),
            if (startAlarm) _buildAlarmOptions(),
            _buildSwitchTile('하루 종일', withTime, (value) {
              setState(() {
                withTime = value;
                startTime = endTime = null; // 하루 종일 설정이 변경될 때 시간 초기화
                // Update alarm options based on the withTime status
                selectedAlarmOption = null;
                alarmTime = null;
                alarmDate = null;
              });
            }),
            if (!withTime) _buildTimePicker('시작 시간', startTime, true),
            if (!withTime) _buildTimePicker('종료 시간', endTime, false),
            _buildTextField('장소', (value) => place = value),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, Function(String?) onSaved) {
    return TextFormField(
      decoration: InputDecoration(labelText: label),
      onSaved: onSaved,
    );
  }

  Widget _buildDatePicker(String label, DateTime date,
      {required bool isStartDate}) {
    return ListTile(
      leading: const Icon(Icons.calendar_today),
      title: Text('$label: ${DateFormat('yyyy-MM-dd').format(date)}'),
      onTap: () => _selectDate(context, isStart: isStartDate),
    );
  }

  Widget _buildTimePicker(String label, TimeOfDay? time, bool isStartTime) {
    return ListTile(
      leading: const Icon(Icons.alarm),
      title: Text('$label: ${time != null ? time.format(context) : "선택되지 않음"}'),
      onTap: () => _selectTime(context, isStart: isStartTime),
    );
  }

  // 알림사용, 하루종일 스와이프 아이콘
  Widget _buildSwitchTile(
      String title, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xfff0d2338), // 스위치 버튼이 활성화될 때의 주 색상
      activeTrackColor: const Color(0xFFE7D8BC), // 스위치 트랙의 활성화된 부분의 색상
      inactiveThumbColor:
          const Color(0xFFBDBDBD), // 스위치 버튼이 비활성화될 때의 색상 (더 어둡게 설정)
      inactiveTrackColor: const Color(0x99E7D8BC), // 스위치 트랙의 비활성화된 부분의 색상
    );
  }

  Widget _buildAlarmOptions() {
    List<String> options = withTime
        ? ['일정 당일 오전 9시', '일정 당일 오후 12시', '사용자 설정']
        : ['시작 1시간 전', '시작 30분 전', '사용자 설정'];

    return Column(
      children: List<Widget>.generate(
        options.length,
        (index) => ListTile(
          leading: const Icon(Icons.alarm),
          title: Text(_buildOptionTitle(index, options)),
          trailing: selectedAlarmOption == index
              ? const Icon(Icons.check, color: Colors.blue)
              : null,
          onTap: () {
            setState(() {
              selectedAlarmOption = index;
              _updateAlarmTime(index);
            });
          },
        ),
      ),
    );
  }

  String _buildOptionTitle(int index, List<String> options) {
    // options 배열을 인자로 받음
    String optionText = options[index];
    if (index == 2 && alarmTime != null && alarmDate != null) {
      optionText +=
          ' (${DateFormat('MM/dd').format(alarmDate!)} ${alarmTime!.format(context)})';
    }
    return optionText;
  }

  void _updateAlarmTime(int optionIndex) {
    DateTime baseDateTime =
        DateTime(startDate.year, startDate.month, startDate.day);

    if (!withTime && startTime != null) {
      // withTime이 false이고 startTime이 설정된 경우, startTime을 기반으로 날짜와 시간을 설정
      baseDateTime = DateTime(startDate.year, startDate.month, startDate.day,
          startTime!.hour, startTime!.minute);
    }

    if (optionIndex == 0) {
      // 이 부분이 withTime 설정에 따라 올바르게 일정 시간을 설정하도록 수정되었습니다.
      baseDateTime = withTime
          ? DateTime(startDate.year, startDate.month, startDate.day, 9, 0)
          : (startTime != null
              ? DateTime(startDate.year, startDate.month, startDate.day,
                      startTime!.hour, startTime!.minute)
                  .subtract(const Duration(hours: 1))
              : DateTime.now());
    } else if (optionIndex == 1) {
      baseDateTime = withTime
          ? DateTime(startDate.year, startDate.month, startDate.day, 12, 0)
          : (startTime != null
              ? DateTime(startDate.year, startDate.month, startDate.day,
                      startTime!.hour, startTime!.minute)
                  .subtract(const Duration(minutes: 30))
              : DateTime.now());
    } else if (optionIndex == 2) {
      // 사용자 정의 시간을 선택하는 경우 별도의 처리가 필요합니다.
      _selectAlarmTime(context);
      return;
    }

    setState(() {
      alarmDate = baseDateTime; // 알람 날짜 설정
      alarmTime = TimeOfDay(
          hour: baseDateTime.hour, minute: baseDateTime.minute); // 알람 시간 설정
    });
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: ElevatedButton(
        onPressed: () async {
          if (_validateForm()) {
            _formKey.currentState!.save();
            var newSchedule = Schedule(
              scheduleTitle: title,
              startDate: startDate,
              endDate: endDate,
              startAlarm: startAlarm,
              alarmTime: alarmTime,
              alarmDate: alarmDate,
              place: place,
              startTime: startTime,
              endTime: endTime,
              withTime: withTime,
            );
            try {
              String? token = await FirebaseMessaging.instance.getToken();
              if (startAlarm && token != null) {
                await widget.controller.createSchedule(newSchedule);
                AlarmApi alarmApi = AlarmApi();
                String formattedDateTime =
                    alarmApi.formatScheduleDateTime(alarmDate, alarmTime);
                await alarmApi.sendTokenAndScheduleData(
                    token, title, formattedDateTime);
              } else {
                await widget.controller.createSchedule(newSchedule);
              }

              // 업적 체크 메서드 호출
              final achieveController = ref.read(achieveControllerProvider);
              await achieveController.checkTotalScheduleAchieve();

              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('일정이 성공적으로 생성되었습니다.')));

              // 일정 생성 후 이전 화면으로 이동
              Navigator.pop(context);
            } catch (error) {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('일정 생성에 실패했습니다: $error')));
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xfff0d2338),
          foregroundColor: Colors.white,
        ),
        child: const Text('저장'),
      ),
    );
  }

  bool _validateForm() {
    bool isValid = _formKey.currentState!.validate();
    if (!withTime && (startTime == null || endTime == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('시작 시간과 종료 시간을 모두 입력해야 합니다.')));
      isValid = false;
    }
    if (!withTime && startTime != null && endTime != null) {
      DateTime startDateTime = DateTime(startDate.year, startDate.month,
          startDate.day, startTime!.hour, startTime!.minute);
      DateTime endDateTime = DateTime(endDate!.year, endDate!.month,
          endDate!.day, endTime!.hour, endTime!.minute);
      if (endDateTime.isBefore(startDateTime) || endDateTime.hour >= 24) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('종료 시간은 시작 시간 이후여야 하며 오후 11시 59분 이전이어야 합니다.')));
        isValid = false;
      }
    }
    if (startAlarm) {
      if (selectedAlarmOption == null ||
          (selectedAlarmOption == 2 &&
              (alarmDate == null || alarmTime == null))) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('알람 시간을 설정해 주세요.')));
        isValid = false;
      }
      if (alarmDate != null && alarmTime != null) {
        DateTime combinedDateTime = DateTime(alarmDate!.year, alarmDate!.month,
            alarmDate!.day, alarmTime!.hour, alarmTime!.minute);
        if (combinedDateTime.isBefore(DateTime.now())) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('알람 시간은 현재 시간 이후여야 합니다. 다시 설정해 주세요.')));
          isValid = false;
        }
      }
    }
    return isValid;
  }

  // 날짜 설정
  Future<void> _selectDate(BuildContext context,
      {required bool isStart}) async {
    DateTime initialDate = isStart ? startDate : (endDate ?? startDate);
    DateTime firstDate = isStart ? DateTime.now() : startDate;
    DateTime lastDate = DateTime(2100);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
          // 시작일이 변경되었을 때 종료일이 시작일보다 이전인 경우를 처리
          if (endDate != null && endDate!.isBefore(startDate)) {
            endDate = startDate; // 종료일을 시작일로 자동 설정
          }
        } else {
          endDate = picked;
        }
      });
    }
  }

  // 시간 설정
  Future<void> _selectTime(BuildContext context,
      {required bool isStart}) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart
          ? (startTime ?? TimeOfDay.now())
          : (endTime ?? TimeOfDay.now()),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startTime = picked;
        } else {
          endTime = picked;
        }
      });
    }
  }

  Future<void> _selectAlarmTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: alarmTime ?? TimeOfDay.now(), // 기본값으로 현재 시간 설정
    );
    if (picked != null) {
      setState(() {
        alarmTime = picked;
        // 사용자가 시간을 선택하면 alarmDate를 startDate로 설정합니다.
        // 여기서 startDate는 사용자가 이전에 선택한 시작 날짜를 의미합니다.
        alarmDate = DateTime(startDate.year, startDate.month, startDate.day,
            alarmTime!.hour, alarmTime!.minute);
      });
    }
  }
}
