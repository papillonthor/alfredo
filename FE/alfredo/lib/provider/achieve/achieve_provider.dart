import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/achieve/achieve_model.dart';
import '../../controller/achieve/achieve_controller.dart';

// AchieveController를 위한 Provider 정의
final achieveControllerProvider = Provider<AchieveController>((ref) {
  return AchieveController(ref);
  // ref를 인자로 받아 AchieveController를 생성하여 반환합니다.
  // AchieveController는 API 호출을 관리합니다.
});

// Achieve 데이터를 관리하는 FutureProvider 정의
final achieveProvider = FutureProvider<Achieve>((ref) async {
  final achieveController = ref.read(achieveControllerProvider);
  // achieveControllerProvider를 읽어 AchieveController 인스턴스를 가져옵니다.
  return await achieveController.detailAchieve();
  // AchieveController의 detailAchieve 메서드를 호출하여 업적 데이터를 가져옵니다.
});
