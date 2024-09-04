// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Todo _$TodoFromJson(Map<String, dynamic> json) => Todo(
      id: (json['id'] as num?)?.toInt(),
      subIndex: json['subIndex'] as String?,
      todoTitle: json['todoTitle'] as String,
      todoContent: json['todoContent'] as String?,
      dueDate: Todo._fromJsonDateTime(json['dueDate'] as String),
      spentTime: (json['spentTime'] as num?)?.toInt(),
      isCompleted: json['isCompleted'] as bool? ?? false,
      url: json['url'] as String?,
      place: json['place'] as String?,
      uid: json['uid'] as String?,
    );

Map<String, dynamic> _$TodoToJson(Todo instance) => <String, dynamic>{
      'id': instance.id,
      'subIndex': instance.subIndex,
      'todoTitle': instance.todoTitle,
      'todoContent': instance.todoContent,
      'dueDate': Todo._toJsonDateTime(instance.dueDate),
      'spentTime': instance.spentTime,
      'isCompleted': instance.isCompleted,
      'url': instance.url,
      'place': instance.place,
      'uid': instance.uid,
    };
