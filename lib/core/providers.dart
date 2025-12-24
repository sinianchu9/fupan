import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api/api_client.dart';
import '../core/session/user_session.dart';

final userSessionProvider = Provider<UserSession>((ref) => UserSession());

final apiClientProvider = Provider<ApiClient>((ref) {
  final userSession = ref.watch(userSessionProvider);
  return ApiClient(userSession: userSession);
});
