// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routine_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Routine _$RoutineFromJson(Map<String, dynamic> json) => Routine(
      id: (json['id'] as num).toInt(),
      routineTitle: json['routineTitle'] as String,
      startTime: Routine._timeFromString(json['startTime'] as String?),
      days: (json['days'] as List<dynamic>).map((e) => e as String).toSet(),
      alarmSound: json['alarmSound'] as String,
      memo: json['memo'] as String?,
      basicRoutineId: (json['basicRoutineId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$RoutineToJson(Routine instance) => <String, dynamic>{
      'id': instance.id,
      'routineTitle': instance.routineTitle,
      'startTime': Routine._stringFromTime(instance.startTime),
      'days': instance.days.toList(),
      'alarmSound': instance.alarmSound,
      'memo': instance.memo,
      'basicRoutineId': instance.basicRoutineId,
    };
