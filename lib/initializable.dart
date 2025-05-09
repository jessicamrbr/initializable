import 'dart:async';

import 'package:async/async.dart';

class Initializable with InitializableMixin {
  Initializable() {
    initialize();
  }
}

/// A mixin that provides lifecycle management for asynchronous operations on life cycle stages.
/// 
/// This mixin can be used to handle initialization, disposal, and other
/// lifecycle-related tasks in a consistent manner for classes that deal
/// with asynchronous operations.
mixin InitializableMixin {
  Completer<bool> _initialized = Completer<bool>();

  CancelableOperation? _initOperation;

  /// A getter that indicates whether the asynchronous initialization process 
  /// has been completed. Is *Sincronous*, returns `true` if the initialization is complete, 
  /// otherwise `false`.
  bool get isInitialized => _initialized.isCompleted;


  /// A `Future` that completes with `true` when the object is fully initialized
  /// and ready for use.
  ///
  /// This can be used to await the readiness of the object before performing
  /// operations that depend on its initialization.
  Future<bool> get isReady => _initialized.future;


  /// A getter that returns the timeout limit for initialization stage.
  /// 
  /// The timeout limit is set to a constant duration of 5 seconds.
  get timeOutLimit => const Duration(seconds: 50);

  /// Starts the lifecycle process. This method is typically used to 
  /// asynchronous initialization, normaly invoke on class constructor.
  void initialize() {
    _initOperation = CancelableOperation.fromFuture(
      onInit().timeout(
        timeOutLimit, 
        onTimeout: () => _initialized.completeError(
          TimeoutException('Timeout on initialization provider ${runtimeType.toString()}', timeOutLimit),
        ),
      )
    );

    _initOperation!
      .thenOperation(
        (_, __) { 
          _initialized.complete(true);
          onReady();
        },
        onError: (e, s, _) => _initialized.completeError(e, s)
      );
  }

  /// Called during the initialization phase of the lifecycle.
  /// 
  /// This method is asynchronous and can be overridden to perform
  /// any setup or initialization tasks that need to be completed
  /// before the object is fully ready.
  /// 
  /// Override this method to include custom initialization logic.
  Future<void> onInit() async { }

  /// Called when the object is ready to perform its tasks.
  /// 
  /// This method can be overridden to execute any asynchronous
  /// initialization logic or setup that needs to occur after
  /// the object is fully initialized and ready.
  /// 
  /// By default, this method does nothing.
  Future<void> onReady() async { }


  /// Forces the state to be marked as ready, bypassing any asynchronous 
  /// initialization or lifecycle checks. This can be useful in scenarios 
  /// where immediate readiness is required, but should be used with caution 
  /// as it may lead to unexpected behavior if the state is not fully initialized.
  ///
  /// Use this method sparingly and ensure that the state is in a consistent 
  /// and valid condition before calling it.
  void forceReady({
    bool fail = false, 
    String errorMsg = 'Interrupt initialization',
  }) {
    if (
      _initOperation != null 
      && !_initOperation!.isCompleted
      && !_initOperation!.isCanceled
    ) {
      _initOperation!.cancel();
    }

    if (fail) {
      _initialized.completeError(Exception(errorMsg));
    } else {
      _initialized.complete(true);
    }
  }

  void reInitialize() {
    if (
      _initOperation != null 
      && !_initOperation!.isCompleted
      && !_initOperation!.isCanceled
    ) {
      _initOperation!.cancel();
    }

    if (!_initialized.isCompleted) {
      _initialized.completeError(Exception('Reinitializing object type ${runtimeType.toString()}'));
    }

    _initialized = Completer<bool>();

    initialize();
  }
}

