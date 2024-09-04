import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../api/achieve/achieve_api.dart';
import '../../models/achieve/achieve_model.dart';
import '../../provider/user/future_provider.dart';
import '../../provider/achieve/achieve_provider.dart';

class AchieveController {
  final AchieveApi api = AchieveApi();
  final ProviderRef ref;

  AchieveController(this.ref);

  // 업적 테이블 생성 메서드
  Future<void> createAchieve() async {
    final token = await ref.read(authManagerProvider.future);
    if (token != null) {
      await api.createAchieve(token);
      ref.refresh(achieveProvider); // 업적 데이터를 새로고침하는 provider
    } else {
      throw Exception('User not authenticated');
    }
  }

  // 업적 테이블 조회 메서드
  Future<Achieve> detailAchieve() async {
    final token = await ref.read(authManagerProvider.future);
    if (token != null) {
      return await api.detailAchieve(token);
    } else {
      throw Exception('User not authenticated');
    }
  }

  // 2번째 업적 - 첫 ical 등록 메서드
  Future<void> checkTimeAchieve() async {
    final token = await ref.read(authManagerProvider.future);
    if (token != null) {
      await api.checkTimeAchieve(token);
      ref.refresh(achieveProvider);
    } else {
      throw Exception('User not authenticated');
    }
  }

  // 2번째 업적 - 첫 ical 등록 메서드
  Future<void> checkFirstIcal() async {
    final token = await ref.read(authManagerProvider.future);
    if (token != null) {
      await api.checkFirstIcal(token);
      ref.refresh(achieveProvider);
    } else {
      throw Exception('User not authenticated');
    }
  }

  // 3번째 업적 - day 풀 참가 메서드
  Future<void> checkWeekendAchieve() async {
    final token = await ref.read(authManagerProvider.future);
    if (token != null) {
      await api.checkWeekendAchieve(token);
      ref.refresh(achieveProvider);
    } else {
      throw Exception('User not authenticated');
    }
  }

  // 4번째 업적 - 총 루틴 갯수 메서드
  Future<void> checkTotalRoutineAchieve() async {
    final token = await ref.read(authManagerProvider.future);
    if (token != null) {
      await api.checkTotalRoutineAchieve(token);
      ref.refresh(achieveProvider);
    } else {
      throw Exception('User not authenticated');
    }
  }

  // 5번째 업적 - 총 투두 갯수 메서드
  Future<void> checkTotalTodoAchieve() async {
    final token = await ref.read(authManagerProvider.future);
    if (token != null) {
      await api.checkTotalTodoAchieve(token);
      ref.refresh(achieveProvider);
    } else {
      throw Exception('User not authenticated');
    }
  }

  // 6번째 업적 - 총 일정 갯수 메서드
  Future<void> checkTotalScheduleAchieve() async {
    final token = await ref.read(authManagerProvider.future);
    if (token != null) {
      await api.checkTotalScheduleAchieve(token);
      ref.refresh(achieveProvider);
    } else {
      throw Exception('User not authenticated');
    }
  }

  // 9번째 업적 - 생일인 경우 메서드
  Future<void> checkBirthAchieve() async {
    final token = await ref.read(authManagerProvider.future);
    if (token != null) {
      await api.checkBirthAchieve(token);
      ref.refresh(achieveProvider);
    } else {
      throw Exception('User not authenticated');
    }
  }
}
