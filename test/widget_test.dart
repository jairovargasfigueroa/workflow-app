import 'package:flutter_test/flutter_test.dart';
import 'package:tramites_app/app.dart';

void main() {
  testWidgets('App arranca sin errores', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    expect(find.byType(App), findsOneWidget);
  });
}
