import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';

class AuthService {
  final Dio _dio;
  static const String _tokenKey = 'auth_token';

  AuthService({String? baseUrl})
    : _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl ?? ApiClient.defaultBaseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

  Future<bool> requestOtp(String email) async {
    try {
      final response = await _dio.post(
        '/auth/request-otp',
        data: {'email': email},
      );
      return response.data['ok'] == true;
    } on DioException catch (e) {
      print('OTP Request Error: ${e.type} - ${e.message}');
      print('Response: ${e.response?.data}');
      return false;
    } catch (e) {
      print('Unknown OTP Request Error: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> verifyOtp(String email, String code) async {
    try {
      final response = await _dio.post(
        '/auth/verify-otp',
        data: {'email': email, 'code': code},
      );
      if (response.data['ok'] == true) {
        final token = response.data['token'];
        await saveToken(token);
        return response.data;
      }
      return null;
    } on DioException catch (e) {
      print('OTP Verify Error: ${e.type} - ${e.message}');
      print('Response: ${e.response?.data}');
      return null;
    } catch (e) {
      print('Unknown OTP Verify Error: $e');
      return null;
    }
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
