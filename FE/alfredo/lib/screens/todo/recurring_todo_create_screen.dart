import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart'; // UUID 패키지 임포트
import '../../models/todo/todo_model.dart';
import '../../provider/todo/todo_provider.dart';
import '../../provider/achieve/achieve_provider.dart';

class RecurringTodoCreateScreen extends ConsumerStatefulWidget {
  const RecurringTodoCreateScreen({super.key});

  @override
  _RecurringTodoCreateScreenState createState() =>
      _RecurringTodoCreateScreenState();
}

class _RecurringTodoCreateScreenState
    extends ConsumerState<RecurringTodoCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(const Duration(days: 30));
  List<bool> daysOfWeek = List.filled(7, false);
  String todoTitle = '';
  String? todoContent = '';

  // UUID 생성 객체
  final Uuid uuid = const Uuid();

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    DateTime initialDate = isStart ? startDate : endDate;
    DateTime firstDate = DateTime.now();
    // lastDate를 현재 날짜로부터 90일 후로 설정
    DateTime lastDate = DateTime.now().add(const Duration(days: 90));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate, // 마지막 날짜 제한 적용
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
          // 시작 날짜 선택 후 종료 날짜가 시작 날짜 이전이면 종료 날짜를 시작 날짜와 같게 설정
          if (endDate.isBefore(startDate)) {
            endDate = startDate;
          }
        } else {
          endDate = picked;
        }
      });
    }
  }

  void _submitRecurringTodo() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      List<Todo> todosToCreate = [];
      DateTime currentDate = startDate;

      // UUID로 고유한 subIndex 생성
      final String subIndex = uuid.v4();

      while (currentDate.isBefore(endDate.add(const Duration(days: 1)))) {
        if (daysOfWeek[currentDate.weekday - 1]) {
          // 요일 선택에 맞는 날짜에만 할 일 생성
          final newTodo = Todo(
            todoTitle: todoTitle,
            todoContent: todoContent,
            dueDate: currentDate,
            subIndex: subIndex, // 공통된 subIndex 설정
            url: '', // 필요하다면 URL 추가
            place: '', // 필요하다면 장소 추가
          );
          todosToCreate.add(newTodo);
        }
        currentDate = currentDate.add(const Duration(days: 1));
      }

      // 할 일 목록을 데이터베이스 또는 서버에 전송
      final controller = ref.read(todoControllerProvider);
      try {
        await controller.createTodos(todosToCreate);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('할 일이 성공적으로 생성되었습니다.')));

        // 업적 체크 메서드 호출
        final achieveController = ref.read(achieveControllerProvider);
        await achieveController.checkTotalTodoAchieve();

        Navigator.pushReplacementNamed(context, '/main');
      } catch (error) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('할 일 생성에 실패했습니다: $error')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2E9E9), // 배경 색상 설정
      appBar: AppBar(
        title: const Text("반복 할 일 생성"),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        automaticallyImplyLeading: false,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            TextFormField(
              decoration: const InputDecoration(labelText: '제목'),
              onSaved: (value) => todoTitle = value ?? '',
              validator: (value) =>
                  value == null || value.isEmpty ? '제목을 입력해주세요' : null,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: '내용'),
              onSaved: (value) => todoContent = value,
              maxLines: 3,
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title:
                  Text('시작 날짜: ${DateFormat('yyyy-MM-dd').format(startDate)}'),
              onTap: () => _selectDate(context, true),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text('종료 날짜: ${DateFormat('yyyy-MM-dd').format(endDate)}'),
              onTap: () => _selectDate(context, false),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // 가로축 중앙 정렬
              children: <Widget>[
                ToggleButtons(
                  constraints: const BoxConstraints(
                      minHeight: 35.0, minWidth: 35.0), // 버튼 크기 조정
                  isSelected: daysOfWeek,
                  fillColor: const Color(0xFF0D2338), // 선택된 버튼의 배경색 설정
                  selectedColor: Colors.white, // 선택된 버튼의 글자색 설정
                  onPressed: (int index) {
                    setState(() {
                      daysOfWeek[index] = !daysOfWeek[index];
                    });
                  },
                  children: const <Widget>[
                    Text('월', style: TextStyle(fontSize: 15)), // 폰트 크기 조정
                    Text('화', style: TextStyle(fontSize: 15)),
                    Text('수', style: TextStyle(fontSize: 15)),
                    Text('목', style: TextStyle(fontSize: 15)),
                    Text('금', style: TextStyle(fontSize: 15)),
                    Text('토', style: TextStyle(fontSize: 15)),
                    Text('일', style: TextStyle(fontSize: 15)),
                  ],
                ),
              ],
            ),
            ElevatedButton(
              onPressed: _submitRecurringTodo,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D2338),
                foregroundColor: Colors.white,
              ),
              child: const Text('할 일 추가'),
            ),
          ],
        ),
      ),
    );
  }
}




// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:intl/intl.dart';
// import 'package:uuid/uuid.dart'; // UUID 패키지 임포트
// import '../../models/todo/todo_model.dart';
// import '../../provider/todo/todo_provider.dart';

// class RecurringTodoCreateScreen extends ConsumerStatefulWidget {
//   const RecurringTodoCreateScreen({super.key});

