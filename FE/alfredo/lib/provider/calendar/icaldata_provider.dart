import 'package:alfredo/models/user/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import 'calendar_provider.dart';

final iCalProvider =
    FutureProvider.family<List<Appointment>, User>((ref, userState) async {
  final List<Appointment> appointments = <Appointment>[];
  var scheduleData = ref.watch(loadScheduleData);
  scheduleData.when(
      data: (data) => {appointments.addAll(data)},
      error: (err, stack) => {},
      loading: () {});
  var todoData = ref.watch(loadTodoData);
  todoData.when(
      data: (data) => {appointments.addAll(data)},
      error: (err, stack) => {},
      loading: () {});
  var iCalendarData = ref.watch(loadiCalendar(userState));
  iCalendarData.when(
      // ignore: unnecessary_null_comparison
      data: (data) {
        if (data != null) {
          // print('iCal데이타 반환에 성공했습니다. $data');
          appointments.addAll(data);
        }
      },
      error: (err, stack) => {},
      loading: () {});

  return appointments;
});
