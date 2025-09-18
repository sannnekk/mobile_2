import 'package:mobile_2/core/api/api_response.dart';

/// Result of handling an API response
class ApiResult<T> {
  final bool isSuccess;
  final T? data;
  final String? error;

  const ApiResult._({required this.isSuccess, this.data, this.error});

  /// Creates a successful result with data
  factory ApiResult.success(T data) {
    return ApiResult._(isSuccess: true, data: data);
  }

  /// Creates an error result with message
  factory ApiResult.error(String error) {
    return ApiResult._(isSuccess: false, error: error);
  }
}

/// Utility class for handling API responses in a standardized way
class ApiResponseHandler {
  /// Handles an API response and returns a standardized result
  static ApiResult<T> handle<T>(ApiResponse<T> response) {
    if (response is ApiSingleResponse<T>) {
      return ApiResult.success(response.data);
    } else if (response is ApiListResponse<T>) {
      // For list responses, we return the list as data
      // This might need adjustment based on specific use cases
      return ApiResult.success(response.data as T);
    } else if (response is ApiErrorResponse) {
      return ApiResult.error(response.error);
    } else if (response is ApiEmptyResponse) {
      // For empty responses, we consider it success with null data
      return ApiResult.success(null as T);
    } else {
      return ApiResult.error('Неизвестная ошибка');
    }
  }

  /// Handles an API call with error catching
  static Future<ApiResult<T>> handleCall<T>(
    Future<ApiResponse<T>> Function() apiCall,
  ) async {
    try {
      final response = await apiCall();
      return handle(response);
    } catch (e) {
      return ApiResult.error('Ошибка сети: ${e.toString()}');
    }
  }
}
