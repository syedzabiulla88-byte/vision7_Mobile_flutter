import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vision7/app/app.dart';

void main() {
  testWidgets('App boots without error', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: Vision7App(),
      ),
    );
    await tester.pumpAndSettle();

    // Vision7App uses MaterialApp.router (GoRouter)
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
