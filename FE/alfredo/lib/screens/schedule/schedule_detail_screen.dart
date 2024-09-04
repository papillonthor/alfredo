// import 'package:flutter/material.dart';
// import '../../controller/schedule/schedule_controller.dart';
// import '../../models/schedule/schedule_model.dart';
// import 'schedule_edit_screen.dart'; // 일정 수정 화면 import

// class ScheduleDetailScreen extends StatelessWidget {
//   final int scheduleId;
//   final ScheduleController controller = ScheduleController();

//   ScheduleDetailScreen({Key? key, required this.scheduleId}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("일정 상세"),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.edit), // 수정 아이콘 추가
//             onPressed: () {
//               // 수정 화면으로 이동
//               Navigator.push(context, MaterialPageRoute(
//                 builder: (context) => ScheduleEditScreen(scheduleId: scheduleId),
//               ));
//             },
//           ),
//         ],
//       ),
//       body: FutureBuilder<Schedule>(
//         future: controller.getScheduleDetail(scheduleId),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (snapshot.hasError) {
//             return Center(child: Text("오류: ${snapshot.error}"));
//           }
//           if (snapshot.hasData) {
//             return ListTile(
//               title: Text(snapshot.data!.scheduleTitle),
//               subtitle: Text("${snapshot.data!.startDate} - ${snapshot.data!.endDate}"),
//               trailing: Text(snapshot.data!.place ?? '장소 없음'),
//             );
//           }
//           return const Center(child: Text("데이터가 없습니다"));
//         },
//       ),
//     );
//   }
// }
