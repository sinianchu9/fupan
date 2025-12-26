import 'package:dio/dio.dart';
import '../../models/add_event_request.dart';
import '../../models/close_plan_request.dart';
import '../../models/close_plan_response.dart';
import '../../models/weekly_report.dart';
import '../session/user_session.dart';

class ApiClient {
  final Dio dio;
  final UserSession userSession;

  // 可以在此处配置 baseUrl
  static const String defaultBaseUrl =
      "https://pre-trade-journal.kingjoke1991.workers.dev";

  ApiClient({required this.userSession, String? baseUrl})
    : dio = Dio(
        BaseOptions(
          baseUrl: baseUrl ?? defaultBaseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = userSession.token;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          final data = response.data;
          if (data is Map<String, dynamic>) {
            if (data['ok'] == false) {
              return handler.reject(
                DioException(
                  requestOptions: response.requestOptions,
                  response: response,
                  error: data['error'] ?? 'Unknown error',
                  type: DioExceptionType.badResponse,
                ),
              );
            }
          }
          return handler.next(response);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            await userSession.clear();
            // Note: UI redirection should be handled by a listener or router
          }
          return handler.next(e);
        },
      ),
    );
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return dio.get<T>(path, queryParameters: queryParameters);
  }

  Future<Response<T>> post<T>(String path, {dynamic data}) {
    return dio.post<T>(path, data: data);
  }

  // Step 2: 增加业务方法
  Future<List<Map<String, dynamic>>> getWatchlist() async {
    final response = await get('/watchlist');
    return List<Map<String, dynamic>>.from(response.data['items'] ?? []);
  }

  Future<List<Map<String, dynamic>>> getPlans({String? status}) async {
    final response = await get(
      '/plans',
      queryParameters: status != null ? {'status': status} : null,
    );
    return List<Map<String, dynamic>>.from(response.data['items'] ?? []);
  }

  Future<String> createPlan(Map<String, dynamic> data) async {
    final response = await post('/plans/create', data: data);
    return response.data['id'];
  }

  Future<Map<String, dynamic>> getPlanDetail(String planId) async {
    final response = await get('/plans/$planId');
    return response.data;
  }

  Future<void> armPlan(
    String planId, {
    double? actualEntryPrice,
    String? entryDriver,
  }) async {
    await post(
      '/plans/$planId/arm',
      data: {
        if (actualEntryPrice != null) 'actual_entry_price': actualEntryPrice,
        if (entryDriver != null) 'entry_driver': entryDriver,
      },
    );
  }

  Future<void> updatePlan(String planId, Map<String, dynamic> patch) async {
    await dio.post('/plans/$planId/update', data: patch);
  }

  Future<String> addEvent(String planId, AddEventRequest req) async {
    final response = await dio.post(
      '/plans/$planId/add-event',
      data: req.toJson(),
    );
    return response.data['id'];
  }

  Future<ClosePlanResponse> closePlan(
    String planId,
    ClosePlanRequest req,
  ) async {
    final response = await dio.post('/plans/$planId/close', data: req.toJson());
    return ClosePlanResponse.fromJson(response.data);
  }

  Future<List<Map<String, dynamic>>> getArchivedPlans({String? status}) async {
    final response = await get(
      '/plans/archived',
      queryParameters: status != null ? {'status': status} : null,
    );
    return List<Map<String, dynamic>>.from(response.data['items'] ?? []);
  }

  Future<void> archivePlan(String planId) async {
    await post('/plans/$planId/archive');
  }

  Future<void> unarchivePlan(String planId) async {
    await post('/plans/$planId/unarchive');
  }

  Future<WeeklyReport> getWeeklyReport() async {
    final response = await get('/report/weekly');
    return WeeklyReport.fromJson(response.data);
  }

  // ---- self reviews (Step 7) ----
  Future<String> submitSelfReview(
    String planId,
    Map<String, int> scores,
  ) async {
    final response = await post(
      '/reviews/self',
      data: {'plan_id': planId, ...scores},
    );
    return response.data['id'];
  }

  Future<Map<String, dynamic>?> getSelfReview(String planId) async {
    final response = await get('/reviews/self/$planId');
    return response.data['review'];
  }

  // ---- Anomaly Hints ----
  Future<List<Map<String, dynamic>>> getHints() async {
    final response = await get('/hints');
    return List<Map<String, dynamic>>.from(response.data['items'] ?? []);
  }

  Future<void> consumeHint(String id) async {
    await post('/hints/$id/consume');
  }

  Future<void> dismissHint(String id) async {
    await post('/hints/$id/dismiss');
  }

  // ---- Symbols ----
  Future<Map<String, dynamic>> createSymbol(
    String code,
    String name, {
    String? industry,
  }) async {
    final response = await post(
      '/symbols/create',
      data: {
        'code': code,
        'name': name,
        if (industry != null) 'industry': industry,
      },
    );
    return response.data;
  }
}
