// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Schedule _$ScheduleFromJson(Map<String, dynamic> json) => Schedule(
      scheduleId: (json['scheduleId'] as num?)?.toInt(),
      scheduleTitle: json['scheduleTitle'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      startAlarm: json['startAlarm'] as bool? ?? false,
      place: json['place'] as String?,
      startTime: Schedule._timeFromString(json['startTime'] as String?),
      endTime: Schedule._timeFromString(json['endTime'] as String?),
      alarmTime: Schedule._timeFromString(json['alarmTime'] as String?),
      alarmDate: json['alarmDate'] == null
          ? null
          : DateTime.parse(json['alarmDate'] as String),
      withTime: json['withTime'] as bool? ?? true,
    );

Map<String, dynamic> _$ScheduleToJson(Schedule instance) => <String, dynamic>{
      'scheduleId': instance.scheduleId,
      'scheduleTitle': instance.scheduleTitle,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'startAlarm': instance.startAlarm,
      'place': instance.place,
      'startTime': Schedule._stringFromTime(instance.startTime),
      'endTime': Schedule._stringFromTime(instance.endTime),
      'alarmTime': Schedule._stringFromTime(instance.alarmTime),
      'alarmDate': instance.alarmDate?.toIso8601String(),
      'withTime': instance.withTime,
    };
