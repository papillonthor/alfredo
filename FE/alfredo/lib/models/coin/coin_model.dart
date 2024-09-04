import 'package:json_annotation/json_annotation.dart';

part 'coin_model.g.dart';

@JsonSerializable()
class Coin {
  final int coinId;
  final int totalCoin;
  final int todayCoin;

  Coin({
    required this.coinId,
    required this.totalCoin,
    required this.todayCoin,
  });

  factory Coin.fromJson(Map<String, dynamic> json) => _$CoinFromJson(json);
  Map<String, dynamic> toJson() => _$CoinToJson(this);
}
