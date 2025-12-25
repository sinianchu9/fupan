import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api/api_client.dart';
import '../core/session/user_session.dart';

import '../core/api/auth_service.dart';

final userSessionProvider = Provider<UserSession>((ref) => UserSession());

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final apiClientProvider = Provider<ApiClient>((ref) {
  final userSession = ref.watch(userSessionProvider);
  return ApiClient(userSession: userSession);
});