//   @override
//   _RecurringTodoCreateScreenState createState() =>
//       _RecurringTodoCreateScreenState();
// }

// class _RecurringTodoCreateScreenState
//     extends ConsumerState<RecurringTodoCreateScreen> {
//   final _formKey = GlobalKey<FormState>();
//   DateTime startDate = DateTime.now();
//   DateTime endDate = DateTime.now().add(const Duration(days: 30));
//   List<bool> daysOfWeek = List.filled(7, false);
//   String todoTitle = '';
//   String? todoContent = '';

//   // UUID 생성 객체
//   final Uuid uuid = const Uuid();

//   Future<void> _selectDate(BuildContext context, bool isStart) async {
//     DateTime initialDate = isStart ? startDate : endDate;
//     DateTime firstDate = DateTime.now();
//     // lastDate를 현재 날짜로부터 90일 후로 설정
//     DateTime lastDate = DateTime.now().add(const Duration(days: 90));

//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: initialDate,
//       firstDate: firstDate,
//       lastDate: lastDate, // 마지막 날짜 제한 적용
//     );

//     if (picked != null) {
//       setState(() {
//         if (isStart) {
//           startDate = picked;
//           // 시작 날짜 선택 후 종료 날짜가 시작 날짜 이전이면 종료 날짜를 시작 날짜와 같게 설정
//           if (endDate.isBefore(startDate)) {
//             endDate = startDate;
//           }
//         } else {
//           endDate = picked;
//         }
//       });
//     }
//   }

//   void _submitRecurringTodo() {
//     if (_formKey.currentState!.validate()) {
//       _formKey.currentState!.save();

//       List<Todo> todosToCreate = [];
//       DateTime currentDate = startDate;

//       // UUID로 고유한 subIndex 생성
//       final String subIndex = uuid.v4();

//       while (currentDate.isBefore(endDate.add(const Duration(days: 1)))) {
//         if (daysOfWeek[currentDate.weekday - 1]) {
//           // 요일 선택에 맞는 날짜에만 할 일 생성
//           final newTodo = Todo(
//             todoTitle: todoTitle,
//             todoContent: todoContent,
//             dueDate: currentDate,
//             subIndex: subIndex, // 공통된 subIndex 설정
//             url: '', // 필요하다면 URL 추가
//             place: '', // 필요하다면 장소 추가
//           );
//           todosToCreate.add(newTodo);
//         }
//         currentDate = currentDate.add(const Duration(days: 1));
//       }

//       // 할 일 목록을 데이터베이스 또는 서버에 전송
//       final controller = ref.read(todoControllerProvider);
//       controller.createTodos(todosToCreate).then((_) {
//         ScaffoldMessenger.of(context)
//             .showSnackBar(const SnackBar(content: Text('할 일이 성공적으로 생성되었습니다.')));
//         Navigator.pushReplacementNamed(context, '/main');
//       }).catchError((error) {
//         ScaffoldMessenger.of(context)
//             .showSnackBar(SnackBar(content: Text('할 일 생성에 실패했습니다: $error')));
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("반복 할 일 생성"),
//         automaticallyImplyLeading: false,
//       ),
//       body: Form(
//         key: _formKey,
//         child: ListView(
//           padding: const EdgeInsets.all(16),
//           children: <Widget>[
//             TextFormField(
//               decoration: const InputDecoration(labelText: '제목'),
//               onSaved: (value) => todoTitle = value ?? '',
//               validator: (value) =>
//                   value == null || value.isEmpty ? '제목을 입력해주세요' : null,
//             ),
//             TextFormField(
//               decoration: const InputDecoration(labelText: '내용'),
//               onSaved: (value) => todoContent = value,
//               maxLines: 3,
//             ),
//             ListTile(
//               title:
//                   Text('시작 날짜: ${DateFormat('yyyy-MM-dd').format(startDate)}'),
//               onTap: () => _selectDate(context, true),
//             ),
//             ListTile(
//               title: Text('종료 날짜: ${DateFormat('yyyy-MM-dd').format(endDate)}'),
//               onTap: () => _selectDate(context, false),
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center, // 가로축 중앙 정렬
//               children: <Widget>[
//                 ToggleButtons(
//                   constraints: const BoxConstraints(
//                       minHeight: 35.0, minWidth: 35.0), // 버튼 크기 조정
//                   isSelected: daysOfWeek,
//                   onPressed: (int index) {
//                     setState(() {
//                       daysOfWeek[index] = !daysOfWeek[index];
//                     });
//                   },
//                   children: const <Widget>[
//                     Text('월', style: TextStyle(fontSize: 15)), // 폰트 크기 조정
//                     Text('화', style: TextStyle(fontSize: 15)),
//                     Text('수', style: TextStyle(fontSize: 15)),
//                     Text('목', style: TextStyle(fontSize: 15)),
//                     Text('금', style: TextStyle(fontSize: 15)),
//                     Text('토', style: TextStyle(fontSize: 15)),
//                     Text('일', style: TextStyle(fontSize: 15)),
//                   ],
//                 ),
//               ],
//             ),
//             ElevatedButton(
//               onPressed: _submitRecurringTodo,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF0D2338),
//                 foregroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10.0)),
//               ),
//               child: const Text('할 일 추가'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
