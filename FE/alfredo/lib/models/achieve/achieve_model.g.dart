// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achieve_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Achieve _$AchieveFromJson(Map<String, dynamic> json) => Achieve(
      achieveId: (json['achieveId'] as num).toInt(),
      achieveOne: json['achieveOne'] as bool,
      achieveTwo: json['achieveTwo'] as bool,
      achieveThree: json['achieveThree'] as bool,
      achieveFour: json['achieveFour'] as bool,
      achieveFive: json['achieveFive'] as bool,
      achieveSix: json['achieveSix'] as bool,
      achieveSeven: json['achieveSeven'] as bool,
      achieveEight: json['achieveEight'] as bool,
      achieveNine: json['achieveNine'] as bool,
      finishOne: json['finishOne'] == null
          ? null
          : DateTime.parse(json['finishOne'] as String),
      finishTwo: json['finishTwo'] == null
          ? null
          : DateTime.parse(json['finishTwo'] as String),
      finishThree: json['finishThree'] == null
          ? null
          : DateTime.parse(json['finishThree'] as String),
      finishFour: json['finishFour'] == null
          ? null
          : DateTime.parse(json['finishFour'] as String),
      finishFive: json['finishFive'] == null
          ? null
          : DateTime.parse(json['finishFive'] as String),
      finishSix: json['finishSix'] == null
          ? null
          : DateTime.parse(json['finishSix'] as String),
      finishSeven: json['finishSeven'] == null
          ? null
          : DateTime.parse(json['finishSeven'] as String),
      finishEight: json['finishEight'] == null
          ? null
          : DateTime.parse(json['finishEight'] as String),
      finishNine: json['finishNine'] == null
          ? null
          : DateTime.parse(json['finishNine'] as String),
    );

Map<String, dynamic> _$AchieveToJson(Achieve instance) => <String, dynamic>{
      'achieveId': instance.achieveId,
      'achieveOne': instance.achieveOne,
      'achieveTwo': instance.achieveTwo,
      'achieveThree': instance.achieveThree,
      'achieveFour': instance.achieveFour,
      'achieveFive': instance.achieveFive,
      'achieveSix': instance.achieveSix,
      'achieveSeven': instance.achieveSeven,
      'achieveEight': instance.achieveEight,
      'achieveNine': instance.achieveNine,
      'finishOne': instance.finishOne?.toIso8601String(),
      'finishTwo': instance.finishTwo?.toIso8601String(),
      'finishThree': instance.finishThree?.toIso8601String(),
      'finishFour': instance.finishFour?.toIso8601String(),
      'finishFive': instance.finishFive?.toIso8601String(),
      'finishSix': instance.finishSix?.toIso8601String(),
      'finishSeven': instance.finishSeven?.toIso8601String(),
      'finishEight': instance.finishEight?.toIso8601String(),
      'finishNine': instance.finishNine?.toIso8601String(),
    };
