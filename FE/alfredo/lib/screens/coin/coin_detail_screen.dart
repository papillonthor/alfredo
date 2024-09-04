import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/coin/coin_model.dart';
import '../../provider/coin/coin_provider.dart';

class CoinDetailScreen extends ConsumerWidget {
  const CoinDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coinAsyncValue = ref.watch(coinProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("코인 상세", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xff0d2338),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color(0xffD6C3C3),
      body: coinAsyncValue.when(
        data: (coin) => _buildCoinDetail(context, coin, ref),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildCoinDetail(BuildContext context, Coin coin, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Total Coin: ${coin.totalCoin}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            'Today Coin: ${coin.todayCoin}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => _incrementCoins(ref),
                child: const Text('Increment Coins'),
              ),
              ElevatedButton(
                onPressed: () => _decrementCoins(ref),
                child: const Text('Decrement Coins'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _decrementTotalCoins(ref, context),
            child: const Text('Decrement Total Coins by Specific Value'),
          ),
        ],
      ),
    );
  }

  Future<void> _incrementCoins(WidgetRef ref) async {
    final coinController = ref.read(coinControllerProvider);
    await coinController.incrementCoin();
  }

  Future<void> _decrementCoins(WidgetRef ref) async {
    final coinController = ref.read(coinControllerProvider);
    await coinController.decrementCoin();
  }

  Future<void> _decrementTotalCoins(WidgetRef ref, BuildContext context) async {
    final coinController = ref.read(coinControllerProvider);
    final decrementValue = await _showDecrementDialog(context);
    if (decrementValue != null) {
      await coinController.decrementTotalCoin(decrementValue);
    }
  }

  Future<int?> _showDecrementDialog(BuildContext context) async {
    int? decrementValue;
    return showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Decrement Total Coins'),
          content: TextField(
            keyboardType: TextInputType.number,
            decoration:
                const InputDecoration(hintText: "Enter value to decrement"),
            onChanged: (value) {
              decrementValue = int.tryParse(value);
            },
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(null);
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(decrementValue);
              },
            ),
          ],
        );
      },
    );
  }
}
