import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/main.dart';
void main() {
  testWidgets('compile check', (tester) async {
    await tester.pumpWidget(const ContextDictionaryApp());
  });
}
