import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  String email;
  String nickname;
  DateTime? birth;
  String? answer;
  String? googleCalendarUrl;

  User({
    required this.email,
    required this.nickname,
    required this.birth,
    required this.answer,
    required this.googleCalendarUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
