import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'todo_create_screen.dart';
import 'recurring_todo_create_screen.dart';

class TodoTabView extends ConsumerWidget {
  const TodoTabView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('할 일 관리'),
          backgroundColor: const Color(0xFF0D2338), // AppBar 배경 색상
          foregroundColor: Colors.white,
          bottom: const TabBar(
            labelColor: Colors.white, // 선택된 탭의 텍스트 색상
            unselectedLabelColor: Colors.white70, // 선택되지 않은 탭의 텍스트 색상
            tabs: [
              Tab(icon: Icon(Icons.add), text: '할 일'),
              Tab(icon: Icon(Icons.repeat), text: '반복 할 일'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            // 각 탭의 배경색을 하얀색으로 설정
            ColoredBox(
              color: Colors.white,
              child: TodoCreateScreen(),
            ),
            ColoredBox(
              color: Colors.white,
              child: RecurringTodoCreateScreen(),
            ),
          ],
        ),
      ),
    );
  }
}

void showTodoModalDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return const Dialog(
        child: SizedBox(
          width: 600, // 다이얼로그의 크기를 조정
          child: TodoTabView(),
        ),
      );
    },
  );
}


// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import 'todo_create_screen.dart';
// import 'recurring_todo_create_screen.dart';

// class TodoTabView extends ConsumerWidget {
//   const TodoTabView({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return DefaultTabController(
//       length: 2,
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('할 일 관리'),
//           backgroundColor: const Color(0xfff0d2338),
//           foregroundColor: Colors.white,
//           bottom: const TabBar(
//             tabs: [
//               Tab(icon: Icon(Icons.add), text: '단일 할 일'),
//               Tab(icon: Icon(Icons.repeat), text: '반복 할 일'),
//             ],
//           ),
//         ),
//         body: const TabBarView(
//           children: [
//             TodoCreateScreen(),
//             RecurringTodoCreateScreen(),
//           ],
//         ),
//       ),
//     );
//   }
// }

// void showTodoModalDialog(BuildContext context) {
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return const Dialog(
//         child: SizedBox(
//           width: 600, // 다이얼로그의 크기를 조정
//           child: TodoTabView(),
//         ),
//       );
//     },
//   );
// }
