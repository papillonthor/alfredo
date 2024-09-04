import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/routine/routine_api.dart';
import '../../models/routine/routine_model.dart'; //g.dart로 해야 되나?
import '../../provider/user/future_provider.dart';

// RoutineController를 위한 Provider 정의
final routineProvider = FutureProvider.autoDispose<List<Routine>>((ref) async {
  final idToken = await ref.watch(authManagerProvider.future);

  // final String routineBaseUrl = dotenv.env['ROUTINE_API_URL']!;
  // var url = Uri.parse('$routineBaseUrl/all');
  // final response = await http.get(
  //   url,
  //   headers: {
  //     'Content-Type': 'application/json',
  //     'Authorization': 'Bearer $idToken',
  //   },
  // );
  final routineApi = RoutineApi();
  final routines = await routineApi.getAllRoutines(idToken);
  return routines;
});
