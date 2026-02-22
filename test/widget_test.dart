import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/main.dart';

void main() {
  testWidgets('App launches and shows greeting', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ContextDictionaryApp());

    // Verify that the greeting part of the text is present.
    // Since the greeting is dynamic ("Good Morning", etc.), we might not know exactly which one.
    // But we know "What would you like to know?" is static.
    expect(find.text('What would you like to know?'), findsOneWidget);
  });
}
