import 'package:alfredo/provider/calendar/calendar_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/schedule/schedule_api.dart'; // API 호출을 위한 경로 수정
import '../../models/schedule/schedule_model.dart'; // 모델 클래스 경로 수정
import '../../provider/user/future_provider.dart';

class ScheduleController {
  final ScheduleApi api = ScheduleApi();
  final ProviderRef ref;

  ScheduleController(this.ref);

  // 모든 스케줄을 가져오는 메서드
  Future<List<Schedule>> getSchedules() async {
    // provider에서 토큰을 가져옴
    final token = await ref.read(authManagerProvider.future);
    if (token != null) {
      return await api.fetchSchedules(token);
    } else {
      throw Exception('User not authenticated');
    }
  }

  // 스케줄 생성 메서드
  Future<Schedule> createSchedule(Schedule schedule) async {
    final token = await ref.read(authManagerProvider.future);
    if (token != null) {
      var returndata = await api.createSchedule(schedule, token);
      ref.refresh(loadSchedule);
      return returndata;
    } else {
      throw Exception('Authentication token not available');
    }
  }

  // 특정 스케줄의 상세 정보를 가져오는 메서드
  // 사용 안해도 수정에서 사용한다
  Future<Schedule> getScheduleDetail(int id) async {
    return await api.getScheduleDetail(id);
  }

  // 스케줄 수정 메서드
  Future<void> updateSchedule(int id, Schedule schedule) async {
    await api.updateSchedule(id, schedule);
    ref.refresh(loadSchedule);
  }

  // 스케줄 삭제 메서드
  Future<void> deleteSchedule(int id) async {
    await api.deleteSchedule(id);
    ref.refresh(loadSchedule);
  }
}
