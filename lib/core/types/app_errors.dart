import 'package:dio/dio.dart';

/// Custom error types for better error handling throughout the app

abstract class AppError implements Exception {
  final String message;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const AppError(this.message, {this.originalError, this.stackTrace});

  @override
  String toString() => '$runtimeType: $message';
}

class NetworkError extends AppError {
  const NetworkError(
    String message, {
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(message, originalError: originalError, stackTrace: stackTrace);
}

class AuthError extends AppError {
  const AuthError(
    String message, {
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(message, originalError: originalError, stackTrace: stackTrace);
}

class ValidationError extends AppError {
  const ValidationError(
    String message, {
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(message, originalError: originalError, stackTrace: stackTrace);
}

class ServerError extends AppError {
  final int? statusCode;
  const ServerError(
    String message, {
    this.statusCode,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(message, originalError: originalError, stackTrace: stackTrace);
}

class UnknownError extends AppError {
  const UnknownError(
    String message, {
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(message, originalError: originalError, stackTrace: stackTrace);
}

/// Utility function to convert DioException to AppError
AppError dioExceptionToAppError(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return NetworkError(
        'Request timeout',
        originalError: e,
        stackTrace: e.stackTrace,
      );
    case DioExceptionType.badResponse:
      final statusCode = e.response?.statusCode;
      if (statusCode == 401) {
        return AuthError(
          'Unauthorized',
          originalError: e,
          stackTrace: e.stackTrace,
        );
      } else if (statusCode != null && statusCode >= 400 && statusCode < 500) {
        return ValidationError(
          'Client error: $statusCode',
          originalError: e,
          stackTrace: e.stackTrace,
        );
      } else if (statusCode != null && statusCode >= 500) {
        return ServerError(
          'Server error: $statusCode',
          statusCode: statusCode,
          originalError: e,
          stackTrace: e.stackTrace,
        );
      }
      return ServerError(
        'Bad response',
        originalError: e,
        stackTrace: e.stackTrace,
      );
    case DioExceptionType.cancel:
      return NetworkError(
        'Request cancelled',
        originalError: e,
        stackTrace: e.stackTrace,
      );
    case DioExceptionType.connectionError:
      return NetworkError(
        'Connection error',
        originalError: e,
        stackTrace: e.stackTrace,
      );
    case DioExceptionType.badCertificate:
      return NetworkError(
        'Certificate error',
        originalError: e,
        stackTrace: e.stackTrace,
      );
    case DioExceptionType.unknown:
      return UnknownError(
        'Unknown error',
        originalError: e,
        stackTrace: e.stackTrace,
      );
  }
}
