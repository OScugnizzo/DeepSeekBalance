import 'package:deepseekbalance/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders the balance home screen on launch', (tester) async {
    FlutterSecureStorage.setMockInitialValues({});

    await tester.pumpWidget(const DeepSeekBalanceApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));

    expect(find.text('DeepSeek Balance'), findsOneWidget);
    expect(find.text('TOTAL BALANCE'), findsOneWidget);
    expect(find.text('Topped-up'), findsOneWidget);
    expect(find.text('Granted / Bonus'), findsOneWidget);

    // Unmount to cancel the provider's traffic timer before the test ends.
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });
}
