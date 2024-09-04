// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../screens/mainpage/main_page.dart';
// import '../../screens/user/mypage.dart';
// import '../../screens/calendar/calendar.dart';
// import '../../screens/routine/routine_list_screen.dart';
// import 'plusbutton.dart';

// class TabView extends ConsumerStatefulWidget {
//   const TabView({super.key});

//   @override
//   _TabViewState createState() => _TabViewState();
// }

// class _TabViewState extends ConsumerState<TabView> {
//   int _selectedIndex = 0;

//   static final List<Widget> _pages = [
//     const MainPage(),
//     RoutineListScreen(),
//     Container(),
//     const Calendar(),
//     const MyPage(),
//   ];

//   void _onItemTapped(int index) {
//     if (index == 2) {
//       PlusButton.showCreateOptions(context);
//     } else {
//       setState(() {
//         _selectedIndex = index;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: _pages.elementAt(_selectedIndex),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         backgroundColor: const Color(0xFF0D2338),
//         unselectedItemColor: const Color(0xFFB0BEC5),
//         selectedItemColor: const Color(0xFFF2E9E9),
//         type: BottomNavigationBarType.fixed,
//         items: const <BottomNavigationBarItem>[
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
//           BottomNavigationBarItem(icon: Icon(Icons.list), label: '루틴'),
//           BottomNavigationBarItem(icon: Icon(Icons.add_box_sharp), label: '등록'),
//           BottomNavigationBarItem(
//               icon: Icon(Icons.calendar_today), label: '달력'),
//           BottomNavigationBarItem(icon: Icon(Icons.person), label: '내 정보'),
//         ],
//         currentIndex: _selectedIndex,
//         onTap: _onItemTapped,
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../screens/calendar/calendar.dart';
import '../../screens/mainpage/main_page.dart';
import '../../screens/routine/routine_list_screen.dart';
import '../../screens/user/mypage.dart';
import 'plusbutton.dart';

class TabView extends ConsumerStatefulWidget {
  const TabView({super.key});

  @override
  _TabViewState createState() => _TabViewState();
}

class _TabViewState extends ConsumerState<TabView> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = [
    const MainPage(),
    RoutineListScreen(),
    Container(),
    const Calendar(),
    const MyPage(),
  ];

  void _onItemTapped(int index) {
    if (index == 2) {
      PlusButton.showCreateOptions(context);
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => _selectedIndex != 0, // 첫 번째 탭에서만 뒤로 가기를 막습니다.
      child: Scaffold(
      resizeToAvoidBottomInset: false,
        body: Center(
          child: _pages.elementAt(_selectedIndex),
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: const Color(0xFF0D2338),
          unselectedItemColor: const Color(0xFFB0BEC5),
          selectedItemColor: const Color(0xFFF2E9E9),
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
            BottomNavigationBarItem(icon: Icon(Icons.list), label: '루틴'),
            BottomNavigationBarItem(
                icon: Icon(Icons.add_box_sharp), label: '등록'),
            BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today), label: '달력'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: '내 정보'),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
