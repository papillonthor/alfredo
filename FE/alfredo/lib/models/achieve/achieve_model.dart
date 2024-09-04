import 'package:json_annotation/json_annotation.dart';

part 'achieve_model.g.dart';

@JsonSerializable()
class Achieve {
  final int achieveId;
  final bool achieveOne;
  final bool achieveTwo;
  final bool achieveThree;
  final bool achieveFour;
  final bool achieveFive;
  final bool achieveSix;
  final bool achieveSeven;
  final bool achieveEight;
  final bool achieveNine;
  final DateTime? finishOne;
  final DateTime? finishTwo;
  final DateTime? finishThree;
  final DateTime? finishFour;
  final DateTime? finishFive;
  final DateTime? finishSix;
  final DateTime? finishSeven;
  final DateTime? finishEight;
  final DateTime? finishNine;

  Achieve({
    required this.achieveId,
    required this.achieveOne,
    required this.achieveTwo,
    required this.achieveThree,
    required this.achieveFour,
    required this.achieveFive,
    required this.achieveSix,
    required this.achieveSeven,
    required this.achieveEight,
    required this.achieveNine,
    this.finishOne,
    this.finishTwo,
    this.finishThree,
    this.finishFour,
    this.finishFive,
    this.finishSix,
    this.finishSeven,
    this.finishEight,
    this.finishNine,
  });

  // JSON 직렬화 메서드
  factory Achieve.fromJson(Map<String, dynamic> json) =>
      _$AchieveFromJson(json);
  Map<String, dynamic> toJson() => _$AchieveToJson(this);

  static DateTime? _fromJsonDate(String? date) =>
      date == null ? null : DateTime.parse(date);

  static String? _toJsonDate(DateTime? date) => date?.toIso8601String();
}
