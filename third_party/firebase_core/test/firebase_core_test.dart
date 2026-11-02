// ignore_for_file: require_trailing_commas
// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$FirebaseApp', () {
    late MockFirebaseCore mock;

    const FirebaseOptions testOptions = FirebaseOptions(
      apiKey: 'apiKey',
      appId: 'appId',
      messagingSenderId: 'messagingSenderId',
      projectId: 'projectId',
    );

    const String testAppName = 'testApp';

    setUp(() {
      final FirebaseAppPlatform platformApp =
          FirebaseAppPlatform(testAppName, testOptions);

      mock = MockFirebaseCore(
        apps: [platformApp],
        appByName: {
          testAppName: platformApp,
        },
        initializeAppHandler: ({name, options}) async {
          expect(name, testAppName);
          expect(options, testOptions);
          return platformApp;
        },
      );

      Firebase.delegatePackingProperty = mock;
    });

    test('.apps', () {
      final List<FirebaseApp> apps = Firebase.apps;

      expect(mock.appsCalled, 1);
      expect(apps[0], Firebase.app(testAppName));
    });

    test('.app()', () {
      final FirebaseApp app = Firebase.app(testAppName);

      expect(mock.appCalls, [testAppName]);
      expect(app.name, testAppName);
      expect(app.options, testOptions);
    });

    test('.initializeApp()', () async {
      final FirebaseApp initializedApp = await Firebase.initializeApp(
        name: testAppName,
        options: testOptions,
      );
      final FirebaseApp app = Firebase.app(testAppName);

      expect(initializedApp, app);
      expect(mock.initializeAppCalls, [
        const InitializeAppCall(name: testAppName, options: testOptions),
      ]);
      expect(mock.appCalls, [testAppName]);
    });

    test('.registerService() and .getService()', () {
      final FirebaseApp app = Firebase.app(testAppName);

      final testService = TestService();
      app.registerService<TestService>(testService);

      expect(app.getService<TestService>(), testService);
    });

    test('.getService() returns null when registry is null', () {
      const String nullAppName = 'nullApp';
      final FirebaseAppPlatform nullPlatformApp =
          FirebaseAppPlatform(nullAppName, testOptions);
      mock.appByName[nullAppName] = nullPlatformApp;

      final FirebaseApp app = Firebase.app(nullAppName);

      expect(app.getService<TestService>(), isNull);
    });

    test('.getService() returns null when service is not registered', () {
      final FirebaseApp app = Firebase.app(testAppName);

      expect(app.getService<AnotherTestService>(), isNull);
    });

    test('.delete() disposes registered services before deleting app',
        () async {
      final calls = <String>[];
      final platformApp = TestFirebaseAppPlatform(
        testAppName,
        testOptions,
        onDelete: () async {
          calls.add('app');
        },
      );
      mock.appByName[testAppName] = platformApp;

      final FirebaseApp app = Firebase.app(testAppName);
      final testService = TestService();
      app.registerService<TestService>(
        testService,
        dispose: (_) async {
          calls.add('service');
        },
      );

      await app.delete();

      expect(calls, <String>['service', 'app']);
      expect(app.getService<TestService>(), isNull);
    });
  });

  test('.initializeApp() with demoProjectId', () async {
    const String demoProjectId = 'demo-project-id';
    const String expectedName = demoProjectId;
    const FirebaseOptions expectedOptions = FirebaseOptions(
      apiKey: '12345',
      // Flutter tests use android as the default platform.
      appId: '1:1:android:1',
      messagingSenderId: '',
      projectId: demoProjectId,
    );

    final FirebaseAppPlatform platformApp =
        FirebaseAppPlatform(expectedName, expectedOptions);
    final mock = MockFirebaseCore(
      apps: [platformApp],
      appByName: {
        expectedName: platformApp,
      },
      initializeAppHandler: ({name, options}) async {
        expect(name, expectedName);
        expect(options, expectedOptions);
        return platformApp;
      },
    );
    Firebase.delegatePackingProperty = mock;

    final FirebaseApp initializedApp = await Firebase.initializeApp(
      demoProjectId: demoProjectId,
    );
    final FirebaseApp app = Firebase.app(expectedName);

    expect(initializedApp, app);
    expect(mock.initializeAppCalls, [
      const InitializeAppCall(name: expectedName, options: expectedOptions),
    ]);
    expect(mock.appCalls, [expectedName]);
  });
}

class MockFirebaseCore extends FirebasePlatform
    with MockPlatformInterfaceMixin {
  MockFirebaseCore({
    required List<FirebaseAppPlatform> apps,
    required this.appByName,
    required this.initializeAppHandler,
  }) : _apps = apps;

  final List<FirebaseAppPlatform> _apps;
  final Map<String, FirebaseAppPlatform> appByName;
  final Future<FirebaseAppPlatform> Function({
    String? name,
    FirebaseOptions? options,
  }) initializeAppHandler;

  int appsCalled = 0;
  final List<String> appCalls = <String>[];
  final List<InitializeAppCall> initializeAppCalls = <InitializeAppCall>[];

  @override
  List<FirebaseAppPlatform> get apps {
    appsCalled += 1;
    return _apps;
  }

  @override
  FirebaseAppPlatform app([String name = defaultFirebaseAppName]) {
    appCalls.add(name);
    return appByName[name] ?? FakeFirebaseAppPlatform();
  }

  @override
  Future<FirebaseAppPlatform> initializeApp({
    String? name,
    FirebaseOptions? options,
  }) {
    initializeAppCalls.add(InitializeAppCall(name: name, options: options));
    return initializeAppHandler(name: name, options: options);
  }
}

class InitializeAppCall {
  const InitializeAppCall({
    required this.name,
    required this.options,
  });

  final String? name;
  final FirebaseOptions? options;

  @override
  bool operator ==(Object other) {
    return other is InitializeAppCall &&
        other.name == name &&
        other.options == options;
  }

  @override
  int get hashCode => Object.hash(name, options);
}

class FakeFirebaseAppPlatform extends FirebaseAppPlatform {
  FakeFirebaseAppPlatform()
      : super(
          defaultFirebaseAppName,
          const FirebaseOptions(
            apiKey: 'apiKey',
            appId: 'appId',
            messagingSenderId: 'messagingSenderId',
            projectId: 'projectId',
          ),
        );
}

class TestFirebaseAppPlatform extends FirebaseAppPlatform {
  TestFirebaseAppPlatform(
    super.name,
    super.options, {
    this.onDelete,
  });

  final Future<void> Function()? onDelete;

  @override
  Future<void> delete() async {
    await onDelete?.call();
  }
}

class TestService implements FirebaseService {}

class AnotherTestService implements FirebaseService {}
