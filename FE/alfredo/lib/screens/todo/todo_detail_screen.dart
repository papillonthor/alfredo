import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/todo/todo_model.dart';
import '../../controller/todo/todo_controller.dart';
import '../../provider/todo/todo_provider.dart';
import '../../api/todo/todo_api.dart';
import '../todo/todo_timer_screen.dart';

class TodoDetailScreen extends StatefulWidget {
  final int todoId;
  const TodoDetailScreen({super.key, required this.todoId});

  @override
  _TodoDetailScreenState createState() => _TodoDetailScreenState();
}

class _TodoDetailScreenState extends State<TodoDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2E9E9), // 배경 색상 설정
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D2338), // 남색 배경
        title: const Text('할 일 상세',
            style: TextStyle(color: Colors.white)), // 흰색 텍스트
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: const Color(0xFFF2E9E9), // 배경 색상 설정
        padding: const EdgeInsets.all(16),
        child: Consumer(
          builder: (context, ref, _) {
            return FutureBuilder<Todo>(
              future:
                  ref.read(todoControllerProvider).fetchTodoById(widget.todoId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                      child: Text('오류: ${snapshot.error.toString()}'));
                } else if (snapshot.hasData) {
                  return TodoDetailForm(
                      todo: snapshot.data!,
                      todoController: ref.read(todoControllerProvider));
                } else {
                  return const Center(child: Text('데이터를 불러올 수 없습니다.'));
                }
              },
            );
          },
        ),
      ),
    );
  }
}

class TodoDetailForm extends StatefulWidget {
  final Todo todo;
  final TodoController todoController;
  const TodoDetailForm(
      {super.key, required this.todo, required this.todoController});

  @override
  _TodoDetailFormState createState() => _TodoDetailFormState();
}

class _TodoDetailFormState extends State<TodoDetailForm> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _urlController;
  late TextEditingController _placeController;
  late int _spentTime;
  late DateTime _dueDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo.todoTitle);
    _contentController = TextEditingController(text: widget.todo.todoContent);
    _urlController = TextEditingController(text: widget.todo.url);
    _placeController = TextEditingController(text: widget.todo.place);
    _spentTime = widget.todo.spentTime ?? 0; // _spentTime 초기화
    _dueDate = widget.todo.dueDate;
  }

  @override
  void didUpdateWidget(covariant TodoDetailForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.todo.spentTime != oldWidget.todo.spentTime) {
      setState(() {
        _spentTime = widget.todo.spentTime ?? 0;
      });
    }
  }

  void _navigateAndDisplaySelection(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              TodoTimerScreen(initialTimeInSeconds: _spentTime)),
    );

    // TodoTimerScreen에서 반환된 결과가 null이 아니고, int 형식인지 확인하고, 위젯이 아직 마운트된 상태인지 확인
    if (result != null && result is int && mounted) {
      setState(() {
        _spentTime = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: ListView(
        children: <Widget>[
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: '제목'),
          ),
          TextFormField(
            controller: _contentController,
            decoration: const InputDecoration(labelText: '내용'),
            maxLines: 3,
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: Text('마감 기한: ${DateFormat('yyyy-MM-dd').format(_dueDate)}'),
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: _dueDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 90)),
              );
              if (picked != null && picked != _dueDate) {
                setState(() {
                  _dueDate = picked;
                });
              }
            },
          ),
          TextFormField(
            controller: _urlController,
            decoration: const InputDecoration(labelText: 'URL'),
          ),
          TextFormField(
            controller: _placeController,
            decoration: const InputDecoration(labelText: '장소'),
          ),
          ListTile(
            leading: const Icon(Icons.access_time),
            title: Text(
                '소요 시간: ${_spentTime ~/ 3600}시간 ${(_spentTime % 3600) ~/ 60}분 ${_spentTime % 60}초'),
            onTap: () => _navigateAndDisplaySelection(context),
          ),
          const SizedBox(height: 70),
          ElevatedButton(
            onPressed: () => showDialog(
                context: context,
                builder: (context) => _updateTodoDialog(context)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D2338),
              foregroundColor: Colors.white,
            ),
            child: const Text('할 일 수정'),
          ),
          ElevatedButton(
            onPressed: () => showDialog(
                context: context,
                builder: (context) => _deleteTodoDialog(context)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D2338),
              foregroundColor: Colors.white,
            ),
            child: const Text('삭제'),
          )
        ],
      ),
    );
  }

  Widget _updateTodoDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('할 일 수정'),
      content: const Text('원하는 수정 방식을 선택하세요.'),
      actions: <Widget>[
        TextButton(
          onPressed: () async {
            final updatedTodo = Todo(
              id: widget.todo.id,
              todoTitle: _titleController.text,
              todoContent: _contentController.text,
              dueDate: _dueDate,
              url: _urlController.text,
              place: _placeController.text,
              spentTime: _spentTime,
              isCompleted: widget.todo.isCompleted,
            );
            await widget.todoController.updateTodo(updatedTodo);
            Navigator.pushReplacementNamed(context, '/main');
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('변경 사항이 저장되었습니다.')));
          },
          child: const Text('할 일 수정'),
        ),
        if (widget.todo.subIndex != null)
          TextButton(
            onPressed: () async {
              final updatedSubTodo = Todo(
                  subIndex: widget.todo.subIndex,
                  todoTitle: _titleController.text,
                  todoContent: _contentController.text,
                  dueDate: _dueDate,
                  url: _urlController.text,
                  place: _placeController.text,
                  spentTime: _spentTime,
                  isCompleted: widget.todo.isCompleted);
              await widget.todoController
                  .updateTodosBySubIndexAndDate(updatedSubTodo);
              Navigator.pushReplacementNamed(context, '/main');
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('할 일 반복 수정완료.')));
            },
            child: const Text('할 일 반복 수정'),
          ),
      ],
    );
  }

  Widget _deleteTodoDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('삭제 확인'),
      content: const Text('삭제 방식을 선택하세요.'),
      actions: <Widget>[
        TextButton(
          onPressed: () async {
            if (widget.todo.isCompleted) {
              final updatedTodo = widget.todo.copyWith(isCompleted: false);
              await widget.todoController.updateTodo(updatedTodo);
            }
            await widget.todoController.deleteTodoById(widget.todo.id!);
            Navigator.pop(context); // Close the dialog
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('할 일이 삭제되었습니다.')));
            Navigator.pushReplacementNamed(context, '/main');
          },
          child: const Text('할 일 삭제'),
        ),
        if (widget.todo.subIndex != null)
          TextButton(
            onPressed: () async {
              if (widget.todo.isCompleted) {
                final updatedSubTodo = widget.todo.copyWith(isCompleted: false);
                await widget.todoController
                    .updateTodosBySubIndexAndDate(updatedSubTodo);
              }
              await widget.todoController.deleteTodoBySubIndexAndDate(
                  widget.todo.subIndex!, widget.todo.dueDate);
              Navigator.pop(context); // Close the dialog
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('오늘 이후 할 일 반복 삭제 완료.')));
              Navigator.pushReplacementNamed(context, '/main');
            },
            child: const Text('할 일 반복 삭제'),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _urlController.dispose();
    _placeController.dispose();
    super.dispose();
  }
}




// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:intl/intl.dart';
// import '../../models/todo/todo_model.dart';
// import '../../controller/todo/todo_controller.dart';
// import '../../provider/todo/todo_provider.dart';
// import '../../api/todo/todo_api.dart';
// import '../todo/todo_timer_screen.dart';

// class TodoDetailScreen extends StatefulWidget {
//   final int todoId;
//   const TodoDetailScreen({super.key, required this.todoId});

//   @override
//   _TodoDetailScreenState createState() => _TodoDetailScreenState();
// }

// class _TodoDetailScreenState extends State<TodoDetailScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF2E9E9), // 배경 색상 설정
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF0D2338), // 남색 배경
//         title: const Text('할 일 상세',
//             style: TextStyle(color: Colors.white)), // 흰색 텍스트
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),
//       body: Container(
//         color: const Color(0xFFF2E9E9), // 배경 색상 설정
//         padding: const EdgeInsets.all(16),
//         child: Consumer(
//           builder: (context, ref, _) {
//             return FutureBuilder<Todo>(
//               future:
//                   ref.read(todoControllerProvider).fetchTodoById(widget.todoId),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 } else if (snapshot.hasError) {
//                   return Center(
//                       child: Text('오류: ${snapshot.error.toString()}'));
//                 } else if (snapshot.hasData) {
//                   return TodoDetailForm(
//                       todo: snapshot.data!,
//                       todoController: ref.read(todoControllerProvider));
//                 } else {
//                   return const Center(child: Text('데이터를 불러올 수 없습니다.'));
//                 }
//               },
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

// class TodoDetailForm extends StatefulWidget {
//   final Todo todo;
//   final TodoController todoController;
//   const TodoDetailForm(
//       {super.key, required this.todo, required this.todoController});

//   @override
//   _TodoDetailFormState createState() => _TodoDetailFormState();
// }

// class _TodoDetailFormState extends State<TodoDetailForm> {
//   late TextEditingController _titleController;
//   late TextEditingController _contentController;
//   late TextEditingController _urlController;
//   late TextEditingController _placeController;
//   late int _spentTime;
//   late DateTime _dueDate;

//   @override
//   void initState() {
//     super.initState();
//     _titleController = TextEditingController(text: widget.todo.todoTitle);
//     _contentController = TextEditingController(text: widget.todo.todoContent);
//     _urlController = TextEditingController(text: widget.todo.url);
//     _placeController = TextEditingController(text: widget.todo.place);
//     _spentTime = widget.todo.spentTime ?? 0; // _spentTime 초기화
//     _dueDate = widget.todo.dueDate;
//   }

