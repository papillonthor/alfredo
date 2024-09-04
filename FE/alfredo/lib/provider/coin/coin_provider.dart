import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/coin/coin_model.dart';
import '../../controller/coin/coin_controller.dart';

final coinControllerProvider = Provider<CoinController>((ref) {
  return CoinController(ref);
});

final coinProvider = FutureProvider<Coin>((ref) async {
  final coinController = ref.read(coinControllerProvider);
  return await coinController.getCoinDetail();
});
