import 'package:flutter_test/flutter_test.dart';
import 'package:inovafin/main.dart';

void main() {
  testWidgets('INOVAFIN smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const InovafinApp());
    expect(find.text('INOVAFIN'), findsOneWidget);
  });
}
