import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/schedule/schedule_model.dart';
import '../../provider/schedule/schedule_provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../api/alarm/alarm_api.dart';

class ScheduleEditScreen extends ConsumerStatefulWidget {
  final int scheduleId;

  const ScheduleEditScreen({super.key, required this.scheduleId});

  @override
  _ScheduleEditScreenState createState() => _ScheduleEditScreenState();
}

class _ScheduleEditScreenState extends ConsumerState<ScheduleEditScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController? _titleController;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _startAlarm = false;
  bool _withTime = true;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  TimeOfDay? _alarmTime; // 알람 시간 설정을 위한 변수
  DateTime? _alarmDate; // 알람 날짜 설정을 위한 변수
  int? _selectedAlarmOption; // 선택된 알람 옵션 인덱스
  String? _place;

  final AlarmApi alarmApi = AlarmApi();

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  void _loadSchedule() async {
    try {
      final schedule = await ref
          .read(scheduleControllerProvider)
          .getScheduleDetail(widget.scheduleId);
      _titleController = TextEditingController(text: schedule.scheduleTitle);
      _startDate = schedule.startDate;
      _endDate = schedule.endDate;
      _startAlarm = schedule.startAlarm;
      _withTime = schedule.withTime;
      _startTime = schedule.startTime;
      _endTime = schedule.endTime;
      _alarmTime = schedule.alarmTime;
      _alarmDate = schedule.alarmDate; // 알람 날짜 초기 설정
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('일정 로딩 실패: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_titleController == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("일정 상세"),
          backgroundColor: const Color(0xfff0d2338), // AppBar 배경색 설정
          iconTheme: const IconThemeData(color: Colors.white), // 아이콘 색상 설정
        ),
        backgroundColor: const Color(0xfff0d2338), // Scaffold 배경색 설정
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "일정 수정",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xfff0d2338), // AppBar 배경색 설정
        iconTheme: const IconThemeData(color: Colors.white), // 아이콘 색상 설정

        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteSchedule,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: buildFormFields(),
        ),
      ),
    );
  }

  List<Widget> buildFormFields() {
    return [
      TextFormField(
        controller: _titleController,
        decoration: const InputDecoration(labelText: '일정 제목'),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '제목을 입력해주세요';
          }
          return null;
        },
      ),
      ListTile(
        leading: const Icon(Icons.calendar_today),
        title: Text("시작 날짜: ${DateFormat('yyyy-MM-dd').format(_startDate)}"),
        onTap: () => _selectDate(context, isStart: true),
      ),
      ListTile(
        leading: const Icon(Icons.calendar_today),
        title: Text(
            "종료 날짜: ${_endDate != null ? DateFormat('yyyy-MM-dd').format(_endDate!) : '선택되지 않음'}"),
        onTap: () => _selectDate(context, isStart: false),
      ),
      _buildSwitchTile('알람 사용', _startAlarm, (bool value) {
        setState(() {
          _startAlarm = value;
          if (!value) {
            _alarmTime = null;
            _alarmDate = null;
            _removeAlarmIfSet();
          }
        });
      }),
      if (_startAlarm) _buildAlarmOptions(),
      _buildSwitchTile('하루 종일', _withTime, (bool value) {
        setState(() {
          _withTime = value;
          if (!value) {
            _startTime = null;
            _endTime = null;
          }
        });
      }),
      if (!_withTime)
        ListTile(
          leading: const Icon(Icons.access_time),
          title: Text(
              '시작 시간: ${_startTime != null ? _startTime!.format(context) : "선택되지 않음"}'),
          onTap: () => _selectTime(context, isStart: true),
        ),
      if (!_withTime)
        ListTile(
          leading: const Icon(Icons.access_time_filled),
          title: Text(
              '종료 시간: ${_endTime != null ? _endTime!.format(context) : "선택되지 않음"}'),
          onTap: () => _selectTime(context, isStart: false),
        ),
      TextFormField(
        initialValue: _place,
        decoration: const InputDecoration(labelText: '장소'),
        onSaved: (value) => _place = value,
      ),
      Padding(
        padding: const EdgeInsets.all(20.0), // 버튼 주변에 20 픽셀 패딩 추가
        child: ElevatedButton(
          onPressed: _updateSchedule,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xfff0d2338), // 버튼 배경색 설정
            foregroundColor: Colors.white, // 글씨색 설정
          ),
          child: const Text('수정하기'),
        ),
      ),
    ];
  }

  Widget _buildAlarmOptions() {
    List<String> options = _withTime
        ? ['일정 당일 오전 9시', '일정 당일 오후 12시', '사용자 설정']
        : ['시작 1시간 전', '시작 30분 전', '사용자 설정'];

    return Column(
      children: List<Widget>.generate(
          options.length,
          (index) => ListTile(
                leading: const Icon(Icons.alarm),
                title: _buildOptionTitle(index),
                trailing: _selectedAlarmOption == index
                    ? const Icon(Icons.check, color: Colors.blue)
                    : null,
                onTap: () {
                  setState(() {
                    _selectedAlarmOption = index;
                    if (index == 2) {
                      // '사용자 설정' 선택 시 시간 선택기 호출
                      _selectAlarmTime();
                    } else {
                      _updateAlarmTime(index);
                    }
                  });
                },
              )),
    );
  }

  Widget _buildOptionTitle(int index) {
    // 옵션 텍스트 기본 설정
    String optionText = index == 2
        ? '사용자 설정'
        : (_withTime
            ? ['일정 당일 오전 9시', '일정 당일 오후 12시'][index]
            : ['시작 1시간 전', '시작 30분 전'][index]);

    // _alarmTime이 설정되어 있고, _alarmDate도 null이 아닐 때만 날짜와 시간을 표시합니다.
    if (index == 2 && _alarmTime != null && _alarmDate != null) {
      optionText +=
          ' (${DateFormat('MM/dd').format(_alarmDate!)} ${_alarmTime!.format(context)})';
    }
    return Text(optionText);
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

  void _updateAlarmTime(int optionIndex) {
    DateTime baseDateTime = _calculateBaseDateTime(optionIndex);
    _alarmTime = TimeOfDay.fromDateTime(baseDateTime);
    _alarmDate = baseDateTime; // 알람 날짜 설정 업데이트
  }

  DateTime _calculateBaseDateTime(int optionIndex) {
    DateTime baseDateTime = DateTime.now(); // Default to now if no time is set
    if (_withTime) {
      // Specific times set for options 0 and 1
      int hour =
          optionIndex == 0 ? 9 : 12; // 9 AM for option 0, 12 PM for option 1
      baseDateTime =
          DateTime(_startDate.year, _startDate.month, _startDate.day, hour, 0);
    } else if (_startTime != null) {
      // User-set time for options 0 and 1 when not full day
      baseDateTime = DateTime(_startDate.year, _startDate.month, _startDate.day,
          _startTime!.hour, _startTime!.minute);
      int minutesSubtract = optionIndex == 0 ? 60 : 30;
      baseDateTime = baseDateTime.subtract(Duration(minutes: minutesSubtract));
    }
    return baseDateTime;
  }

  void _selectDate(BuildContext context, {required bool isStart}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate ?? DateTime.now(),
      firstDate: isStart ? DateTime.now() : _startDate,
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != (isStart ? _startDate : _endDate)) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate)) {
            _endDate = _startDate; // 종료일을 시작일로 자동 설정
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _selectTime(BuildContext context, {required bool isStart}) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart
          ? (_startTime ?? TimeOfDay.now())
          : (_endTime ?? TimeOfDay.now()),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _selectAlarmTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _alarmTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      DateTime potentialAlarmDate = DateTime(_startDate.year, _startDate.month,
          _startDate.day, picked.hour, picked.minute);
      if (DateTime.now().isAfter(potentialAlarmDate)) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('알람 시간은 현재 시간 이후여야 합니다. 다시 설정해 주세요.')));
        return;
      }
      setState(() {
        _alarmTime = picked;
        _alarmDate = potentialAlarmDate;
      });
    }
  }

  void _deleteSchedule() async {
    try {
      if (_startAlarm) {
        DateTime now = DateTime.now();
        if (_alarmDate != null && _alarmDate!.isAfter(now)) {
          // Only delete alarms that have not occurred yet
          await alarmApi.deleteAlarm(widget.scheduleId);
        }
      }

      await ref
          .read(scheduleControllerProvider)
          .deleteSchedule(widget.scheduleId);
      // 삭제 성공 후, 결과로 true를 반환합니다.
      Navigator.pop(context, true); // 결과로 true를 넘겨줍니다.
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('일정이 삭제되었습니다.')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('일정 삭제 실패: $e')));
    }
  }

  void _updateSchedule() async {
    // 알람 시간을 DateTime 객체로 결합합니다.
    DateTime? fullAlarmDateTime;
    if (_alarmDate != null && _alarmTime != null) {
      fullAlarmDateTime = DateTime(_alarmDate!.year, _alarmDate!.month,
          _alarmDate!.day, _alarmTime!.hour, _alarmTime!.minute);
    }

    // 사용자 설정에서 시간을 선택하지 않았을 때 경고 메시지 표시
    if (_startAlarm && _selectedAlarmOption == 2 && _alarmTime == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('알람 시간을 설정해 주세요.')));
      return; // 유효하지 않은 알람 시간으로 인해 업데이트를 중단합니다.
    }

    // 결합된 알람 시간이 현재 시간 이전인지 검증합니다.
    if (_startAlarm &&
        fullAlarmDateTime != null &&
        fullAlarmDateTime.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('알람 시간은 현재 시간 이후여야 합니다. 다시 설정해 주세요.')));
      return; // 유효하지 않은 알람 시간으로 인해 업데이트를 중단합니다.
    }

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      var updatedSchedule = Schedule(
        scheduleId: widget.scheduleId,
        scheduleTitle: _titleController!.text,
        startDate: _startDate,
        endDate: _endDate,
        startAlarm: _startAlarm,
        alarmTime: _alarmTime,
        alarmDate: _alarmDate,
        place: _place,
        startTime: _startTime,
        endTime: _endTime,
        withTime: _withTime,
      );

      try {
        // 스케줄 업데이트를 요청합니다.
        await ref
            .read(scheduleControllerProvider)
            .updateSchedule(widget.scheduleId, updatedSchedule);

        // startAlarm이 false일 경우 알람을 삭제합니다.
        if (!_startAlarm) {
          // 알람 삭제 API를 호출합니다. 백엔드에서 해당 로직을 처리한다고 가정합니다.
          await alarmApi.deleteAlarm(widget.scheduleId);
        } else if (_startAlarm &&
            _alarmDate != null &&
            _alarmDate!.isAfter(DateTime.now())) {
          // 알람이 활성화되어 있고, 알람 날짜가 현재 날짜 이후인 경우 알람 정보를 업데이트합니다.
          String? token = await FirebaseMessaging.instance.getToken();
          if (token != null) {
            String formattedDateTime =
                alarmApi.formatScheduleDateTime(_alarmDate, _alarmTime);
            await alarmApi.updateAlarm(token, _titleController!.text,
                formattedDateTime, widget.scheduleId);
          }
        }

        // 일정 수정이 성공적으로 완료되었다는 메시지를 사용자에게 알립니다.
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('일정이 정상적으로 수정되었습니다')));
        Navigator.pop(context, true);
      } catch (error) {
        // 일정 수정 실패 시 에러 메시지를 표시합니다.
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('수정 실패: $error')));
      }
    }
  }

  void _removeAlarmIfSet() async {
    if (_startAlarm &&
        _alarmDate != null &&
        _alarmDate!.isAfter(DateTime.now())) {
      // 알람이 설정되어 있고 아직 실행되지 않았다면 삭제
      await alarmApi.deleteAlarm(widget.scheduleId);
    }
  }
}
