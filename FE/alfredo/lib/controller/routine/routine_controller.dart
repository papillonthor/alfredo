import 'package:alfredo/api/routine/routine_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/routine/routine_model.dart';
import '../../provider/user/future_provider.dart';

class RoutineController {
  final RoutineApi api = RoutineApi();
  final ProviderRef ref;
  RoutineController(this.ref);

  Future<List<Routine>> getAllRoutines(WidgetRef ref) async {
    final idToken = await ref.read(authManagerProvider.future);

    if (idToken == null || idToken.isEmpty) {
      throw Exception("ID Token not found or empty.");
    }

    return await api.getAllRoutines(idToken);
  }

  Future<void> createRoutine(
      WidgetRef ref,
      String routineTitle,
      String startTime,
      List<String> days,
      String alarmSound,
      String memo,
      int basicRoutineId) async {
    final idToken = await ref.read(authManagerProvider.future);
    if (idToken == null || idToken.isEmpty) {
      throw Exception("ID Token not found or empty.");
    }

    await api.createRoutine(idToken, routineTitle, startTime, days, alarmSound,
        memo, basicRoutineId);
  }
}
