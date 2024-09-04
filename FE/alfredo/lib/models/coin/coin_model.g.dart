// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coin_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Coin _$CoinFromJson(Map<String, dynamic> json) => Coin(
      coinId: (json['coinId'] as num).toInt(),
      totalCoin: (json['totalCoin'] as num).toInt(),
      todayCoin: (json['todayCoin'] as num).toInt(),
    );

Map<String, dynamic> _$CoinToJson(Coin instance) => <String, dynamic>{
      'coinId': instance.coinId,
      'totalCoin': instance.totalCoin,
      'todayCoin': instance.todayCoin,
    };
