import 'package:flutter_test/flutter_test.dart';
import 'package:illustrated_life_journal/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App boots and shows the Welcome screen for a first-time user',
      (tester) async {
    // No saved character in a fresh, mocked SharedPreferences store, so
    // the startup gate should route to Welcome.
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const IllustratedLifeJournalApp());
    await tester.pumpAndSettle();

    expect(find.text('Illustrated Life Journal'), findsOneWidget);
    expect(find.text('Get started'), findsOneWidget);
  });
}
