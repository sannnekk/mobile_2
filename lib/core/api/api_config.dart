class ApiConfig {
  final String baseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;

  const ApiConfig({
    required this.baseUrl,
    this.connectTimeout = const Duration(seconds: 15),
    this.receiveTimeout = const Duration(seconds: 30),
  });

  // Best-practice: provide a factory that pulls from String.fromEnvironment for
  // release/profile builds and falls back to sane defaults for debug.
  factory ApiConfig.fromEnv() {
    const base = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://api.noo-school.ru',
    );
    const connect = int.fromEnvironment(
      'API_CONNECT_TIMEOUT_SEC',
      defaultValue: 15,
    );
    const receive = int.fromEnvironment(
      'API_RECEIVE_TIMEOUT_SEC',
      defaultValue: 30,
    );
    return ApiConfig(
      baseUrl: base,
      connectTimeout: Duration(seconds: connect),
      receiveTimeout: Duration(seconds: receive),
    );
  }
}
