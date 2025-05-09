import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:initializable/initializable.dart';

class TestAsyncLifeCycle extends Initializable {
  bool onInitCalled = false;
  bool onReadyCalled = false;

  @override
  Future<void> onInit() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    await super.onInit();
    onInitCalled = true;
  }

  @override
  Future<void> onReady() async {
    await super.onReady();
    onReadyCalled = true;
  }
}

class TestAsyncLifeCycleTimeout extends Initializable {
  bool onInitCalled = false;
  @override
  get timeOutLimit => const Duration(milliseconds: 100);

  @override
  Future<void> onInit() async {
    await Future.delayed(const Duration(milliseconds: 500));
    onInitCalled = true;
  }
}

void main() {
  group('AsyncLifeCycleMixin Tests', () {
    test('Initialization completes successfully', () async {
      final lifeCycle1 = TestAsyncLifeCycle();

      expect(lifeCycle1.isInitialized, isFalse);
      await lifeCycle1.isReady;
      expect(lifeCycle1.isInitialized, isTrue);
      expect(lifeCycle1.onInitCalled, isTrue);
      await Future.delayed(const Duration(milliseconds: 100));
      expect(lifeCycle1.onReadyCalled, isTrue);
    });

    test('Initialization fails with error', () async {
      final lifeCycle2 = TestAsyncLifeCycle();

      lifeCycle2.forceReady(fail: true, errorMsg: 'Initialization failed');

      await expectLater(
        lifeCycle2.isReady,
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('Initialization failed'))),
      );
      expect(lifeCycle2.isInitialized, isTrue);
    });

    test('Initialization times out', () async {
      final lifeCycle3 = TestAsyncLifeCycleTimeout();

      expect(
        lifeCycle3.isReady,
        throwsA(isA<TimeoutException>()),
      );
    });

    test('Force readiness without failure', () async {
      final lifeCycle4 = TestAsyncLifeCycleTimeout();

      lifeCycle4.forceReady();
      expect(lifeCycle4.isInitialized, isTrue);
      await expectLater(await lifeCycle4.isReady, isTrue);
    });
  });
}