import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/achieve/achieve_model.dart';
import '../../provider/achieve/achieve_provider.dart';
import '../user/loading_screen.dart';

class AchieveDetailScreen extends ConsumerWidget {
  const AchieveDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achieveAsyncValue = ref.watch(achieveProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("업적 상세", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xff0d2338),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/bookroom.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          achieveAsyncValue.when(
            data: (achieve) => _buildAchieveGrid(context, achieve),
            loading: () => const MyLoadingScreen(),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
        ],
      ),
    );
  }

  Widget _buildAchieveGrid(BuildContext context, Achieve achieve) {
    final achieveStatuses = [
      {
        "title": "인내의 숲",
        "status": achieve.achieveOne,
        "description": "총 수행시간 300초 이상인 경우 달성",
        "date": achieve.finishOne,
        "backgroundImage": "assets/first_achieve.png"
      },
      {
        "title": "얼리어답터",
        "status": achieve.achieveTwo,
        "description": "외부 캘린더와 연동 시 달성",
        "date": achieve.finishTwo,
        "backgroundImage": "assets/second_achieve.png"
      },
      {
        "title": "한 주의 승리자",
        "status": achieve.achieveThree,
        "description": "토요일부터 토요일 7일간 할 일 완료 시 달성",
        "date": achieve.finishThree,
        "backgroundImage": "assets/third_achieve.png"
      },
      {
        "title": "갓생살기",
        "status": achieve.achieveFour,
        "description": "총 루틴 갯수 15개 이상 시 달성",
        "date": achieve.finishFour,
        "backgroundImage": "assets/fourth_achieve.png"
      },
      {
        "title": "당신은 T이십니까?",
        "status": achieve.achieveFive,
        "description": "총 투두 갯수 15개 이상 시 달성",
        "date": achieve.finishFive,
        "backgroundImage": "assets/todocat.png"
      },
      {
        "title": "약속왕",
        "status": achieve.achieveSix,
        "description": "총 일정 갯수 5개 이상 시 달성",
        "date": achieve.finishSix,
        "backgroundImage": "assets/sixth_achieve.png"
      },
      {
        "title": "주 6일제",
        "status": achieve.achieveSeven,
        "description": "일주일에 6일 연속 출석 달성",
        "date": achieve.finishSeven,
        "backgroundImage": "assets/seventh_achieve.png"
      },
      {
        "title": "한 분 두식이 석삼이",
        "status": achieve.achieveEight,
        "description": "총 출석일수 3일 달성",
        "date": achieve.finishEight,
        "backgroundImage": "assets/eighth_achieve.png"
      },
      {
        "title": "해피버쓰데이",
        "status": achieve.achieveNine,
        "description": "생일 축하드립니다~!",
        "date": achieve.finishNine,
        "backgroundImage": "assets/catbirthday.png"
      },
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
      ),
      itemCount: achieveStatuses.length,
      itemBuilder: (context, index) {
        final achieveStatus = achieveStatuses[index];
        return GestureDetector(
          onTap: () => _showAchieveStatus(context, achieveStatus),
          child: _buildAchieveBadge(
            achieveStatus["title"] as String,
            achieveStatus["status"] as bool,
            achieveStatus["description"] as String,
            achieveStatus["date"] as DateTime?,
            achieveStatus.containsKey("backgroundImage")
                ? achieveStatus["backgroundImage"] as String
                : null,
          ),
        );
      },
    );
  }

  void _showAchieveStatus(
      BuildContext context, Map<String, dynamic> achieveStatus) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(achieveStatus["title"] as String),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(achieveStatus["description"] as String),
              if (achieveStatus["date"] != null)
                Text(
                    '달성일: ${DateFormat('yyyy-MM-dd').format(achieveStatus["date"] as DateTime)}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAchieveBadge(String title, bool status, String description,
      DateTime? date, String? backgroundImage) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: backgroundImage == null ? const Color(0xffE7D8BC) : null,
            image: backgroundImage != null
                ? DecorationImage(
                    image: AssetImage(backgroundImage),
                    fit: BoxFit.cover,
                  )
                : null,
            border: Border.all(
              color: Colors.white, // 테두리 색상 설정
              width: 4, // 테두리 두께 설정
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (date != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('yyyy-MM-dd').format(date),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        if (!status)
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100.0),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}




// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../models/achieve/achieve_model.dart';
// import '../../provider/achieve/achieve_provider.dart';
// import 'dart:ui';
// import 'package:intl/intl.dart';

// class AchieveDetailScreen extends ConsumerWidget {
//   const AchieveDetailScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final achieveAsyncValue = ref.watch(achieveProvider);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("업적 상세", style: TextStyle(color: Colors.white)),
//         backgroundColor: const Color(0xff0d2338),
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),
//       backgroundColor: const Color(0xffD6C3C3),
//       body: achieveAsyncValue.when(
//         data: (achieve) => _buildAchieveList(context, achieve),
//         loading: () => const Center(child: CircularProgressIndicator()),
//         error: (err, stack) => Center(child: Text('Error: $err')),
//       ),
//     );
//   }

//   Widget _buildAchieveList(BuildContext context, Achieve achieve) {
//     final achieveStatuses = [
//       {
//         "title": "첫번째 업적",
//         "status": achieve.achieveOne,
//         "description": "총 수행시간 업적",
//         "date": achieve.finishOne
//       },
//       {
//         "title": "2번째 업적",
//         "status": achieve.achieveTwo,
//         "description": "첫 ical 등록 업적",
//         "date": achieve.finishTwo
//       },
//       {
//         "title": "3번째 업적",
//         "status": achieve.achieveThree,
//         "description": "토요일부터 토요일 7일간 할일",
//         "date": achieve.finishThree
//       },
//       {
//         "title": "4번째 업적",
//         "status": achieve.achieveFour,
//         "description": "총 루틴 갯수 몇개이상",
//         "date": achieve.finishFour
//       },
//       {
//         "title": "5번째 업적",
//         "status": achieve.achieveFive,
//         "description": "총 투두 갯수 몇개 이상",
//         "date": achieve.finishFive
//       },
//       {
//         "title": "6번째 업적",
//         "status": achieve.achieveSix,
//         "description": "총 일정 갯수 몇개 이상",
//         "date": achieve.finishSix
//       },
//       {
//         "title": "9번째 업적",
//         "status": achieve.achieveNine,
//         "description": "생일 등록자가 오늘이 생일인 경우",
//         "date": achieve.finishNine
//       },
//     ];

//     return ListView.builder(
//       padding: const EdgeInsets.all(16.0),
//       itemCount: achieveStatuses.length,
//       itemBuilder: (context, index) {
//         final achieveStatus = achieveStatuses[index];
//         return _buildAchieveCard(
//           achieveStatus["title"] as String,
//           achieveStatus["status"] as bool,
//           achieveStatus["description"] as String,
//           achieveStatus["date"] as DateTime?,
//         );
//       },
//     );
//   }

//   Widget _buildAchieveCard(
//       String title, bool status, String description, DateTime? date) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Stack(
//         children: [
//           Card(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(15.0),
//             ),
//             color: const Color(0xffE7D8BC),
//             elevation: 5,
//             child: Center(
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       title,
//                       style: const TextStyle(
//                         color: Color(0xff0d2338),
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       description,
//                       style: const TextStyle(
//                         color: Color(0xff0d2338),
//                         fontSize: 16,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                     if (date != null) ...[
//                       const SizedBox(height: 8),
//                       Text(
//                         '달성일: ${DateFormat('yyyy-MM-dd').format(date)}',
//                         style: const TextStyle(
//                           color: Color(0xff0d2338),
//                           fontSize: 14,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           if (!status)
//             Positioned.fill(
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(15.0),
//                 child: BackdropFilter(
//                   filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
//                   child: Container(
//                     color: Colors.black.withOpacity(0.2),
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
