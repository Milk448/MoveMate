import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movemate/main.dart';

void main() {
  testWidgets('MoveMate app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MoveMateApp());

    expect(find.text('Welcome to MoveMate!'), findsOneWidget);
  });
}
