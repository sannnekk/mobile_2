import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_2/core/utils/debouncer.dart';

void main() {
  group('Debouncer', () {
    test('debounces function calls', () async {
      final debouncer = Debouncer(delay: const Duration(milliseconds: 100));
      int callCount = 0;

      // Call multiple times quickly
      debouncer.debounce(() => callCount++);
      debouncer.debounce(() => callCount++);
      debouncer.debounce(() => callCount++);

      // Should not have executed yet
      expect(callCount, 0);

      // Wait for debounce delay
      await Future.delayed(const Duration(milliseconds: 150));

      // Should have executed once
      expect(callCount, 1);

      debouncer.dispose();
    });

    test('cancels previous calls', () async {
      final debouncer = Debouncer(delay: const Duration(milliseconds: 100));
      int callCount = 0;

      // Call once
      debouncer.debounce(() => callCount++);
      await Future.delayed(const Duration(milliseconds: 50));

      // Call again, should cancel first
      debouncer.debounce(() => callCount++);

      // Wait for the new delay
      await Future.delayed(const Duration(milliseconds: 110));

      // First call should not have executed, second should
      expect(callCount, 1);

      debouncer.dispose();
    });

    test('dispose cancels pending calls', () async {
      final debouncer = Debouncer(delay: const Duration(milliseconds: 100));
      int callCount = 0;

      debouncer.debounce(() => callCount++);
      debouncer.dispose();

      // Wait for delay
      await Future.delayed(const Duration(milliseconds: 150));

      // Should not have executed
      expect(callCount, 0);
    });
  });
}
