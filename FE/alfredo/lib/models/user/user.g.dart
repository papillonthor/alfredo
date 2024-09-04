// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      email: json['email'] as String,
      nickname: json['nickname'] as String,
      birth: json['birth'] == null
          ? null
          : DateTime.parse(json['birth'] as String),
      answer: json['answer'] as String?,
      googleCalendarUrl: json['googleCalendarUrl'] as String?,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'email': instance.email,
      'nickname': instance.nickname,
      'birth': instance.birth?.toIso8601String(),
      'answer': instance.answer,
      'googleCalendarUrl': instance.googleCalendarUrl,
    };
