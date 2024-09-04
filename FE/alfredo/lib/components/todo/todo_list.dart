import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/todo/todo_model.dart';
import '../../provider/coin/coin_provider.dart'; // coin_provider를 import합니다.
import '../../provider/todo/todo_provider.dart';
import '../../screens/todo/todo_detail_screen.dart';

class TodoList extends ConsumerStatefulWidget {
  const TodoList({super.key});

  @override
  ConsumerState<TodoList> createState() => _TodoListState();
}

class _TodoListState extends ConsumerState<TodoList> {
  List<Todo>? _todos;

  void _fetchTodos() async {
    final todoController = ref.read(todoControllerProvider);
    var fetchedTodos = await todoController.fetchTodosByDate(DateTime.now());
    if (mounted) {
      setState(() {
        _todos = fetchedTodos;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchTodos(); // 프레임이 그려진 후 데이터를 불러옵니다.
    });
  }

  void _onTodoUpdated() {
    _fetchTodos(); // 할 일이 업데이트 될 때 데이터를 다시 불러옵니다.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(40.0),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: const Text('오늘의 할 일 목록',
              style: TextStyle(
                  fontSize: 20.0, color: Color.fromARGB(255, 77, 26, 86))),
        ),
      ),
      body: _todos == null
          ? const Center(child: CircularProgressIndicator())
          : _todos!.isEmpty
              ? const Center(child: Text('오늘의 할 일이 없습니다.'))
              : ListView.builder(
                  itemCount: _todos!.length,
                  itemBuilder: (context, index) {
                    final todo = _todos![index];
                    return Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                              width: 1, color: Color(0xf80d3d3d3)), // 밑줄 추가
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 0),
                        title: Text(
                          todo.todoTitle,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color.fromARGB(255, 8, 1, 1),
                          ),
                          maxLines: 2, // 최대 줄 수를 2로 설정
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return TodoDetailScreen(todoId: todo.id!);
                            },
                          ).then((_) =>
                              _onTodoUpdated()); // 대화 상자가 닫힌 후 데이터를 갱신합니다.
                        },
                        trailing: Transform.scale(
                          scale: 1.3,
                          child: Checkbox(
                            value: todo.isCompleted,
                            onChanged: (bool? newValue) {
                              if (newValue != null) {
                                _toggleTodoCompletion(todo, newValue, index);
                              }
                            },
                            checkColor: const Color.fromARGB(
                                255, 231, 20, 20), // 체크 표시 색상을 빨간색으로 변경
                            activeColor: Colors.transparent,
                            side: const BorderSide(
                              color: Color.fromARGB(250, 255, 255, 255),
                              width: 2.0,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  void _toggleTodoCompletion(Todo todo, bool isCompleted, int index) async {
    final todoController = ref.read(todoControllerProvider);
    final coinController =
        ref.read(coinControllerProvider); // coinController를 읽어옵니다.

    setState(() {
      _todos![index] = todo.copyWith(isCompleted: isCompleted);
    });

    if (isCompleted) {
      // 할 일이 완료되었을 때
      await coinController.incrementCoin();
    } else {
      // 할 일이 완료 해제되었을 때
      await coinController.decrementCoin();
    }

    await todoController
        .updateTodo(_todos![index])
        .then((_) => _onTodoUpdated());
  }
}


// import 'package:flutter/material.dart';
// import 'dart:math' as math;
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import '../../models/todo/todo_model.dart';
// import '../../provider/todo/todo_provider.dart';
// import '../../screens/todo/todo_detail_screen.dart';

// class TodoList extends ConsumerStatefulWidget {
//   const TodoList({super.key});

//   @override
//   ConsumerState<TodoList> createState() => _TodoListState();
// }

// class _TodoListState extends ConsumerState<TodoList> {
//   List<Todo>? _todos;

//   void _fetchTodos() async {
//     final todoController = ref.read(todoControllerProvider);
//     var fetchedTodos = await todoController.fetchTodosByDate(DateTime.now());
//     if (mounted) {
//       setState(() {
//         _todos = fetchedTodos;
//       });
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _fetchTodos();
//     });
//   }

//   void _onTodoUpdated() {
//     _fetchTodos();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       appBar: PreferredSize(
//         preferredSize: const Size.fromHeight(40.0),
//         child: AppBar(
//           backgroundColor: Colors.transparent,
//           elevation: 0,
//           centerTitle: true,
//           automaticallyImplyLeading: false,
//           title: const Text('오늘의 할 일 목록',
//               style: TextStyle(
//                   fontSize: 20.0, color: Color.fromARGB(255, 242, 237, 237))),
//         ),
//       ),
//       body: _todos == null
//           ? const Center(child: CircularProgressIndicator())
//           : _todos!.isEmpty
//               ? const Center(child: Text('오늘의 할 일이 없습니다.'))
//               : ListView.builder(
//                   itemCount: _todos!.length,
//                   itemBuilder: (context, index) {
//                     final todo = _todos![index];
//                     String displayTitle = todo.todoTitle.length > 9
//                         ? '${todo.todoTitle.substring(0, 9)}...'
//                         : todo.todoTitle;
//                     return CustomPaint(
//                       foregroundPainter: WavyLinePainter(),
//                       child: Container(
//                         padding:
//                             const EdgeInsets.symmetric(vertical: 1), // 간격 조정
//                         child: ListTile(
//                           contentPadding: const EdgeInsets.symmetric(
//                               horizontal: 20.0, vertical: 1.0), // 여기도 간격 조정
//                           title: Text(
//                             displayTitle,
//                             style: const TextStyle(
//                               fontSize: 16,
//                               color: Color.fromARGB(255, 8, 1, 1),
//                             ),
//                           ),
//                           onTap: () {
//                             showDialog(
//                               context: context,
//                               builder: (BuildContext context) {
//                                 return TodoDetailScreen(todoId: todo.id!);
//                               },
//                             ).then((_) => _onTodoUpdated());
//                           },
//                           trailing: Transform.scale(
//                             scale: 1.5,
//                             child: Checkbox(
//                               value: todo.isCompleted,
//                               onChanged: (bool? newValue) {
//                                 if (newValue != null) {
//                                   _toggleTodoCompletion(todo, newValue, index);
//                                 }
//                               },
//                               checkColor: const Color.fromARGB(
//                                   255, 231, 20, 20), // 체크 표시 색상을 빨간색으로 변경
//                               activeColor: Colors.transparent,
//                               side: const BorderSide(
//                                 color: Color.fromARGB(250, 255, 255, 255),
//                                 width: 2.0,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//     );
//   }

//   void _toggleTodoCompletion(Todo todo, bool isCompleted, int index) async {
//     final todoController = ref.read(todoControllerProvider);
//     setState(() {
//       _todos![index] = todo.copyWith(isCompleted: isCompleted);
//     });
//     await todoController
//         .updateTodo(_todos![index])
//         .then((_) => _onTodoUpdated());
//   }
// }

// class WavyLinePainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.brown
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 0.5;
//     Path path = Path();
//     path.moveTo(0, size.height - 1);
//     for (double i = 0; i < size.width; i += 6) {
//       path.lineTo(i, size.height - 10 + 5 * math.sin(i / 60 * 2 * math.pi));
//     }
//     canvas.drawPath(path, paint);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }

// import 'package:flutter/material.dart';
// import 'dart:math' as math;
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import '../../models/todo/todo_model.dart';
// import '../../provider/todo/todo_provider.dart';
// import '../../screens/todo/todo_detail_screen.dart';

// class TodoList extends ConsumerStatefulWidget {
//   const TodoList({super.key});

//   @override
//   ConsumerState<TodoList> createState() => _TodoListState();
// }

// class _TodoListState extends ConsumerState<TodoList> {
//   List<Todo>? _todos;

//   void _fetchTodos() async {
//     final todoController = ref.read(todoControllerProvider);
//     var fetchedTodos = await todoController.fetchTodosByDate(DateTime.now());
//     if (mounted) {
//       setState(() {
//         _todos = fetchedTodos;
//       });
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _fetchTodos();
//     });
//   }

//   void _onTodoUpdated() {
//     _fetchTodos();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       appBar: PreferredSize(
//         preferredSize: const Size.fromHeight(40.0),
//         child: AppBar(
//           backgroundColor: Colors.transparent,
//           elevation: 0,
//           centerTitle: true,
//           title: const Text('오늘의 할 일 목록',
//               style: TextStyle(
//                   fontSize: 20.0,
//                   fontFamily: 'Georgia',
//                   color: Color.fromARGB(255, 242, 237, 237))),
//         ),
//       ),
//       body: _todos == null
//           ? const Center(child: CircularProgressIndicator())
//           : _todos!.isEmpty
//               ? const Center(child: Text('오늘의 할 일이 없습니다.'))
//               : ListView.builder(
//                   itemCount: _todos!.length,
//                   itemBuilder: (context, index) {
//                     final todo = _todos![index];
//                     return CustomPaint(
//                       foregroundPainter: WavyLinePainter(),
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(vertical: 5),
//                         child: ListTile(
//                           contentPadding: const EdgeInsets.symmetric(
//                               horizontal: 16.0, vertical: 1.0),
//                           title: Text(
//                             todo.todoTitle,
//                             style: const TextStyle(
//                               fontSize: 16,
//                               color: Color.fromARGB(255, 8, 1, 1),
//                             ),
//                           ),
//                           onTap: () {
//                             showDialog(
//                               context: context,
//                               builder: (BuildContext context) {
//                                 return TodoDetailScreen(todoId: todo.id!);
//                               },
//                             ).then((_) => _onTodoUpdated());
//                           },
//                           trailing: Transform.scale(
//                             scale: 1.5,
//                             child: Checkbox(
//                               value: todo.isCompleted,
//                               onChanged: (bool? newValue) {
//                                 if (newValue != null) {
//                                   _toggleTodoCompletion(todo, newValue, index);
//                                 }
//                               },

//                               checkColor: const Color.fromARGB(
//                                   255, 231, 20, 20), // 체크 표시 색상을 빨간색으로 변경
//                               activeColor: Colors.transparent,
//                               side: const BorderSide(
//                                 color: Color.fromARGB(250, 255, 255, 255),
//                                 width: 2.0,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//     );
//   }

//   void _toggleTodoCompletion(Todo todo, bool isCompleted, int index) async {
//     final todoController = ref.read(todoControllerProvider);
//     setState(() {
//       _todos![index] = todo.copyWith(isCompleted: isCompleted);
//     });
//     await todoController
//         .updateTodo(_todos![index])
//         .then((_) => _onTodoUpdated());
//   }
// }

// class WavyLinePainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.brown
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 0.5;
//     Path path = Path();
//     path.moveTo(0, size.height - 1);
//     for (double i = 0; i < size.width; i += 6) {
//       path.lineTo(i, size.height - 10 + 5 * math.sin(i / 60 * 2 * math.pi));
//     }
//     canvas.drawPath(path, paint);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }



// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import '../../models/todo/todo_model.dart';
// import '../../provider/todo/todo_provider.dart';
// import '../../screens/todo/todo_detail_screen.dart';

// class TodoList extends ConsumerStatefulWidget {
//   const TodoList({super.key});

//   @override
//   ConsumerState<TodoList> createState() => _TodoListState();
// }

// class _TodoListState extends ConsumerState<TodoList> {
//   List<Todo>? _todos;

//   void _fetchTodos() async {
//     final todoController = ref.read(todoControllerProvider);
//     var fetchedTodos = await todoController.fetchTodosByDate(DateTime.now());
//     if (mounted) {
//       setState(() {
//         _todos = fetchedTodos;
//       });
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _fetchTodos(); // 프레임이 그려진 후 데이터를 불러옵니다.
//     });
//   }

//   void _onTodoUpdated() {
//     _fetchTodos(); // 할 일이 업데이트 될 때 데이터를 다시 불러옵니다.
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       appBar: PreferredSize(
//         preferredSize: const Size.fromHeight(40.0),
//         child: AppBar(
//           backgroundColor: Colors.transparent,
//           elevation: 0,
//           centerTitle: true,
//           title: const Text('오늘의 할 일 목록',
//               style: TextStyle(
//                   fontSize: 20.0,
//                   fontFamily: 'Georgia',
//                   color: Color.fromARGB(255, 242, 237, 237))),
//         ),
//       ),
//       body: _todos == null
//           ? const Center(child: CircularProgressIndicator())
//           : _todos!.isEmpty
//               ? const Center(child: Text('오늘의 할 일이 없습니다.'))
//               : ListView.builder(
//                   itemCount: _todos!.length,
//                   itemBuilder: (context, index) {
//                     final todo = _todos![index];
//                     return ListTile(
//                       contentPadding: const EdgeInsets.symmetric(
//                           horizontal: 30.0, vertical: 8.0),
//                       title: Text(
//                         todo.todoTitle,
//                         style: const TextStyle(
//                           fontSize: 18,
//                           color: Color.fromARGB(255, 8, 1, 1),
//                         ),
//                       ),
//                       onTap: () {
//                         showDialog(
//                           context: context,
//                           builder: (BuildContext context) {
//                             return TodoDetailScreen(todoId: todo.id!);
//                           },
//                         ).then(
//                             (_) => _onTodoUpdated()); // 대화 상자가 닫힌 후 데이터를 갱신합니다.
//                       },
//                       trailing: Transform.scale(
//                         scale: 1.5,
//                         child: Checkbox(
//                           value: todo.isCompleted,
//                           onChanged: (bool? newValue) {
//                             if (newValue != null) {
//                               _toggleTodoCompletion(todo, newValue, index);
//                             }
//                           },
//                           activeColor: const Color(0xFFc5a880),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//     );
//   }

//   void _toggleTodoCompletion(Todo todo, bool isCompleted, int index) async {
//     final todoController = ref.read(todoControllerProvider);
//     setState(() {
//       _todos![index] = todo.copyWith(isCompleted: isCompleted);
//     });
//     await todoController
//         .updateTodo(_todos![index])
//         .then((_) => _onTodoUpdated());
//   }
// }
