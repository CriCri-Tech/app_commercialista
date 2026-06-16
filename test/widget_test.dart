import 'package:flutter_test/flutter_test.dart';


import 'package:nexa/main.dart';
import 'package:nexa/presentazione/schermate/welcome_page.dart';

void main() {
  testWidgets('Smoke test di avvio Nexa', (WidgetTester tester) async {
    
    await tester.pumpWidget(const MiaApp(schermataIniziale: WelcomePage()));

    
    await tester.pumpAndSettle();

   
    expect(find.byType(WelcomePage), findsOneWidget);

    
  });
}