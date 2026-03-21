import 'package:flutter_test/flutter_test.dart';
import 'package:alertlens_ai/main.dart';

void main() {
  testWidgets('AlertLens AI app starts', (WidgetTester tester) async {
    await tester.pumpWidget(const AlertLensApp());
    expect(find.text('AlertLens'), findsOneWidget);
  });
}
