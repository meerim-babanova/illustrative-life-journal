import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:illustrated_life_journal/core/routing/app_router.dart';
import 'package:illustrated_life_journal/core/theme/app_theme.dart';
import 'package:illustrated_life_journal/features/character/state/character_provider.dart';
import 'package:illustrated_life_journal/features/home/presentation/screens/home_screen.dart';
import 'package:illustrated_life_journal/features/journal/state/journal_provider.dart';
import 'package:provider/provider.dart';

import 'fakes/fake_character_repository.dart';
import 'fakes/fake_illustration_generation_service.dart';
import 'fakes/fake_journal_repository.dart';

Widget _wrapHome({
  required CharacterProvider character,
  required JournalProvider journal,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: character),
      ChangeNotifierProvider.value(value: journal),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      onGenerateRoute: AppRouter.onGenerateRoute,
      home: const HomeScreen(),
    ),
  );
}

void main() {
  testWidgets('Home shows the empty-state prompt when there are no memories yet',
      (tester) async {
    final character = CharacterProvider(repository: FakeCharacterRepository());
    final journal = JournalProvider(
      repository: FakeJournalRepository(),
      illustrationService: FakeIllustrationGenerationService(),
    );
    await character.load();
    await journal.load();

    await tester.pumpWidget(_wrapHome(character: character, journal: journal));
    await tester.pumpAndSettle();

    expect(
      find.text('Your first memory will show up here once you write one.'),
      findsOneWidget,
    );
  });

  testWidgets('Home shows the newest memory after one is saved, replacing '
      'the empty state', (tester) async {
    final character = CharacterProvider(repository: FakeCharacterRepository());
    final journal = JournalProvider(
      repository: FakeJournalRepository(),
      illustrationService: FakeIllustrationGenerationService(),
    );
    await character.load();
    await journal.load();

    await journal.createEntry(
      title: 'A walk in the rain',
      text: 'Today I went to a small café after class.',
    );

    await tester.pumpWidget(_wrapHome(character: character, journal: journal));
    await tester.pumpAndSettle();

    expect(
      find.text('Your first memory will show up here once you write one.'),
      findsNothing,
    );
    expect(find.text('A walk in the rain'), findsOneWidget);
  });

  testWidgets('the newest of several memories appears first', (tester) async {
    final character = CharacterProvider(repository: FakeCharacterRepository());
    final journal = JournalProvider(
      repository: FakeJournalRepository(),
      illustrationService: FakeIllustrationGenerationService(),
    );
    await character.load();
    await journal.load();

    await journal.createEntry(title: 'First one', text: 'text one');
    await Future.delayed(const Duration(milliseconds: 2));
    await journal.createEntry(title: 'Second one', text: 'text two');

    await tester.pumpWidget(_wrapHome(character: character, journal: journal));
    await tester.pumpAndSettle();

    expect(journal.entries.first.title, 'Second one');
    expect(find.text('Second one'), findsOneWidget);
  });
}
