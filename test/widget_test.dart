import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_supabase/main.dart';

void main() {
  testWidgets('MyApp builds successfully', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Flutter Supabase'), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
