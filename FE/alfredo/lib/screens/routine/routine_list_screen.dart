import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../api/routine/routine_api.dart';
import '../../provider/routine/routine_provider.dart';
import '../../screens/routine/routine_detail_screen.dart';

class RoutineListScreen extends ConsumerStatefulWidget {
  const RoutineListScreen({super.key});

  @override
  _RoutineListScreenState createState() => _RoutineListScreenState();
}

class _RoutineListScreenState extends ConsumerState<RoutineListScreen> {
  final routineApi = RoutineApi();

  @override
  Widget build(BuildContext context) {
    final routines = ref.watch(routineProvider);
    final screenWidth = MediaQuery.of(context).size.width; // 화면 크기 얻어오기
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D2338),
        title: const Padding(
          padding: EdgeInsets.only(top: 16.0, left: 8),
          child: Text(
            "루틴 리스트",
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
        ),
      ),
      backgroundColor: const Color(0xFF0D2338),
      body: routines.when(
        data: (data) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10, left: 32.0),
                child: Text(
                  '${data.length}개',
                  style: const TextStyle(color: Colors.grey),
                  textAlign: TextAlign.left,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final routine = data[index];
                    return Dismissible(
                      key: Key(routine.id
                          .toString()), // Provide a unique key for each item
                      background: Container(
                        color: Colors.red,
                        child: const Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: EdgeInsets.only(right: 20.0),
                            child: Icon(Icons.delete, color: Colors.white),
                          ),
                        ),
                      ),
                      onDismissed: (direction) async {
                        await routineApi.deleteRoutine(routine.id);
                        setState(() {
                          data.removeAt(index);
                        });
                        ref.refresh(routineProvider);
                      },
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RoutineDetailScreen(
                              routine: routine,
                            ),
                          ),
                        ),
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 6.0),
                          color: const Color(0xFFF2E9E9),
                          child: ListTile(
                            leading: const Icon(Icons.event_note,
                                color: Colors.grey),
                            title: Text(
                              routine.routineTitle,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Row(
                              children: [
                                Wrap(
                                  spacing: 4.0,
                                  children: _buildDayWidgets(routine.days),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  formatTimeOfDay(routine.startTime),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const CircularProgressIndicator(),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  List<Widget> _buildDayWidgets(Set<String> days) {
    const allDays = ["일", "월", "화", "수", "목", "금", "토"];
    const allDaysShort = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];

    return List<Widget>.generate(7, (index) {
      final day = allDays[index];
      final dayShort = allDaysShort[index];
      final isSelected = days.contains(dayShort);
      return Text(
        day,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.black : Colors.grey,
          fontSize: 12,
        ),
      );
    });
  }

  String formatTimeOfDay(TimeOfDay tod) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    final format = DateFormat.jm(); // Use 'jm' for AM/PM format
    return format.format(dt);
  }
}
