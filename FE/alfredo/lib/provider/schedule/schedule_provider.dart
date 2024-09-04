import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controller/schedule/schedule_controller.dart';

// ScheduleController를 위한 Provider 정의
final scheduleControllerProvider = Provider<ScheduleController>((ref) {
  return ScheduleController(ref);
});
