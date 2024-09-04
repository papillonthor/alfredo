import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../provider/user/user_state_provider.dart';
import 'package:intl/intl.dart';
import '../../components/chart/bar_chart.dart';
import '../../components/chart/chart_container.dart';
import './user_update.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../controller/user/mute_controller.dart';
import '../user/loading_screen.dart';
import '../achieve/achieve_detail_screen.dart';
import 'package:workmanager/workmanager.dart';

class MyPage extends ConsumerWidget {
  const MyPage({super.key});

  void openUserUpdateModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return const FractionallySizedBox(
          heightFactor: 0.91,
          child: UserUpdateScreen(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xfff0d2338),
        iconTheme: const IconThemeData(color: Color(0xFFF2E9E9)),
        title: const Text(
          '마이페이지',
          style: TextStyle(
            color: Color(0xFFF2E9E9),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      backgroundColor: const Color(0xFFF2E9E9),
      body: userState.when(
        data: (user) => ListView(
          padding: const EdgeInsets.only(top: 30),
          children: [
            Padding(
              padding:
                  const EdgeInsets.only(left: 20.0, bottom: 26.0, right: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    user.nickname,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AchieveDetailScreen(),
                        ),
                      );
                    },
                    child: const Row(
                      children: [
                        Icon(
                          Icons.emoji_events_outlined,
                          size: 40,
                          color: Colors.amber,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '업적',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xfff0d2338),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFF0D2338)),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('내 정보',
                          style: Theme.of(context).textTheme.titleLarge),
                      IconButton(
                        icon: const Icon(Icons.settings),
                        onPressed: () {
                          // 모달 여는 함수 호출
                          openUserUpdateModal(context);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('이메일: '),
                      Text(user.email ?? '이메일 없음'),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('생일: '),
                      Text(
                        user.birth != null
                            ? DateFormat('yyyy-MM-dd').format(user.birth!)
                            : '생일 없음',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30.0),
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 80,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                child: const Text(
                  '오늘 한 일',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 30.0),
            const ChartContainer(
                title: '요일별 달성',
                color: Color(0xffD6C3C3),
                chart: BarChartContent()),
            const SizedBox(height: 20.0),
            Padding(
              padding: const EdgeInsets.all(38.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.volume_off),
                    iconSize: 30,
                    onPressed: () {
                      MuteController.toggleMute();
                      print("Mute toggled");
                    },
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.exit_to_app),
                        color: Colors.red,
                        iconSize: 30,
                        onPressed: () async {
                          try {
                            await FirebaseAuth.instance.signOut();
                            await Workmanager().cancelAll(); // 백그라운드 작업 취소
                            print("Logged out");
                            Navigator.pushReplacementNamed(context, '/');
                          } catch (e) {
                            print("Logout failed: $e");
                          }
                        },
                      ),
                      const Text('로그아웃', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ],
              ),
            ),
            // const SizedBox(height: 20.0),
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 38.0),
            //   child: ElevatedButton(
            //     onPressed: () {
            //       Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //             builder: (context) => const UserRoutineTestPage()),
            //       );
            //     },
            //     child: const Text('User Routine Test로 이동'),
            //   ),
            // ),
          ],
        ),
        loading: () => const MyLoadingScreen(),
        error: (error, stack) => Text('Error: $error'),
      ),
    );
  }
}
