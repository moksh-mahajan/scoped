import 'package:scoped/src/scoped.dart';
import 'package:test/test.dart';

void main() {
  group('Scoped', () {
    test('read throws StateError when ref is not available', () {
      final value = create(() => 42);
      expect(() => read(value), throwsStateError);
    });

    test('read uses orElse when ref is not available', () {
      final value = create(() => 42);
      expect(read(value, orElse: () => 24), equals(24));
    });

    test('calls onError when uncaught exception occurs', () {
      final value = create(() => 42);
      late final Object exception;
      runScopedGuarded(
        () => read(value),
        onError: (error, _) => exception = error,
      );
      expect(exception, isNotNull);
    });

    test('read accesses the value when ref is available', () {
      final ref = create(() => 42);
      runScoped(
        () => expect(read(ref), equals(42)),
        values: {ref},
      );
    });

    test('value is computed lazily and cached', () {
      var createCallCount = 0;
      final ref = create(() {
        createCallCount++;
        return 42;
      });

      expect(createCallCount, equals(0));

      runScoped(
        () {
          read(ref);
          read(ref);
          read(ref);
        },
        values: {ref},
      );

      expect(createCallCount, equals(1));
    });

    test('value can be overridden', () {
      final ref = create(() => 42);

      runScoped(
        () {
          expect(read(ref), equals(42));

          runScoped(
            () {
              expect(read(ref), equals(0));
            },
            values: {ref.overrideWith(() => 0)},
          );
        },
        values: {ref},
      );
    });

    test('overrides are considered equal', () {
      final ref = create(() => 42);
      final override = ref.overrideWith(() => 24);
      expect(ref, equals(override));
      expect(ref.hashCode, equals(override.hashCode));
    });

    test('same instance is equal', () {
      final ref = create(() => 42);
      expect(ref, equals(ref));
    });

    test('different instances are not equal', () {
      final ref1 = create(() => 42);
      final ref2 = create(() => 42);

      expect(ref1, isNot(equals(ref2)));
      expect(ref1.hashCode, isNot(equals(ref2.hashCode)));
    });
  });
}
