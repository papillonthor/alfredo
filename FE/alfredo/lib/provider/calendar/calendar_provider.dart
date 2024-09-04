// ignore_for_file: unused_import

import 'dart:convert';
import 'dart:core';

import 'package:alfredo/models/schedule/schedule_model.dart';
import 'package:alfredo/models/todo/todo_model.dart';
import 'package:alfredo/models/user/user.dart';
import 'package:alfredo/provider/schedule/schedule_provider.dart';
import 'package:alfredo/provider/todo/todo_provider.dart';
import 'package:alfredo/provider/user/user_state_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:icalendar_parser/icalendar_parser.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

DateTime? lastModified;
final loadSchedule = Provider((ref) {
  final scheduleController = ref.read(scheduleControllerProvider);

  var fetchedSchedule = scheduleController.getSchedules();
  return fetchedSchedule;
});

final loadTodo = Provider((ref) {
  final todoController = ref.read(todoControllerProvider);

  var fetchedTodos = todoController.fetchTodoList();
  return fetchedTodos;
});

DateTime combineDateTimeAndTimeOfDay(DateTime date, TimeOfDay time) {
  return DateTime(date.year, date.month, date.day, time.hour, time.minute);
}

final loadScheduleData = FutureProvider<List<Appointment>>((ref) async {
  final List<Appointment> appointments = <Appointment>[];
  var fetchedSchedule = await ref.watch(loadSchedule);
  // var fetchedSchedule = await scheduleController.getSchedules();
  for (Schedule _schedule in fetchedSchedule) {
    if (_schedule.withTime) {
      appointments.add(
        Appointment(
          startTime: _schedule.startDate,
          endTime: _schedule.endDate ?? _schedule.startDate,
          isAllDay: true,
          subject: _schedule.scheduleTitle,
          save_type: 'schedule',
          params: _schedule.scheduleId.toString(),
          color: const Color(0xFFe7d8bc),
        ),
      );
    } else {
      if (_schedule.startDate == _schedule.endDate!) {
        DateTime starttime = combineDateTimeAndTimeOfDay(
            _schedule.startDate, _schedule.startTime!);
        DateTime endtime =
            combineDateTimeAndTimeOfDay(_schedule.endDate!, _schedule.endTime!);
        appointments.add(
          Appointment(
            startTime: starttime,
            endTime: endtime,
            subject: _schedule.scheduleTitle,
            save_type: 'schedule',
            params: _schedule.scheduleId.toString(),
            color: const Color(0xFFe7d8bc),
          ),
        );
      } else {
        appointments.add(
          Appointment(
            startTime: _schedule.startDate,
            endTime: _schedule.endDate!,
            isAllDay: true,
            subject: _schedule.scheduleTitle,
            save_type: 'schedule',
            params: _schedule.scheduleId.toString(),
            color: const Color(0xFFe7d8bc),
          ),
        );
      }
    }
  }
  // print('loadSchedule : $appointments');
  return appointments;
});

final loadTodoData = FutureProvider<List<Appointment>>((ref) async {
  final List<Appointment> appointments = <Appointment>[];
  var fetchedTodos = await ref.watch(loadTodo);
  for (Todo _todo in fetchedTodos) {
    appointments.add(
      Appointment(
        startTime: _todo.dueDate,
        endTime: _todo.dueDate,
        isAllDay: true,
        subject: _todo.todoTitle,
        save_type: 'todo',
        params: _todo.id.toString(),
        color: const Color(0xFFD6C3C3),
      ),
    );
  }
  // print('loadTodos : $appointments');
  return appointments;
});

final loadiCalendar =
    FutureProvider.family<List<Appointment>?, User>((ref, userState) async {
  // ignore: await_only_futures
  ICalendar? iCalendar;
  Map? iCalendarJson;

  final List<Appointment> appointments = <Appointment>[];
  bool flag = false;
  Future<void> getCalendarDataSource(Map? iCalendarJson) async {
    if (iCalendarJson != null) {
      for (Map? datas in iCalendarJson['data']) {
        if (datas!['dtstart'] != null) {
          // print(datas);
          DateTime startDateTime = DateTime.parse(datas['dtstart']['dt']);
          DateTime endDateTime = DateTime.parse(datas['dtend']['dt']);
          if (startDateTime.hour == 0 &&
              startDateTime.minute == 0 &&
              startDateTime.second == 0 &&
              endDateTime.hour == 0 &&
              endDateTime.minute == 0 &&
              endDateTime.second == 0) {
            appointments.add(Appointment(
              startTime: startDateTime,
              endTime: endDateTime.subtract(const Duration(days: 1)),
              save_type: 'iCal',
              isAllDay: true,
              subject: datas['summary'] ?? '(제목 없음)',
            ));
          } else {
            appointments.add(Appointment(
              startTime: startDateTime,
              endTime: endDateTime,
              save_type: 'iCal',
              subject: datas['summary'] ?? '(제목 없음)',
            ));
          }
        }
        if (datas['lastModified'] != null) {
          if (lastModified != null &&
              flag == false &&
              lastModified!
                  .isBefore(DateTime.parse(datas['lastModified']['dt']))) {
            if (datas['lastModified'] != null) {
              lastModified = DateTime.parse(datas['lastModified']['dt']);
            }
            flag = true;
            // ignore: prefer_conditional_assignment
          } else if (lastModified == null) {
            lastModified = DateTime.parse(datas['lastModified']['dt']);
            flag = true;
          }
        }
      }
    }
    if (flag) {
      // print('loadiCalendarData :');
      // print(appointments);
    }
  }

  bool isValidUtf8(List<int> bytes) {
    try {
      utf8.decode(bytes, allowMalformed: false);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> loadiCalendarData(String iCalUrl) async {
    try {
      final response = await http.get(Uri.parse(iCalUrl));
      if (response.statusCode == 200) {
        final icsString = response.body;
        iCalendar = ICalendar.fromString(icsString);
        List<int> bytes = iCalendar.toString().codeUnits;

        if (isValidUtf8(bytes)) {
          String decodedSummary = utf8.decode(bytes);
          iCalendarJson = jsonDecode(decodedSummary);
        } else {
          iCalendarJson = iCalendar!.toJson();
        }
        await getCalendarDataSource(iCalendarJson);
        // print("aaa");
      } else {
        throw Exception('Failed to load iCal data');
      }
    } catch (error) {
      print('Error fetching iCal data: $error');
      // 오류 처리를 원하는 대로 수행하세요.
    }
  }

  if (userState.googleCalendarUrl != '' ||
      userState.googleCalendarUrl != null) {
    await loadiCalendarData(userState.googleCalendarUrl!);
    return appointments;
  }
  return null;
});
