import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/routine/routine_api.dart';
import '../../provider/achieve/achieve_provider.dart';
import '../../provider/routine/routine_provider.dart';
import '../../provider/user/future_provider.dart';

class RoutineCreateScreen extends ConsumerWidget {
  const RoutineCreateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _RoutineCreateScreenBody(ref: ref);
  }
}

class _RoutineCreateScreenBody extends StatefulWidget {
  final WidgetRef ref;

  const _RoutineCreateScreenBody({super.key, required this.ref});

  @override
  _RoutineCreateScreenState createState() =>
      _RoutineCreateScreenState(ref: ref);
}

class _RoutineCreateScreenState extends State<_RoutineCreateScreenBody> {
  final WidgetRef ref;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController memoController = TextEditingController();
  final RoutineApi routineApi = RoutineApi();
  TimeOfDay? selectedTime = const TimeOfDay(hour: 7, minute: 30);
  List<bool> selectedDays = [false, true, true, true, true, true, false];
  String currentAlarmSound = "Morning Glory";
  int? basicRoutineId; // 기본 루틴 ID를 저장할 변수 추가
  String? selectedCategory; // 선택된 카테고리를 저장할 변수 추가

  _RoutineCreateScreenState({required this.ref});

  // 카테고리와 기본 루틴 ID를 매핑하는 맵
  final Map<String, int> categoryToId = {
    "기상": 1,
    "명상": 2,
    "모닝커피": 3,
    "공부": 4,
    "운동": 5,
    "독서": 6,
    "샤워": 7,
    "스트레칭": 8,
    "취침": 9,
  };

  Future<void> _fetchBasicRoutine(int basicRoutineId) async {
    try {
      final basicRoutine = await routineApi.fetchBasicRoutine(basicRoutineId);
      setState(() {
        titleController.text = basicRoutine.routineTitle;
        selectedTime = TimeOfDay(
          hour: basicRoutine.startTime.hour,
          minute: basicRoutine.startTime.minute,
        );
        selectedDays = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
            .map((day) => basicRoutine.days.contains(day))
            .toList();
        memoController.text = basicRoutine.memo ?? ''; // null이면 빈 문자열로 설정
        this.basicRoutineId = basicRoutine.id; // 기본 루틴 ID 저장
        selectedCategory = categoryToId.keys
            .firstWhere((k) => categoryToId[k] == basicRoutineId);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch routine: $e')),
      );
    }
  }

  Future<void> _saveRoutine() async {
    if (titleController.text.isEmpty) {
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
      try {
        final String? idToken = await ref.watch(authManagerProvider.future);
        final routineTitle = titleController.text;
        final hour = selectedTime!.hour.toString().padLeft(2, '0');
        final minute = selectedTime!.minute.toString().padLeft(2, '0');

        final startTime = '$hour:$minute:00';
        final days = selectedDays
            .asMap()
            .entries
            .map((e) => e.value
                ? ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"][e.key]
                : "")
            .where((d) => d.isNotEmpty)
            .toList();

        final memo = memoController.text;

        // 루틴 생성
        await routineApi.createRoutine(
          idToken,
          routineTitle,
          startTime,
          days,
          currentAlarmSound,
          memo,
          basicRoutineId,
        );

        // 루틴 데이터를 새로고침
        ref.refresh(routineProvider);

        // 4번째 업적 조회
        final achieveController = ref.read(achieveControllerProvider);
        await achieveController.checkTotalRoutineAchieve();

        // 화면 종료
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save routine: $e')),
        );
      }
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
          "루틴 생성",
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
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: categoryToId.keys.map((category) {
                    return _buildCategoryBadge(
                        category, categoryToId[category]!);
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: "루틴 제목",
                  labelStyle: TextStyle(fontSize: 18),
                  focusedBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Color(0xFF0D2338)), // 네이비 색 테두리
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '루틴 제목을 입력해주세요';
                  }
                  return null;
                },
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
                    margin: const EdgeInsets.only(right: 16.0), // 원하는 margin 설정
                    child: GestureDetector(
                      onTap: () async {
                        final TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: selectedTime!,
                        );
                        if (pickedTime != null) {
                          setState(() => selectedTime = pickedTime);
                        }
                      },
                      child: Text(
                        selectedTime!.format(context),
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 50),
              ToggleButtons(
                isSelected: selectedDays,
                selectedColor: Colors.white, // 선택된 항목의 텍스트 색상
                color: Colors.black, // 선택되지 않은 항목의 텍스트 색상
                fillColor: const Color(0xFF0D2338), // 선택된 항목의 배경색
                selectedBorderColor: const Color(0xFF0D2338), // 선택된 항목의 테두리 색상
                borderColor: Colors.grey, // 선택되지 않은 항목의 테두리 색상
                borderWidth: 1.0,
                borderRadius: BorderRadius.circular(0.0),
                onPressed: (int index) =>
                    setState(() => selectedDays[index] = !selectedDays[index]),
                constraints: BoxConstraints(
                  minWidth: (MediaQuery.of(context).size.width - 64) /
                      7, // 64는 양쪽 패딩 합계
                ), // 테두리 모서리 둥글기
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
                controller: memoController,
                decoration: const InputDecoration(
                  labelText: "메모",
                  labelStyle: TextStyle(fontSize: 18),
                  contentPadding: EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 12.0), // 텍스트 필드 내부 패딩 설정
                ),
                style: const TextStyle(fontSize: 18), // 입력 텍스트 크기 설정
                maxLines: null, // 줄바꿈 허용
              ),
              const SizedBox(height: 50),
              SizedBox(
                width: double.infinity, // 버튼의 가로 크기를 전체로 설정
                child: ElevatedButton(
                  onPressed: _saveRoutine,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D2338), // 버튼 배경색
                    foregroundColor: Colors.white, // 버튼 텍스트 색
                  ),
                  child: const Text("저장"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryBadge(String title, int basicRoutineId) {
    return GestureDetector(
      onTap: () => _fetchBasicRoutine(basicRoutineId),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        decoration: BoxDecoration(
          color: selectedCategory == title
              ? const Color.fromARGB(255, 127, 128, 129)
              : const Color.fromARGB(255, 222, 217, 217),
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Text(title, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
