// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:growwise/main.dart';
import 'package:growwise/providers/app_state.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState(),
        child: const GrowWiseApp(),
      ),
    );

    // Verify splash screen loads with GrowWise branding
    expect(find.text('GrowWise'), findsOneWidget);

    // Advance past the splash screen timer
    await tester.pumpAndSettle(const Duration(seconds: 4));
  });
}