//   @override
//   void didUpdateWidget(covariant TodoDetailForm oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (widget.todo.spentTime != oldWidget.todo.spentTime) {
//       setState(() {
//         _spentTime = widget.todo.spentTime ?? 0;
//       });
//     }
//   }

//   void _navigateAndDisplaySelection(BuildContext context) async {
//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(
//           builder: (context) =>
//               TodoTimerScreen(initialTimeInSeconds: _spentTime)),
//     );

//     // TodoTimerScreen에서 반환된 결과가 null이 아니고, int 형식인지 확인하고, 위젯이 아직 마운트된 상태인지 확인
//     if (result != null && result is int && mounted) {
//       setState(() {
//         _spentTime = result;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Form(
//       child: ListView(
//         children: <Widget>[
//           TextFormField(
//             controller: _titleController,
//             decoration: const InputDecoration(labelText: '제목'),
//           ),
//           TextFormField(
//             controller: _contentController,
//             decoration: const InputDecoration(labelText: '내용'),
//             maxLines: 3,
//           ),
//           ListTile(
//             title: Text('마감 기한: ${DateFormat('yyyy-MM-dd').format(_dueDate)}'),
//             onTap: () async {
//               final DateTime? picked = await showDatePicker(
//                 context: context,
//                 initialDate: _dueDate,
//                 firstDate: DateTime.now(),
//                 lastDate: DateTime.now().add(const Duration(days: 90)),
//               );
//               if (picked != null && picked != _dueDate) {
//                 setState(() {
//                   _dueDate = picked;
//                 });
//               }
//             },
//           ),
//           TextFormField(
//             controller: _urlController,
//             decoration: const InputDecoration(labelText: 'URL'),
//           ),
//           TextFormField(
//             controller: _placeController,
//             decoration: const InputDecoration(labelText: '장소'),
//           ),
//           ListTile(
//             title: Text(
//                 '소요 시간: ${_spentTime ~/ 3600}시간 ${(_spentTime % 3600) ~/ 60}분 ${_spentTime % 60}초'),
//             onTap: () => _navigateAndDisplaySelection(context),
//           ),
//           const SizedBox(height: 70),
//           ElevatedButton(
//             onPressed: () => showDialog(
//                 context: context,
//                 builder: (context) => _updateTodoDialog(context)),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF0D2338),
//               foregroundColor: Colors.white,
//             ),
//             child: const Text('할 일 수정'),
//           ),
//           ElevatedButton(
//             onPressed: () => showDialog(
//                 context: context,
//                 builder: (context) => _deleteTodoDialog(context)),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF0D2338),
//               foregroundColor: Colors.white,
//             ),
//             child: const Text('삭제'),
//           )
//         ],
//       ),
//     );
//   }

//   Widget _updateTodoDialog(BuildContext context) {
//     return AlertDialog(
//       title: const Text('할 일 수정'),
//       content: const Text('원하는 수정 방식을 선택하세요.'),
//       actions: <Widget>[
//         TextButton(
//           onPressed: () async {
//             final updatedTodo = Todo(
//               id: widget.todo.id,
//               todoTitle: _titleController.text,
//               todoContent: _contentController.text,
//               dueDate: _dueDate,
//               url: _urlController.text,
//               place: _placeController.text,
//               spentTime: _spentTime,
//               isCompleted: widget.todo.isCompleted,
//             );
//             await widget.todoController.updateTodo(updatedTodo);
//             Navigator.pushReplacementNamed(context, '/main');
//             ScaffoldMessenger.of(context)
//                 .showSnackBar(const SnackBar(content: Text('변경 사항이 저장되었습니다.')));
//           },
//           child: const Text('할 일 수정'),
//         ),
//         if (widget.todo.subIndex != null)
//           TextButton(
//             onPressed: () async {
//               final updatedSubTodo = Todo(
//                   subIndex: widget.todo.subIndex,
//                   todoTitle: _titleController.text,
//                   todoContent: _contentController.text,
//                   dueDate: _dueDate,
//                   url: _urlController.text,
//                   place: _placeController.text,
//                   spentTime: _spentTime,
//                   isCompleted: widget.todo.isCompleted);
//               await widget.todoController
//                   .updateTodosBySubIndexAndDate(updatedSubTodo);
//               Navigator.pushReplacementNamed(context, '/main');
//               ScaffoldMessenger.of(context)
//                   .showSnackBar(const SnackBar(content: Text('할 일 반복 수정완료.')));
//             },
//             child: const Text('할 일 반복 수정'),
//           ),
//       ],
//     );
//   }

