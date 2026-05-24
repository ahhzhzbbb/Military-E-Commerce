import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:military_e_commerce/main.dart';

void main() {
  testWidgets('Military e-commerce app shows splash screen', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MyApp());

    expect(find.text('Sàn TMĐT Quân Đội'), findsOneWidget);
    expect(find.byIcon(Icons.shield), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('Đăng nhập để tiếp tục'), findsOneWidget);
  });
}
