import 'dart:core';

import 'package:alfredo/provider/calendar/icaldata_provider.dart';
import 'package:alfredo/provider/user/user_state_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../screens/todo/todo_detail_screen.dart';
import '../schedule/schedule_edit_screen.dart';

class Calendar extends ConsumerStatefulWidget {
  const Calendar({super.key});

  @override
  _Calendar createState() => _Calendar();
}

class _Calendar extends ConsumerState<Calendar> {
  var userData;
  final List<Appointment> appointments = <Appointment>[];
  double screenHeight = 0.0;
  bool _isDragging = false;
  final CalendarController _controller = CalendarController();
  // ignore: prefer_const_constructors, prefer_final_fields
  MonthViewSettings _monthViewSettings = MonthViewSettings(
    appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
    showTrailingAndLeadingDates: false,
  );

  @override
  void initState() {
    super.initState();
  }

  // SharedPreferences에 iCalendar 데이터를 비교 하는 함수
  Future<bool> compareLastModified(String lastModifiedData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedlastModified = prefs.getString('lastModified');
    if (DateTime.parse(savedlastModified!)
        .isAtSameMomentAs(DateTime.parse(lastModifiedData))) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    screenHeight = MediaQuery.of(context).size.height;
    return userState.when(
        data: (data) {
          final iCalDatas = ref.watch(iCalProvider(data));
          return iCalDatas.when(
              data: (data) {
                return Scaffold(
                  resizeToAvoidBottomInset: false,
                  appBar: PreferredSize(
                    preferredSize: const Size.fromHeight(0), // AppBar의 높이 설정
                    child: AppBar(),
                  ),
                  body: GestureDetector(
                    onVerticalDragUpdate: calendarDarged,
                    onVerticalDragEnd: calendarDragEnd,
                    child: SfCalendar(
                      view: CalendarView.month,
                      allowedViews: const <CalendarView>[
                        CalendarView.day,
                        CalendarView.week,
                        CalendarView.workWeek,
                        CalendarView.month,
                        CalendarView.schedule
                      ],
                      showTodayButton: true,
                      showDatePickerButton: true,
                      controller: _controller,
                      initialSelectedDate: DateTime.now(),
                      dataSource: _DataSource(data),
                      onTap: calendarTapped,
                      monthViewSettings: _monthViewSettings,
                    ),
                  ),
                );
              },
              error: (err, stack) => Text('Error: $err'),
              loading: () => const CircularProgressIndicator());
        },
        error: (err, stack) => Text('Error: $err'),
        loading: () => const CircularProgressIndicator());
  }

  @override
  void didUpdateWidget(covariant Calendar oldWidget) {
    print(oldWidget);
    super.didUpdateWidget(oldWidget);
    // 여기에서 oldWidget을 사용하여 이전 위젯의 정보에 접근할 수 있습니다.
  }

  void calendarTapped(CalendarTapDetails calendarTapDetails) async {
    if (_controller.view == CalendarView.month &&
        calendarTapDetails.targetElement == CalendarElement.calendarCell &&
        !_monthViewSettings.showAgenda) {
      setState(() {
        detailMonthCalendar();
      });
    }
    if (calendarTapDetails.targetElement == CalendarElement.appointment) {
      if (calendarTapDetails.appointments![0].save_type == 'todo') {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return TodoDetailScreen(
                todoId: int.parse(calendarTapDetails.appointments![0].params));
          },
        );
      } else if (calendarTapDetails.appointments![0].save_type == 'schedule') {
        var result = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ScheduleEditScreen(
                  scheduleId:
                      int.parse(calendarTapDetails.appointments![0].params))),
        );
      }
    }
  }

  void calendarDarged(DragUpdateDetails details) {
    if (!_isDragging) {
      _isDragging = true;
      if (details.delta.dy > screenHeight / 100) {
        if (_monthViewSettings.numberOfWeeksInView == 6) {
          monthCalendar();
        } else if (_monthViewSettings.numberOfWeeksInView == 1) {
          detailMonthCalendar();
        }
      } else if (details.delta.dy < -screenHeight / 100) {
        if (!_monthViewSettings.showAgenda) {
          detailMonthCalendar();
        } else if (_monthViewSettings.appointmentDisplayMode !=
            MonthAppointmentDisplayMode.appointment) {
          detailWeekCalendar();
        }
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {});
      });
      setState(() {});
    }
  }

  Future<void> calendarDragEnd(DragEndDetails details) async {
    _isDragging = false;
  }

  Future<void> monthCalendar() async {
    _monthViewSettings = const MonthViewSettings(
      showAgenda: false,
      appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
      showTrailingAndLeadingDates: false,
    );
  }

  Future<void> detailMonthCalendar() async {
    // ignore: no_leading_underscores_for_local_identifiers
    _monthViewSettings = MonthViewSettings(
      showAgenda: true,
      showTrailingAndLeadingDates: false,
      agendaViewHeight: screenHeight / 4.05,
    );
  }

  Future<void> detailWeekCalendar() async {
    // ignore: prefer_const_constructors
    _monthViewSettings = MonthViewSettings(
      showAgenda: true,
      showTrailingAndLeadingDates: false,
      numberOfWeeksInView: 1,
      agendaViewHeight: screenHeight / 1.4,
    );
  }
}

class _DataSource extends CalendarDataSource {
  _DataSource(this.source);

  List<Appointment> source;

  @override
  List<dynamic> get appointments => source;
}