//   Widget _deleteTodoDialog(BuildContext context) {
//     return AlertDialog(
//       title: const Text('삭제 확인'),
//       content: const Text('삭제 방식을 선택하세요.'),
//       actions: <Widget>[
//         TextButton(
//           onPressed: () async {
//             if (widget.todo.isCompleted) {
//               final updatedTodo = widget.todo.copyWith(isCompleted: false);
//               await widget.todoController.updateTodo(updatedTodo);
//             }
//             await widget.todoController.deleteTodoById(widget.todo.id!);
//             Navigator.pop(context); // Close the dialog
//             ScaffoldMessenger.of(context)
//                 .showSnackBar(const SnackBar(content: Text('할 일이 삭제되었습니다.')));
//             Navigator.pushReplacementNamed(context, '/main');
//           },
//           child: const Text('할 일 삭제'),
//         ),
//         if (widget.todo.subIndex != null)
//           TextButton(
//             onPressed: () async {
//               if (widget.todo.isCompleted) {
//                 final updatedSubTodo = widget.todo.copyWith(isCompleted: false);
//                 await widget.todoController
//                     .updateTodosBySubIndexAndDate(updatedSubTodo);
//               }
//               await widget.todoController.deleteTodoBySubIndexAndDate(
//                   widget.todo.subIndex!, widget.todo.dueDate);
//               Navigator.pop(context); // Close the dialog
//               ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text('오늘 이후 할 일 반복 삭제 완료.')));
//               Navigator.pushReplacementNamed(context, '/main');
//             },
//             child: const Text('할 일 반복 삭제'),
//           ),
//       ],
//     );
//   }

//   @override
//   void dispose() {
//     _titleController.dispose();
//     _contentController.dispose();
//     _urlController.dispose();
//     _placeController.dispose();
//     super.dispose();
//   }
// }



// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:intl/intl.dart';
// import '../../models/todo/todo_model.dart';
// import '../../controller/todo/todo_controller.dart';
// import '../../provider/todo/todo_provider.dart';
// import '../../api/todo/todo_api.dart';
// import '../todo/todo_timer_screen.dart';

// class TodoDetailScreen extends StatefulWidget {
//   final int todoId;
//   const TodoDetailScreen({super.key, required this.todoId});

//   @override
//   _TodoDetailScreenState createState() => _TodoDetailScreenState();
// }

// class _TodoDetailScreenState extends State<TodoDetailScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF0D2338), // 남색 배경
//         title: const Text('할 일 상세',
//             style: TextStyle(color: Colors.white)), // 흰색 텍스트
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),
//       body: Container(
//         padding: const EdgeInsets.all(16),
//         child: Consumer(
//           builder: (context, ref, _) {
//             return FutureBuilder<Todo>(
//               future:
//                   ref.read(todoControllerProvider).fetchTodoById(widget.todoId),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 } else if (snapshot.hasError) {
//                   return Center(
//                       child: Text('오류: ${snapshot.error.toString()}'));
//                 } else if (snapshot.hasData) {
//                   return TodoDetailForm(
//                       todo: snapshot.data!,
//                       todoController: ref.read(todoControllerProvider));
//                 } else {
//                   return const Center(child: Text('데이터를 불러올 수 없습니다.'));
//                 }
//               },
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

// class TodoDetailForm extends StatefulWidget {
//   final Todo todo;
//   final TodoController todoController;
//   const TodoDetailForm(
//       {super.key, required this.todo, required this.todoController});

//   @override
//   _TodoDetailFormState createState() => _TodoDetailFormState();
// }

// class _TodoDetailFormState extends State<TodoDetailForm> {
//   late TextEditingController _titleController;
//   late TextEditingController _contentController;
//   late TextEditingController _urlController;
//   late TextEditingController _placeController;
//   late int _spentTime;
//   late DateTime _dueDate;

//   @override
//   void initState() {
//     super.initState();
//     _titleController = TextEditingController(text: widget.todo.todoTitle);
//     _contentController = TextEditingController(text: widget.todo.todoContent);
//     _urlController = TextEditingController(text: widget.todo.url);
//     _placeController = TextEditingController(text: widget.todo.place);
//     _spentTime = widget.todo.spentTime ?? 0; // _spentTime 초기화
//     _dueDate = widget.todo.dueDate;
//   }

//   @override
//   void didUpdateWidget(covariant TodoDetailForm oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (widget.todo.spentTime != oldWidget.todo.spentTime) {
//       setState(() {
//         _spentTime = widget.todo.spentTime ?? 0;
//       });
//     }
//   }

//   void _navigateAndDisplaySelection(BuildContext context) async {
//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(
//           builder: (context) =>
//               TodoTimerScreen(initialTimeInSeconds: _spentTime)),
//     );

