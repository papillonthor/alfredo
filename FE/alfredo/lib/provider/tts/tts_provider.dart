import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../api/tts/tts_api.dart';

final ttsApiProvider = Provider<TtsApi>((ref) {
  return TtsApi(); // API 인스턴스 생성
});

final ttsSummaryProvider =
    FutureProvider.family<String, String>((ref, authToken) {
  final ttsApi = ref.read(ttsApiProvider);
  return ttsApi.fetchSummary(authToken);
});
