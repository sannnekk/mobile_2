import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_2/core/providers/auth_providers.dart';
import 'package:mobile_2/core/entities/auth_payload.dart';
import 'package:mobile_2/core/entities/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  test('logout clears authentication data', () async {
    // Setup: login first
    final notifier = container.read(authStateProvider.notifier);
    final payload = AuthPayload(
      userId: 'u1',
      username: 'test',
      role: UserRole.student,
    );
    await notifier.login('test_token', payload, user: null);

    // Verify logged in
    expect(notifier.state.isAuthenticated, true);
    expect(notifier.state.token, 'test_token');
    expect(notifier.state.userPayload?.userId, 'u1');

    // Logout
    await notifier.logout();

    // Verify logged out
    expect(notifier.state.isAuthenticated, false);
    expect(notifier.state.token, null);
    expect(notifier.state.userPayload, null);
    expect(notifier.state.user, null);

    // Verify SharedPreferences cleared
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('api_token'), null);
    expect(prefs.getString('api_payload'), null);
    expect(prefs.getString('api_user'), null);
  });
}
