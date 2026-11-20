import 'package:flutter_test/flutter_test.dart';
import 'package:excelcraft/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ExcelCraftApp());
    expect(find.byType(ExcelCraftApp), findsOneWidget);
  });
}