//     // TodoTimerScreen에서 반환된 결과가 null이 아니고, int 형식인지 확인하고, 위젯이 아직 마운트된 상태인지 확인
//     if (result != null && result is int && mounted) {
//       setState(() {
//         _spentTime = result;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Form(
//       child: ListView(
//         children: <Widget>[
//           TextFormField(
//             controller: _titleController,
//             decoration: const InputDecoration(labelText: '제목'),
//           ),
//           TextFormField(
//             controller: _contentController,
//             decoration: const InputDecoration(labelText: '내용'),
//             maxLines: 3,
//           ),
//           ListTile(
//             title: Text('마감 기한: ${DateFormat('yyyy-MM-dd').format(_dueDate)}'),
//             onTap: () async {
//               final DateTime? picked = await showDatePicker(
//                 context: context,
//                 initialDate: _dueDate,
//                 firstDate: DateTime.now(),
//                 lastDate: DateTime.now().add(const Duration(days: 90)),
//               );
//               if (picked != null && picked != _dueDate) {
//                 setState(() {
//                   _dueDate = picked;
//                 });
//               }
//             },
//           ),
//           TextFormField(
//             controller: _urlController,
//             decoration: const InputDecoration(labelText: 'URL'),
//           ),
//           TextFormField(
//             controller: _placeController,
//             decoration: const InputDecoration(labelText: '장소'),
//           ),
//           ListTile(
//             title: Text(
//                 '소요 시간: ${_spentTime ~/ 3600}시간 ${(_spentTime % 3600) ~/ 60}분 ${_spentTime % 60}초'),
//             onTap: () => _navigateAndDisplaySelection(context),
//           ),
//           const SizedBox(height: 70),
//           ElevatedButton(
//             onPressed: () => showDialog(
//                 context: context,
//                 builder: (context) => _updateTodoDialog(context)),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF0D2338),
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10.0)),
//             ),
//             child: const Text('할 일 수정'),
//           ),
//           ElevatedButton(
//             onPressed: () => showDialog(
//                 context: context,
//                 builder: (context) => _deleteTodoDialog(context)),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF0D2338),
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10.0)),
//             ),
//             child: const Text('삭제'),
//           )
//         ],
//       ),
//     );
//   }

//   Widget _updateTodoDialog(BuildContext context) {
//     return AlertDialog(
//       title: const Text('할 일 수정'),
//       content: const Text('원하는 수정 방식을 선택하세요.'),
//       actions: <Widget>[
//         TextButton(
//           onPressed: () async {
//             final updatedTodo = Todo(
//               id: widget.todo.id,
//               todoTitle: _titleController.text,
//               todoContent: _contentController.text,
//               dueDate: _dueDate,
//               url: _urlController.text,
//               place: _placeController.text,
//               spentTime: _spentTime,
//               isCompleted: widget.todo.isCompleted,
//             );
//             await widget.todoController.updateTodo(updatedTodo);
//             Navigator.pushReplacementNamed(context, '/main');
//             ScaffoldMessenger.of(context)
//                 .showSnackBar(const SnackBar(content: Text('변경 사항이 저장되었습니다.')));
//           },
//           child: const Text('할 일 수정'),
//         ),
//         if (widget.todo.subIndex != null)
//           TextButton(
//             onPressed: () async {
//               final updatedSubTodo = Todo(
//                   subIndex: widget.todo.subIndex,
//                   todoTitle: _titleController.text,
//                   todoContent: _contentController.text,
//                   dueDate: _dueDate,
//                   url: _urlController.text,
//                   place: _placeController.text,
//                   spentTime: _spentTime,
//                   isCompleted: widget.todo.isCompleted);
//               await widget.todoController
//                   .updateTodosBySubIndexAndDate(updatedSubTodo);
//               Navigator.pushReplacementNamed(context, '/main');
//               ScaffoldMessenger.of(context)
//                   .showSnackBar(const SnackBar(content: Text('할 일 반복 수정완료.')));
//             },
//             child: const Text('할 일 반복 수정'),
//           ),
//       ],
//     );
//   }

//   Widget _deleteTodoDialog(BuildContext context) {
//     return AlertDialog(
//       title: const Text('삭제 확인'),
//       content: const Text('삭제 방식을 선택하세요.'),
//       actions: <Widget>[
//         TextButton(
//           onPressed: () async {
//             await widget.todoController.deleteTodoById(widget.todo.id!);
//             Navigator.pop(context); // Close the dialog
//             ScaffoldMessenger.of(context)
//                 .showSnackBar(const SnackBar(content: Text('할 일이 삭제되었습니다.')));
//             Navigator.pushReplacementNamed(context, '/main');
//           },
//           child: const Text('할 일 삭제'),
//         ),
//         if (widget.todo.subIndex != null)
//           TextButton(
//             onPressed: () async {
//               await widget.todoController.deleteTodoBySubIndexAndDate(
//                   widget.todo.subIndex!, widget.todo.dueDate);
//               Navigator.pop(context); // Close the dialog
//               ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text('오늘 이후 할 일 반복 삭제 완료.')));
//               Navigator.pushReplacementNamed(context, '/main');
//             },
//             child: const Text('할 일 반복 삭제'),
//           ),
//       ],
//     );
//   }

//   @override
//   void dispose() {
//     _titleController.dispose();
//     _contentController.dispose();
//     _urlController.dispose();
//     _placeController.dispose();
//     super.dispose();
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:intl/intl.dart';
// import '../../models/todo/todo_model.dart';
// import '../../controller/todo/todo_controller.dart';
// import '../../provider/todo/todo_provider.dart';
// import '../../api/todo/todo_api.dart';

// class TodoDetailScreen extends StatefulWidget {
//   final int todoId;
//   const TodoDetailScreen({super.key, required this.todoId});

