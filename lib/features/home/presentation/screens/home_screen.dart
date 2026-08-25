import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/layout/breakpoints.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../character/presentation/widgets/character_preview.dart';
import '../../../character/state/character_provider.dart';
import '../../../journal/presentation/widgets/memory_card.dart';
import '../../../journal/state/journal_provider.dart';
import '../../../stories/data/mock_stories.dart';
import '../../../stories/presentation/widgets/story_card.dart';

/// Home: the character, one invitation to write, and the memories that have
/// already become illustrated pages.
///
/// Phase 2 changes: recent memories now show their illustrations, and every
/// list is laid out from intrinsic heights instead of fixed pixel boxes, so
/// nothing overflows at tablet or narrow widths.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;

  void _onTapNav(int index) {
    if (index == 1) {
      Navigator.of(context).pushNamed(AppRoutes.stories);
      return;
    }
    if (index == 2) {
      Navigator.of(context).pushNamed(AppRoutes.characterStudio);
      return;
    }
    setState(() => _navIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final character = context.watch<CharacterProvider>();
    final journal = context.watch<JournalProvider>();
    final textTheme = Theme.of(context).textTheme;
    final wide = Breakpoints.isWide(context);
    final columns = Breakpoints.gridColumns(context, max: 3);
    final pages = journal.recentPages;

    final invitation = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Welcome back', style: textTheme.bodyMedium),
        const SizedBox(height: AppSpacing.xs),
        Text(
          pages.isEmpty
              ? 'Your story starts today'
              : 'Your story is ' +
                  pages.length.toString() +
                  (pages.length == 1 ? ' page long' : ' pages long'),
          style: textTheme.displayMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Write a few lines and turn this moment into a page in your story.',
          style: textTheme.bodyLarge,
        ),
        const SizedBox(height: AppSpacing.md),
        AppButton(
          label: 'What happened today?',
          icon: Icons.edit_outlined,
          expand: !wide,
          onPressed: () =>
              Navigator.of(context).pushNamed(AppRoutes.journalEntry),
        ),
      ],
    );

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth: Breakpoints.contentMaxWidth(context)),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                if (wide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(child: invitation),
                      const SizedBox(width: AppSpacing.xl),
                      CharacterPreview(config: character.config, size: 180),
                    ],
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text('Welcome back',
                                style: textTheme.bodyMedium),
                          ),
                          CharacterPreview(config: character.config, size: 72),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      invitation,
                    ],
                  ),
                const SizedBox(height: AppSpacing.xl),
                _SectionHeader(
                  title: 'Recent memories',
                  action: pages.isEmpty ? null : 'See all',
                  onAction: pages.isEmpty ? null : () {},
                ),
                const SizedBox(height: AppSpacing.md),
                if (pages.isEmpty)
                  const _RecentMemoriesEmptyState()
                else
                  GridView.builder(
                    shrinkWrap: true,
                    primary: false,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: pages.length > 6 ? 6 : pages.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      mainAxisSpacing: AppSpacing.md,
                      crossAxisSpacing: AppSpacing.md,
                      // A fixed main-axis extent (rather than an aspect
                      // ratio) is what keeps these cards overflow-proof.
                      mainAxisExtent: 246,
                    ),
                    itemBuilder: (context, i) => MemoryCard(page: pages[i]),
                  ),
                const SizedBox(height: AppSpacing.xl),
                _SectionHeader(
                  title: 'Stories',
                  action: 'See all',
                  onAction: () =>
                      Navigator.of(context).pushNamed(AppRoutes.stories),
                ),
                const SizedBox(height: AppSpacing.md),
                GridView.builder(
                  shrinkWrap: true,
                  primary: false,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: mockStories.length > columns
                      ? columns
                      : mockStories.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    mainAxisSpacing: AppSpacing.md,
                    crossAxisSpacing: AppSpacing.md,
                    mainAxisExtent: 220,
                  ),
                  itemBuilder: (context, i) =>
                      StoryCard(story: mockStories[i]),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navIndex,
        onTap: _onTapNav,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.auto_stories_outlined), label: 'Stories'),
          BottomNavigationBarItem(
              icon: Icon(Icons.face_outlined), label: 'Character'),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.action, this.onAction});

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: Text(title, style: textTheme.headlineSmall)),
        if (action != null)
          TextButton(onPressed: onAction, child: Text(action!)),
      ],
    );
  }
}

class _RecentMemoriesEmptyState extends StatelessWidget {
  const _RecentMemoriesEmptyState();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.ivoryDim,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome, color: AppColors.charcoalFaint),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Your first illustrated page will appear here once you write a memory.',
              style: textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
