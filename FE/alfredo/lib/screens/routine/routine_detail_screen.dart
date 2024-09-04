import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/routine/routine_api.dart';
import '../../models/routine/routine_model.dart';
import '../../provider/routine/routine_provider.dart';

class RoutineDetailScreen extends ConsumerStatefulWidget {
  final Routine routine;

  const RoutineDetailScreen({super.key, required this.routine});

  @override
  _RoutineDetailScreenState createState() => _RoutineDetailScreenState();
}

class _RoutineDetailScreenState extends ConsumerState<RoutineDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _memoController;
  TimeOfDay? _selectedTime;
  final List<bool> _selectedDays = List.filled(7, false);
  String _currentAlarmSound = 'Morning Glory';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.routine.routineTitle);
    _memoController = TextEditingController(text: widget.routine.memo);
    _selectedTime = TimeOfDay(
        hour: widget.routine.startTime.hour,
        minute: widget.routine.startTime.minute);
    _currentAlarmSound = widget.routine.alarmSound;

    for (var day in widget.routine.days) {
      int dayIndex =
          ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"].indexOf(day);
      if (dayIndex != -1) _selectedDays[dayIndex] = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D2338),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "루틴 상세 보기",
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF2E9E9),
      body: Padding(
        padding:
            const EdgeInsets.only(top: 32, bottom: 32, left: 16, right: 16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "루틴 제목",
                  labelStyle: TextStyle(fontSize: 18),
                  focusedBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Color(0xFF0D2338)), // 네이비 색 테두리
                  ),
                ),
                maxLines: null,
              ),
              const SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "시간",
                    style: TextStyle(fontSize: 18),
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 16.0),
                    child: GestureDetector(
                      onTap: () async {
                        final TimeOfDay? pickedTime = await showTimePicker(
                            context: context, initialTime: _selectedTime!);
                        if (pickedTime != null) {
                          setState(() => _selectedTime = pickedTime);
                        }
                      },
                      child: Text(
                        _selectedTime!.format(context),
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 50),
              ToggleButtons(
                isSelected: _selectedDays,
                selectedColor: Colors.white,
                color: Colors.black,
                fillColor: const Color(0xFF0D2338),
                selectedBorderColor: const Color(0xFF0D2338),
                borderColor: Colors.grey,
                borderWidth: 1.0,
                borderRadius: BorderRadius.circular(0.0),
                onPressed: (int index) => setState(
                    () => _selectedDays[index] = !_selectedDays[index]),
                constraints: BoxConstraints(
                  minWidth: (MediaQuery.of(context).size.width - 64) /
                      7, // 64는 양쪽 패딩 합계
                ),
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text("일"),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text("월"),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text("화"),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text("수"),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text("목"),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text("금"),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text("토"),
                  ),
                ],
              ),
              const SizedBox(height: 50),
              TextField(
                controller: _memoController,
                decoration: const InputDecoration(
                  labelText: "메모",
                  labelStyle: TextStyle(fontSize: 18),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                ),
                style: const TextStyle(fontSize: 18),
                maxLines: null,
              ),
              const SizedBox(height: 50),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _updateRoutine,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D2338),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("수정하기"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateRoutine() async {
    if (_titleController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("경고"),
          content: const Text("루틴 제목을 입력해주세요"),
          actions: <Widget>[
            TextButton(
              child: const Text('확인'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    } else {
      final String routineTitle = _titleController.text;
      final String memo = _memoController.text;
      final String startTime =
          "${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}";

      final List<String?> days = _selectedDays
          .asMap()
          .entries
          .map((entry) => entry.value
              ? ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"][entry.key]
              : null)
          .where((day) => day != null)
          .toList();

      try {
        await RoutineApi().updateRoutine(
          widget.routine.id,
          routineTitle,
          startTime,
          days,
          _currentAlarmSound,
          memo,
        );
        ref.refresh(routineProvider);
        Navigator.pop(context);
      } catch (error) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("수정 실패"),
            content: Text("루틴 수정에 실패했습니다.: $error"),
            actions: <Widget>[
              TextButton(
                child: const Text('확인'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      }
    }
  }
}
