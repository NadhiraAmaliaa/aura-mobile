import 'package:aura_mobile/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AuraApp builds the app shell', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: AuraApp()));
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Foundation ready'), findsOneWidget);
  });
}
