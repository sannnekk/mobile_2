/// API response types for the app
/// - Single object: { data: {...} }
/// - List: { data: [...], meta: { total: int } }
/// - Error: { error: string }
library;

abstract class ApiResponse<T> {}

class ApiSingleResponse<T> extends ApiResponse<T> {
  final T data;
  ApiSingleResponse(this.data);
}

class ApiListResponse<T> extends ApiResponse<T> {
  final List<T> data;
  final int total;
  ApiListResponse(this.data, this.total);
}

class ApiErrorResponse extends ApiResponse<Never> {
  final String error;
  ApiErrorResponse(this.error);
}

/// Represents a successful response with no body (e.g., HTTP 204 No Content)
class ApiEmptyResponse extends ApiResponse<void> {}