//   @override
//   _TodoDetailScreenState createState() => _TodoDetailScreenState();
// }

// class _TodoDetailScreenState extends State<TodoDetailScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF0D2338), // 남색 배경
//         title: const Text('할 일 상세',
//             style: TextStyle(color: Colors.white)), // 흰색 텍스트
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),
//       body: Container(
//         padding: const EdgeInsets.all(16),
//         child: Consumer(
//           builder: (context, ref, _) {
//             return FutureBuilder<Todo>(
//               future:
//                   ref.read(todoControllerProvider).fetchTodoById(widget.todoId),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 } else if (snapshot.hasError) {
//                   return Center(
//                       child: Text('오류: ${snapshot.error.toString()}'));
//                 } else if (snapshot.hasData) {
//                   return TodoDetailForm(
//                       todo: snapshot.data!,
//                       todoController: ref.read(todoControllerProvider));
//                 } else {
//                   return const Center(child: Text('데이터를 불러올 수 없습니다.'));
//                 }
//               },
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

// class TodoDetailForm extends StatefulWidget {
//   final Todo todo;
//   final TodoController todoController;
//   const TodoDetailForm(
//       {super.key, required this.todo, required this.todoController});

//   @override
//   _TodoDetailFormState createState() => _TodoDetailFormState();
// }

// class _TodoDetailFormState extends State<TodoDetailForm> {
//   late TextEditingController _titleController;
//   late TextEditingController _contentController;
//   late TextEditingController _urlController;
//   late TextEditingController _placeController;
//   late int _spentTime;
//   late DateTime _dueDate;

//   @override
//   void initState() {
//     super.initState();
//     _titleController = TextEditingController(text: widget.todo.todoTitle);
//     _contentController = TextEditingController(text: widget.todo.todoContent);
//     _urlController = TextEditingController(text: widget.todo.url);
//     _placeController = TextEditingController(text: widget.todo.place);
//     _spentTime = widget.todo.spentTime ?? 0;
//     _dueDate = widget.todo.dueDate;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Form(
//       child: ListView(
//         children: <Widget>[
//           TextFormField(
//             controller: _titleController,
//             decoration: const InputDecoration(labelText: '제목'),
//           ),
//           TextFormField(
//             controller: _contentController,
//             decoration: const InputDecoration(labelText: '내용'),
//             maxLines: 3,
//           ),
//           ListTile(
//             title: Text('마감 기한: ${DateFormat('yyyy-MM-dd').format(_dueDate)}'),
//             onTap: () async {
//               final DateTime? picked = await showDatePicker(
//                 context: context,
//                 initialDate: _dueDate,
//                 firstDate: DateTime.now(),
//                 lastDate: DateTime.now().add(const Duration(days: 90)),
//               );
//               if (picked != null && picked != _dueDate) {
//                 setState(() {
//                   _dueDate = picked;
//                 });
//               }
//             },
//           ),
//           TextFormField(
//             controller: _urlController,
//             decoration: const InputDecoration(labelText: 'URL'),
//           ),
//           TextFormField(
//             controller: _placeController,
//             decoration: const InputDecoration(labelText: '장소'),
//           ),
//           TextFormField(
//             initialValue: _spentTime.toString(),
//             decoration: const InputDecoration(labelText: '소요 시간(분)'),
//             keyboardType: TextInputType.number,
//             onChanged: (value) {
//               _spentTime = int.tryParse(value) ?? _spentTime;
//             },
//           ),
//           const SizedBox(height: 70),
//           ElevatedButton(
//             onPressed: () async {
//               showDialog(
//                 context: context,
//                 builder: (BuildContext context) {
//                   return AlertDialog(
//                     title: const Text('할 일 수정'),
//                     content: const Text('원하는 수정 방식을 선택하세요.'),
//                     actions: <Widget>[
//                       TextButton(
//                         onPressed: () async {
//                           final updatedTodo = Todo(
//                             id: widget.todo.id,
//                             todoTitle: _titleController.text,
//                             todoContent: _contentController.text,
//                             dueDate: _dueDate,
//                             url: _urlController.text,
//                             place: _placeController.text,
//                             spentTime: _spentTime,
//                             isCompleted: widget.todo.isCompleted,
//                           );
//                           await widget.todoController.updateTodo(updatedTodo);
//                           Navigator.pushReplacementNamed(context, '/main');
//                           ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(content: Text('변경 사항이 저장되었습니다.')));
//                         },
//                         child: const Text('할 일 수정'),
//                       ),
//                       if (widget.todo.subIndex != null)
//                         TextButton(
//                           onPressed: () async {
//                             final updatedSubTodo = Todo(
//                                 subIndex: widget.todo.subIndex,
//                                 todoTitle: _titleController.text,
//                                 todoContent: _contentController.text,
//                                 dueDate: _dueDate,
//                                 url: _urlController.text,
//                                 place: _placeController.text,
//                                 spentTime: _spentTime,
//                                 isCompleted: widget.todo.isCompleted);
//                             await widget.todoController
//                                 .updateTodosBySubIndexAndDate(updatedSubTodo);
//                             Navigator.pushReplacementNamed(context, '/main');
//                             ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(content: Text('할 일 반복 수정완료.')));
//                           },
//                           child: const Text('할 일 반복 수정'),
//                         ),
//                     ],
//                   );
//                 },
//               );
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF0D2338),
//               foregroundColor: Colors.white, // 흰색 글씨
//               shape: RoundedRectangleBorder(
//                 // 둥근 테두리 설정
//                 borderRadius: BorderRadius.circular(10.0),
//               ),
//             ),
//             child: const Text('할 일 수정'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               showDialog(
//                   context: context,
//                   builder: (BuildContext context) {
//                     return AlertDialog(
//                       title: const Text('삭제 확인'),
//                       content: const Text('삭제 방식을 선택하세요.'),
//                       actions: <Widget>[
//                         TextButton(
//                           onPressed: () async {
//                             await widget.todoController
//                                 .deleteTodoById(widget.todo.id!);
//                             Navigator.of(context).pop(); // 모달 닫기
//                             ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(content: Text('할 일이 삭제되었습니다.')));
//                             Navigator.pushReplacementNamed(context, '/main');
//                           },
//                           child: const Text('할 일 삭제'),
//                         ),
//                         if (widget.todo.subIndex != null)
//                           TextButton(
//                             onPressed: () async {
//                               await widget.todoController
//                                   .deleteTodoBySubIndexAndDate(
//                                       widget.todo.subIndex!,
//                                       widget.todo.dueDate);
//                               Navigator.of(context).pop(); // 모달 닫기
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                   const SnackBar(
//                                       content: Text('오늘 이후 할 일 반복 삭제 완료.')));
//                               Navigator.pushReplacementNamed(context, '/main');
//                             },
//                             child: const Text('할 일 반복 삭제'),
//                           ),
//                       ],
//                     );
//                   });
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF0D2338),
//               foregroundColor: Colors.white, // 흰색 글씨
//               shape: RoundedRectangleBorder(
//                 // 둥근 테두리 설정
//                 borderRadius: BorderRadius.circular(10.0),
//               ),
//             ),
//             child: const Text('삭제'),
//           )
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _titleController.dispose();
//     _contentController.dispose();
//     _urlController.dispose();
//     _placeController.dispose();
//     super.dispose();
//   }
// }



// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:intl/intl.dart';
// import '../../models/todo/todo_model.dart';
// import '../../controller/todo/todo_controller.dart';
// import '../../provider/todo/todo_provider.dart';
// import '../../api/todo/todo_api.dart';

// // TodoDetailScreen을 StatefulWidget으로 변경
// class TodoDetailScreen extends StatefulWidget {
//   final int todoId;
//   const TodoDetailScreen({super.key, required this.todoId});

//   @override
//   _TodoDetailScreenState createState() => _TodoDetailScreenState();
// }

// class _TodoDetailScreenState extends State<TodoDetailScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('할 일 상세'),
//       ),
//       body: Container(
//         padding: const EdgeInsets.all(16),
//         child: Consumer(
//           builder: (context, ref, _) {
//             return FutureBuilder<Todo>(
//               future:
//                   ref.read(todoControllerProvider).fetchTodoById(widget.todoId),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 } else if (snapshot.hasError) {
//                   return Center(
//                       child: Text('오류: ${snapshot.error.toString()}'));
//                 } else if (snapshot.hasData) {
//                   return TodoDetailForm(
//                       todo: snapshot.data!,
//                       todoController: ref.read(todoControllerProvider));
//                 } else {
//                   return const Center(child: Text('데이터를 불러올 수 없습니다.'));
//                 }
//               },
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

// // TodoDetailForm 위젯 정의, 사용자 입력을 받아 Todo 정보를 표시 및 수정 가능
// class TodoDetailForm extends StatefulWidget {
//   final Todo todo;
//   final TodoController todoController;
//   const TodoDetailForm({
//     super.key,
//     required this.todo,
//     required this.todoController,
//   });

//   @override
//   _TodoDetailFormState createState() => _TodoDetailFormState();
// }

// class _TodoDetailFormState extends State<TodoDetailForm> {
//   late TextEditingController _titleController;
//   late TextEditingController _contentController;
//   late TextEditingController _urlController;
//   late TextEditingController _placeController;
//   late int _spentTime;
//   late DateTime _dueDate;

