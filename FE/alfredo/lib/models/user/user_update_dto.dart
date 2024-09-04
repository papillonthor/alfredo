class UserUpdateDto {
  String? nickname;
  DateTime? birth;
  String? answer;
  String? googleCalendarUrl;

  UserUpdateDto(
      {this.nickname, this.birth, this.answer, this.googleCalendarUrl});

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {};
    if (nickname != null) data['nickname'] = nickname;
    if (birth != null) data['birth'] = birth!.toIso8601String();
    if (answer != null) data['answer'] = answer;
    if (googleCalendarUrl != null)
      data['googleCalendarUrl'] = googleCalendarUrl;
    return data;
  }
}
