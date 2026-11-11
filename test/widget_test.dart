import 'package:flutter_test/flutter_test.dart';
import 'package:open_wa/main.dart';

void main() {
  testWidgets('OpenWaApp renders home screen elements properly', (WidgetTester tester) async {
    await tester.pumpWidget(const OpenWaApp());

    expect(find.text('OpenWA 100% Secure Client SDK'), findsOneWidget);
    expect(find.text('Secure Server Connection'), findsOneWidget);
    expect(find.text('Connect Client'), findsOneWidget);
  });
}
