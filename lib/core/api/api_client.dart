import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/utils/logger.dart';
import '../../core/types/app_errors.dart';
import 'api_response.dart';
import 'api_config.dart';
import 'interceptors.dart';
import 'query_params.dart';

/// Callback signatures for UI hooks
typedef ErrorPopup = void Function(String message, {bool incloseable});
typedef LoadingOverlay = void Function(bool show);
typedef RedirectToLogin = void Function();
typedef PromptPassword = Future<String?> Function();

enum ApiRequestType { get, post, put, delete, patch }

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  String? _token;
  Map<String, dynamic>? _payload;
  ErrorPopup? errorPopup;
  LoadingOverlay? loadingOverlay;
  RedirectToLogin? redirectToLogin;
  PromptPassword? promptPassword;
  late final Dio _dio;
  late final ApiConfig _config;

  static const _tokenKey = 'api_token';
  static const _payloadKey = 'api_payload';

  Future<void> init({ApiConfig? config, Dio? dio}) async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    final payloadStr = prefs.getString(_payloadKey);
    if (payloadStr != null) {
      _payload = jsonDecode(payloadStr);
    }
    _config = config ?? ApiConfig.fromEnv();
    _dio = dio ?? _createDio(_config);
  }

  Dio _createDio(ApiConfig config) {
    final dio = Dio(
      BaseOptions(
        baseUrl: config.baseUrl,
        connectTimeout: config.connectTimeout,
        receiveTimeout: config.receiveTimeout,
        headers: {'Content-Type': 'application/json'},
      ),
    );
    dio.interceptors.add(AuthInterceptor(() => _token));
    return dio;
  }

  Future<void> setToken(String token, Object payload) async {
    _token = token;
    if (payload is Map<String, dynamic>) {
      _payload = payload;
    } else {
      // Fallback: try to convert known typed payloads via toJson
      try {
        // ignore: avoid_dynamic_calls
        final json = (payload as dynamic).toJson() as Map<String, dynamic>;
        _payload = json;
      } catch (_) {
        // As a last resort, stringify then decode
        _payload = jsonDecode(jsonEncode(payload)) as Map<String, dynamic>;
      }
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_payloadKey, jsonEncode(_payload));
  }

  Future<void> clearToken() async {
    _token = null;
    _payload = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_payloadKey);
  }

  String? get token => _token;
  Map<String, dynamic>? get payload => _payload;

  /// Main request method
  Future<ApiResponse<T>> request<T>({
    required String path,
    ApiRequestType method = ApiRequestType.get,
    Map<String, String>? headers,
    dynamic body,
    bool silent = false,
    bool showLoading = false,
    bool requireAuth = true,
    T Function(dynamic)? fromJson,
    bool isList = false,
    QueryParams? queryParams,
    bool acceptEmpty = false,
  }) async {
    if (showLoading) loadingOverlay?.call(true);
    try {
      final options = Options(headers: {...?headers});
      final qp = queryParams?.toMap();
      final response = await _send(
        method,
        path,
        options: options,
        body: body,
        queryParams: qp,
      );
      final status = response.statusCode ?? 0;
      final data = response.data;
      if (status == 401) {
        return await _handle401<T>(
          path: path,
          method: method,
          headers: headers,
          body: body,
          silent: silent,
          showLoading: showLoading,
          requireAuth: requireAuth,
          fromJson: fromJson,
          isList: isList,
          queryParams: queryParams,
          error: (data is Map && data['error'] is String)
              ? data['error'] as String
              : 'Unauthorized',
        );
      }
      if (data is Map && data['error'] != null) {
        final msg = data['error'] as String;
        if (!silent) errorPopup?.call(msg, incloseable: false);
        return ApiErrorResponse(msg);
      }
      if (data is Map && data['data'] != null) {
        final payload = data['data'];
        if (isList && payload is List) {
          final items = payload
              .map<T>((e) => fromJson != null ? fromJson(e) : e as T)
              .toList();
          final total = (data['meta'] is Map && data['meta']['total'] != null)
              ? data['meta']['total'] as int
              : items.length;
          return ApiListResponse<T>(items, total);
        }
        final converted = fromJson != null ? fromJson(payload) : payload as T;
        return ApiSingleResponse<T>(converted);
      }
      // Support 204 No Content or endpoints that return no body
      if (status == 204 ||
          (acceptEmpty &&
              (data == null ||
                  (data is Map &&
                      data['data'] == null &&
                      data['error'] == null)))) {
        return ApiEmptyResponse() as ApiResponse<T>;
      }
      return ApiErrorResponse('Unknown response format');
    } on DioException catch (_) {
      if (!silent) {
        errorPopup?.call(
          'Network error. Please check your connection.',
          incloseable: false,
        );
      }
      return ApiErrorResponse('Network error');
    } catch (e) {
      if (!silent) errorPopup?.call('Unexpected error: $e', incloseable: false);
      return ApiErrorResponse('Unexpected error: $e');
    } finally {
      if (showLoading) loadingOverlay?.call(false);
    }
  }

  // Convenience HTTP methods
  Future<ApiResponse<T>> get<T>({
    required String path,
    QueryParams? queryParams,
    Map<String, String>? headers,
    bool silent = false,
    bool showLoading = false,
    bool requireAuth = true,
    T Function(dynamic)? fromJson,
    bool isList = false,
  }) {
    return request<T>(
      path: path,
      method: ApiRequestType.get,
      headers: headers,
      body: null,
      silent: silent,
      showLoading: showLoading,
      requireAuth: requireAuth,
      fromJson: fromJson,
      isList: isList,
      queryParams: queryParams,
    );
  }

  Future<ApiResponse<T>> post<T>({
    required String path,
    dynamic body,
    QueryParams? queryParams,
    Map<String, String>? headers,
    bool silent = false,
    bool showLoading = false,
    bool requireAuth = true,
    T Function(dynamic)? fromJson,
    bool isList = false,
    bool acceptEmpty = false,
  }) {
    return request<T>(
      path: path,
      method: ApiRequestType.post,
      headers: headers,
      body: body,
      silent: silent,
      showLoading: showLoading,
      requireAuth: requireAuth,
      fromJson: fromJson,
      isList: isList,
      queryParams: queryParams,
      acceptEmpty: acceptEmpty,
    );
  }

  Future<ApiResponse<T>> put<T>({
    required String path,
    dynamic body,
    QueryParams? queryParams,
    Map<String, String>? headers,
    bool silent = false,
    bool showLoading = false,
    bool requireAuth = true,
    T Function(dynamic)? fromJson,
    bool isList = false,
    bool acceptEmpty = false,
  }) {
    return request<T>(
      path: path,
      method: ApiRequestType.put,
      headers: headers,
      body: body,
      silent: silent,
      showLoading: showLoading,
      requireAuth: requireAuth,
      fromJson: fromJson,
      isList: isList,
      queryParams: queryParams,
      acceptEmpty: acceptEmpty,
    );
  }

  Future<ApiResponse<T>> delete<T>({
    required String path,
    dynamic body,
    QueryParams? queryParams,
    Map<String, String>? headers,
    bool silent = false,
    bool showLoading = false,
    bool requireAuth = true,
    T Function(dynamic)? fromJson,
    bool isList = false,
    bool acceptEmpty = false,
  }) {
    return request<T>(
      path: path,
      method: ApiRequestType.delete,
      headers: headers,
      body: body,
      silent: silent,
      showLoading: showLoading,
      requireAuth: requireAuth,
      fromJson: fromJson,
      isList: isList,
      queryParams: queryParams,
      acceptEmpty: acceptEmpty,
    );
  }

  Future<ApiResponse<T>> patch<T>({
    required String path,
    dynamic body,
    QueryParams? queryParams,
    Map<String, String>? headers,
    bool silent = false,
    bool showLoading = false,
    bool requireAuth = true,
    T Function(dynamic)? fromJson,
    bool isList = false,
    bool acceptEmpty = false,
  }) {
    return request<T>(
      path: path,
      method: ApiRequestType.patch,
      headers: headers,
      body: body,
      silent: silent,
      showLoading: showLoading,
      requireAuth: requireAuth,
      fromJson: fromJson,
      isList: isList,
      queryParams: queryParams,
      acceptEmpty: acceptEmpty,
    );
  }

  Future<Response> _send(
    ApiRequestType method,
    String path, {
    Options? options,
    dynamic body,
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      switch (method) {
        case ApiRequestType.get:
          AppLogger.debug('GET $path with queryParams: $queryParams');
          return await _dio.get(
            path,
            queryParameters: queryParams,
            options: options,
          );
        case ApiRequestType.post:
          AppLogger.debug('POST $path with body: $body');
          return await _dio.post(
            path,
            data: body,
            queryParameters: queryParams,
            options: options,
          );
        case ApiRequestType.put:
          AppLogger.debug('PUT $path with body: $body');
          return await _dio.put(
            path,
            data: body,
            queryParameters: queryParams,
            options: options,
          );
        case ApiRequestType.delete:
          AppLogger.debug('DELETE $path');
          return await _dio.delete(
            path,
            data: body,
            queryParameters: queryParams,
            options: options,
          );
        case ApiRequestType.patch:
          AppLogger.debug('PATCH $path with body: $body');
          return await _dio.patch(
            path,
            data: body,
            queryParameters: queryParams,
            options: options,
          );
      }
    } on DioException catch (e) {
      final appError = dioExceptionToAppError(e);
      AppLogger.error(
        'API Error: ${appError.message}',
        appError,
        appError.stackTrace,
      );
      return e.response ??
          Response(
            requestOptions: e.requestOptions,
            statusCode: 0,
            data: {'error': e.message},
          );
    }
  }

  Future<ApiResponse<T>> _handle401<T>({
    required String path,
    required ApiRequestType method,
    Map<String, String>? headers,
    dynamic body,
    required bool silent,
    required bool showLoading,
    required bool requireAuth,
    T Function(dynamic)? fromJson,
    required bool isList,
    QueryParams? queryParams,
    required String error,
  }) async {
    if (_token != null) {
      // Token expired: prompt for password
      if (promptPassword != null) {
        final password = await promptPassword!();
        if (password == null) {
          // User cancelled, force logout
          await clearToken();
          redirectToLogin?.call();
          return ApiErrorResponse('Session expired. Please login again.');
        }
        // Try to refresh token
        final loginResp = await request(
          path: '/auth/login',
          method: ApiRequestType.post,
          body: {
            'usernameOrEmail': _payload?['username'] ?? '',
            'password': password,
          },
          silent: true,
          requireAuth: false,
        );
        if (loginResp is ApiSingleResponse) {
          final data = loginResp.data;
          await setToken(data['token'], data['payload']);
          // Retry original request
          return await request(
            path: path,
            method: method,
            headers: headers,
            body: body,
            silent: silent,
            showLoading: showLoading,
            requireAuth: requireAuth,
            fromJson: fromJson,
            isList: isList,
            queryParams: queryParams,
          );
        } else {
          // Login failed
          await clearToken();
          redirectToLogin?.call();
          return ApiErrorResponse('Session expired. Please login again.');
        }
      } else {
        // No prompt handler, force logout
        await clearToken();
        redirectToLogin?.call();
        return ApiErrorResponse('Session expired. Please login again.');
      }
    } else {
      // No token, redirect to login
      redirectToLogin?.call();
      return ApiErrorResponse(error);
    }
  }
}
