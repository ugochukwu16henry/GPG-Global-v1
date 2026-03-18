import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gpg_global/main.dart';

void main() {
  testWidgets('App boots to marketing landing screen',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 2200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const ProviderScope(
        child: GpgGlobalApp(),
      ),
    );
    await tester.pump();

    expect(find.text('Sign In User'), findsOneWidget);
  });
}
