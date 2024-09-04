import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'routine_model.g.dart'; // 자동 생성될 파일 이름

@JsonSerializable()
class Routine {
  int id;

  String routineTitle;
  @JsonKey(fromJson: _timeFromString, toJson: _stringFromTime)
  TimeOfDay startTime;

  Set<String> days;

  String alarmSound;

  String? memo;

  int? basicRoutineId; // 기본 루틴 ID 추가

  Routine({
    required this.id,
    required this.routineTitle,
    required this.startTime,
    required this.days,
    required this.alarmSound,
    this.memo,
    this.basicRoutineId, // 기본 루틴 ID 추가ㄴ
  });

  // JSON 생성 및 해석을 위한 팩토리 메서드
  factory Routine.fromJson(Map<String, dynamic> json) =>
      _$RoutineFromJson(json);
  Map<String, dynamic> toJson() => _$RoutineToJson(this);

  static TimeOfDay _timeFromString(String? timeStr) {
    if (timeStr == null) return const TimeOfDay(hour: 0, minute: 0);
    final timeParts = timeStr.split(':').map(int.parse).toList();
    return TimeOfDay(hour: timeParts[0], minute: timeParts[1]);
  }

  static String _stringFromTime(TimeOfDay? time) {
    if (time == null) return '';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';
  }
}
