import 'package:flutter_test/flutter_test.dart';
import 'package:open_wa/main.dart';

void main() {
  testWidgets('OpenWaApp renders home screen elements properly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const OpenWaApp());

    expect(find.text('Connect to OpenWA'), findsOneWidget);
    expect(find.text('OpenWA server URL'), findsOneWidget);
    expect(find.text('API key'), findsOneWidget);
    expect(find.text('Connect API'), findsOneWidget);
  });
}
