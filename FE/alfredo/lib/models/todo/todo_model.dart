import 'package:json_annotation/json_annotation.dart';

part 'todo_model.g.dart';

@JsonSerializable()
class Todo {
  int? id;
  String? subIndex;
  String todoTitle;
  String? todoContent;
  @JsonKey(fromJson: _fromJsonDateTime, toJson: _toJsonDateTime)
  DateTime dueDate;
  int? spentTime;
  bool isCompleted;
  String? url;
  String? place;
  String? uid; // 사용자 고유 ID 필드 추가

  Todo({
    this.id,
    this.subIndex,
    required this.todoTitle,
    this.todoContent,
    required this.dueDate,
    this.spentTime,
    this.isCompleted = false,
    this.url,
    this.place,
    this.uid,
  });

  factory Todo.fromJson(Map<String, dynamic> json) => _$TodoFromJson(json);
  Map<String, dynamic> toJson() => _$TodoToJson(this);

  static DateTime _fromJsonDateTime(String date) => DateTime.parse(date);
  static String _toJsonDateTime(DateTime date) => date.toIso8601String();

  // copyWith 메소드 추가
  Todo copyWith({
    int? id,
    String? subIndex,
    String? todoTitle,
    String? todoContent,
    DateTime? dueDate,
    int? spentTime,
    bool? isCompleted,
    String? url,
    String? place,
    String? uid,
  }) {
    return Todo(
      id: id ?? this.id,
      subIndex: subIndex ?? this.subIndex,
      todoTitle: todoTitle ?? this.todoTitle,
      todoContent: todoContent ?? this.todoContent,
      dueDate: dueDate ?? this.dueDate,
      spentTime: spentTime ?? this.spentTime,
      isCompleted: isCompleted ?? this.isCompleted,
      url: url ?? this.url,
      place: place ?? this.place,
      uid: uid ?? this.uid,
    );
  }
}