//   @override
//   void initState() {
//     super.initState();
//     _titleController = TextEditingController(text: widget.todo.todoTitle);
//     _contentController = TextEditingController(text: widget.todo.todoContent);
//     _urlController = TextEditingController(text: widget.todo.url);
//     _placeController = TextEditingController(text: widget.todo.place);
//     _spentTime = widget.todo.spentTime ?? 0;
//     _dueDate = widget.todo.dueDate;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Form(
//       child: ListView(
//         children: <Widget>[
//           TextFormField(
//             controller: _titleController,
//             decoration: const InputDecoration(labelText: '제목'),
//           ),
//           TextFormField(
//             controller: _contentController,
//             decoration: const InputDecoration(labelText: '내용'),
//             maxLines: 3,
//           ),
//           ListTile(
//             title: Text('마감 기한: ${DateFormat('yyyy-MM-dd').format(_dueDate)}'),
//             onTap: () async {
//               final DateTime? picked = await showDatePicker(
//                 context: context,
//                 initialDate: _dueDate,
//                 firstDate: DateTime(DateTime.now().year, DateTime.now().month,
//                     DateTime.now().day), // 오늘 이후만 선택 가능
//                 lastDate: DateTime.now()
//                     .add(const Duration(days: 90)), // 3개월 후까지만 선택 가능
//               );
//               if (picked != null && picked != _dueDate) {
//                 setState(() {
//                   _dueDate = picked;
//                 });
//               }
//             },
//           ),
//           TextFormField(
//             controller: _urlController,
//             decoration: const InputDecoration(labelText: 'URL'),
//           ),
//           TextFormField(
//             controller: _placeController,
//             decoration: const InputDecoration(labelText: '장소'),
//           ),
//           TextFormField(
//             initialValue: _spentTime.toString(),
//             decoration: const InputDecoration(labelText: '소요 시간(분)'),
//             keyboardType: TextInputType.number,
//             onChanged: (value) {
//               _spentTime = int.tryParse(value) ?? _spentTime;
//             },
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               showDialog(
//                 context: context,
//                 builder: (BuildContext context) {
//                   return AlertDialog(
//                     title: const Text('할 일 수정'),
//                     content: const Text('원하는 수정 방식을 선택하세요.'),
//                     actions: <Widget>[
//                       TextButton(
//                         onPressed: () async {
//                           final updatedTodo = Todo(
//                             id: widget.todo.id,
//                             todoTitle: _titleController.text,
//                             todoContent: _contentController.text,
//                             dueDate: _dueDate,
//                             url: _urlController.text,
//                             place: _placeController.text,
//                             spentTime: _spentTime,
//                             isCompleted: widget.todo.isCompleted,
//                           );
//                           await widget.todoController.updateTodo(updatedTodo);
//                           Navigator.pushReplacementNamed(context, '/main');
//                           ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(content: Text('변경 사항이 저장되었습니다.')));
//                         },
//                         child: const Text('할 일 수정'),
//                       ),
//                       if (widget.todo.subIndex != null)
//                         TextButton(
//                           onPressed: () async {
//                             final updatedSubTodo = Todo(
//                                 subIndex: widget.todo.subIndex, // subIndex
//                                 todoTitle: _titleController.text, // 제목
//                                 todoContent: _contentController.text, // 내용
//                                 dueDate: _dueDate, // 날짜
//                                 url: _urlController.text, // URL
//                                 place: _placeController.text, // 장소
//                                 spentTime: _spentTime, // 소요 시간
//                                 isCompleted: widget.todo.isCompleted // 완료 상태
//                                 );
//                             await widget.todoController
//                                 .updateTodosBySubIndexAndDate(updatedSubTodo);
//                             Navigator.pushReplacementNamed(
//                                 context, '/main'); // 모달 닫기
//                             ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(content: Text('할 일 반복 수정완료.')));
//                           },
//                           child: const Text('할 일 반복 수정'),
//                         ),
//                     ],
//                   );
//                 },
//               );
//             },
//             child: const Text('할 일 수정'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               showDialog(
//                   context: context,
//                   builder: (BuildContext context) {
//                     return AlertDialog(
//                       title: const Text('삭제 확인'),
//                       content: const Text('삭제 방식을 선택하세요.'),
//                       actions: <Widget>[
//                         TextButton(
//                           onPressed: () async {
//                             await widget.todoController
//                                 .deleteTodoById(widget.todo.id!);
//                             Navigator.of(context).pop(); // 모달 닫기
//                             ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(content: Text('할 일이 삭제되었습니다.')));
//                             Navigator.pushReplacementNamed(context, '/main');
//                           },
//                           child: const Text('할 일 삭제'),
//                         ),
//                         if (widget.todo.subIndex != null)
//                           TextButton(
//                             onPressed: () async {
//                               await widget.todoController
//                                   .deleteTodoBySubIndexAndDate(
//                                       widget.todo.subIndex!,
//                                       widget.todo.dueDate);
//                               Navigator.of(context).pop(); // 모달 닫기
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                   const SnackBar(
//                                       content: Text('오늘 이후 할 일 반복 삭제 완료.')));
//                               Navigator.pushReplacementNamed(context, '/main');
//                             },
//                             child: const Text('할 일 반복 삭제'),
//                           ),
//                       ],
//                     );
//                   });
//             },
//             child: const Text('삭제'),
//           )
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _titleController.dispose();
//     _contentController.dispose();
//     _urlController.dispose();
//     _placeController.dispose();
//     super.dispose();
//   }
// }
