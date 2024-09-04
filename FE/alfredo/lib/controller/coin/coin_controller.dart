import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../api/coin/coin_api.dart';
import '../../models/coin/coin_model.dart';
import '../../provider/user/future_provider.dart';
import '../../provider/coin/coin_provider.dart';

class CoinController {
  final CoinApi api = CoinApi();
  final ProviderRef ref;

  CoinController(this.ref);

  Future<void> createCoin() async {
    final token = await ref.read(authManagerProvider.future);
    if (token != null) {
      await api.createCoin(token);
      ref.refresh(coinProvider);
    } else {
      throw Exception('User not authenticated');
    }
  }

  Future<Coin> getCoinDetail() async {
    final token = await ref.read(authManagerProvider.future);
    if (token != null) {
      return await api.getCoinDetail(token);
    } else {
      throw Exception('User not authenticated');
    }
  }

  Future<void> incrementCoin() async {
    final token = await ref.read(authManagerProvider.future);
    if (token != null) {
      await api.incrementCoin(token);
      ref.refresh(coinProvider);
    } else {
      throw Exception('User not authenticated');
    }
  }

  Future<void> decrementCoin() async {
    final token = await ref.read(authManagerProvider.future);
    if (token != null) {
      await api.decrementCoin(token);
      ref.refresh(coinProvider);
    } else {
      throw Exception('User not authenticated');
    }
  }

  Future<void> decrementTotalCoin(int decrementValue) async {
    final token = await ref.read(authManagerProvider.future);
    if (token != null) {
      await api.decrementTotalCoin(token, decrementValue);
      ref.refresh(coinProvider);
    } else {
      throw Exception('User not authenticated');
    }
  }
}
