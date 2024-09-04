import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/user/user_api.dart';
import '../../models/user/user.dart';
import '../../models/user/user_update_dto.dart';
import 'future_provider.dart';

final userProvider = FutureProvider.autoDispose<User>((ref) async {
  final idToken = await ref.watch(authManagerProvider.future);
  if (idToken == null || idToken.isEmpty) {
    throw Exception('No ID Token found');
  }

  return UserApi().getUserInfo(idToken);
});

final userUpdateProvider =
    FutureProvider.family<void, UserUpdateDto>((ref, userUpdateDto) async {
  final idToken = await ref.watch(authManagerProvider.future);
  if (idToken == null || idToken.isEmpty) {
    throw Exception('No ID Token found');
  }

  await UserApi().updateUser(idToken, userUpdateDto);
  await ref.refresh(userProvider.future);
});
