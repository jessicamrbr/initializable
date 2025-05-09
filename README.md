# Initializable

[![pub package](https://img.shields.io/pub/v/initializable.svg)](https://pub.dev/packages/initializable)

A mixin to manage asynchronous operations during object lifecycle events in Dart.

## Overview

Initializable provides a mixin that makes it easy to control the asynchronous initialization lifecycle in Dart objects, especially useful in situations where you need to ensure instances are ready before use.

- Asynchronous initialization control with timeout.
- Methods to force readiness or failure.
- Safe re-initialization.
- Easy integration with tests.

## Usage

Basic Example

```dart
import 'package:initializable/initializable.dart';

class MyService extends Initializable {
  @override
  Future<void> onInit() async {
    // Simulate an asynchronous initialization
    await Future.delayed(Duration(seconds: 2));
    // Initialization complete
  }

  @override
  Future<void> onReady() async {
    // Code to run after initialization
  }
}

void main() async {
  final service = MyService();

  // Wait until the service is ready
  await service.isReady;
  print('Service initialized!');
}
```

Initialization Timeout

You can set a timeout for initialization by overriding `timeOutLimit`:

```dart
class MyService extends Initializable {
  @override
  get timeOutLimit => const Duration(seconds: 5);

  @override
  Future<void> onInit() async {
    // ...
  }
}
```

Forcing Readiness or Failure

```dart
final service = MyService();
service.forceReady(); // Marks as ready immediately
service.forceReady(fail: true, errorMsg: 'Initialization failed'); // Marks as error
```

Re-initialization

```dart
service.reInitialize();
```

# API
- `isInitialized: bool` - Indicates if initialization is complete.
- `isReady: Future<bool>` - Completes when the object is ready.
- `onInit(): Future<void>` - Override for initialization logic.
- `onReady(): Future<void>` - Override for post-initialization logic.
- `forceReady({bool fail = false, String errorMsg})` - Forces the state to ready or error.
- `reInitialize()` - Re-initializes the object.
