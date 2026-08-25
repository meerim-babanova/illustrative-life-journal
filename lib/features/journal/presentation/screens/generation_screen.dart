import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/layout/breakpoints.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../character/presentation/widgets/character_preview.dart';
import '../../../character/state/character_provider.dart';
import '../../state/journal_provider.dart';
import '../widgets/drifting_line.dart';

/// The illustration-generation state, and the friendly failure state that
/// replaces it when a drawing doesn't come back.
///
/// No percentage is ever shown: progress is genuinely unknown, so the screen
/// says "working" with a calm drifting line and two lines of copy that fade
/// between each other.
class GenerationScreen extends StatefulWidget {
  const GenerationScreen({super.key});

  @override
  State<GenerationScreen> createState() => _GenerationScreenState();
}

class _GenerationScreenState extends State<GenerationScreen>
    with TickerProviderStateMixin {
  late final AnimationController _breath = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  )..repeat(reverse: true);

  late final AnimationController _copy = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 8),
  )..repeat();

  @override
  void dispose() {
    _breath.dispose();
    _copy.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final journal = context.watch<JournalProvider>();
    final textTheme = Theme.of(context).textTheme;

    if (!journal.isWorking && journal.currentPage != null && !journal.hasFailed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        Navigator.of(context).pushReplacementNamed(AppRoutes.journalPage);
      });
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth: Breakpoints.contentMaxWidth(context)),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: journal.hasFailed
                  ? _FailureState(textTheme: textTheme)
                  : _WorkingState(
                      breath: _breath,
                      copy: _copy,
                      draft: journal.draftText,
                      textTheme: textTheme,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WorkingState extends StatelessWidget {
  const _WorkingState({
    required this.breath,
    required this.copy,
    required this.draft,
    required this.textTheme,
  });

  final AnimationController breath;
  final AnimationController copy;
  final String draft;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final config = context.watch<CharacterProvider>().config;

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: breath,
            builder: (context, child) {
              final t = Curves.easeInOut.transform(breath.value);
              return Transform.translate(
                offset: Offset(0, -8 * t),
                child: child,
              );
            },
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.clay.withOpacity(0.16),
                    AppColors.ivory.withOpacity(0),
                  ],
                ),
              ),
              child: CharacterPreview(config: config, size: 150),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            height: 96,
            child: AnimatedBuilder(
              animation: copy,
              builder: (context, _) {
                final second = copy.value > 0.5;
                return _CopyCrossfade(
                  showSecond: second,
                  first: Text(
                    'Turning your memory into an illustration…',
                    textAlign: TextAlign.center,
                    style: textTheme.headlineSmall,
                  ),
                  second: Text(
                    'Finding the little details that make this moment yours.',
                    textAlign: TextAlign.center,
                    style: textTheme.headlineSmall,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const DriftingLine(),
          const SizedBox(height: AppSpacing.xl),
          Text('YOUR WORDS, ALREADY SAVED',
              style: textTheme.labelSmall?.copyWith(letterSpacing: 1.6)),
          const SizedBox(height: AppSpacing.sm),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Text(
              _excerpt(draft),
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge?.copyWith(
                color: AppColors.charcoalFaint,
                height: 1.7,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _excerpt(String text) {
    final t = text.trim();
    if (t.isEmpty) return '';
    if (t.length <= 120) return '"' + t + '"';
    return '"' + t.substring(0, 120).trim() + '…"';
  }
}

/// Crossfades two lines of copy without either one ever jumping the layout.
class _CopyCrossfade extends StatelessWidget {
  const _CopyCrossfade({
    super.key,
    required this.showSecond,
    required this.first,
    required this.second,
  });

  final bool showSecond;
  final Widget first;
  final Widget second;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        AnimatedOpacity(
          opacity: showSecond ? 0 : 1,
          duration: const Duration(milliseconds: 900),
          child: first,
        ),
        AnimatedOpacity(
          opacity: showSecond ? 1 : 0,
          duration: const Duration(milliseconds: 900),
          child: second,
        ),
      ],
    );
  }
}

class _FailureState extends StatelessWidget {
  const _FailureState({required this.textTheme});

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final journal = context.watch<JournalProvider>();
    final config = context.watch<CharacterProvider>().config;
    final wide = Breakpoints.isWide(context);

    final art = Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F0E3),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: const Color(0xFFDCCDB4),
          width: 1.5,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.rotate(
            angle: -0.1,
            child: CharacterPreview(config: config, size: 120),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('WANDERED OFF',
              style: textTheme.labelSmall?.copyWith(letterSpacing: 1.6)),
        ],
      ),
    );

    final words = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Your illustration got a little lost along the way.',
            style: textTheme.displayMedium),
        const SizedBox(height: AppSpacing.sm),
        Text(
          "Let's try again — your words are safe, exactly as you wrote them.",
          style: textTheme.bodyLarge,
        ),
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.sm,
          children: [
            AppButton(
              label: 'Try again',
              expand: false,
              onPressed: () => context.read<JournalProvider>().retry(),
            ),
            AppButton(
              label: 'Save the writing for now',
              variant: AppButtonVariant.secondary,
              expand: false,
              onPressed: () {
                context.read<JournalProvider>().keepWritingOnly();
                Navigator.of(context).popUntil(
                  (route) => route.settings.name == AppRoutes.home,
                );
              },
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.ivoryDim,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('DRAFT KEPT',
                  style: textTheme.labelSmall?.copyWith(letterSpacing: 1.6)),
              const SizedBox(height: AppSpacing.xs),
              Text(
                _draftLine(journal.draftText),
                style: textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );

    return SingleChildScrollView(
      child: wide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: art),
                const SizedBox(width: AppSpacing.xl),
                Expanded(child: words),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                art,
                const SizedBox(height: AppSpacing.lg),
                words,
              ],
            ),
    );
  }

  String _draftLine(String text) {
    final t = text.trim();
    if (t.isEmpty) return 'Saved to today.';
    final words = t.split(RegExp(r'\s+')).length;
    final head = t.length <= 70 ? t : t.substring(0, 70).trim() + '…';
    return '"' + head + '" — ' + words.toString() + ' words, saved to today.';
  }
}
