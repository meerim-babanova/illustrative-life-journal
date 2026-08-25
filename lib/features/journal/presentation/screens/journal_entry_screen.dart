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

/// Write Memory.
///
/// One large, comfortable writing surface on paper-coloured ground, the
/// character present in a quiet rail so the user can see who will appear in
/// the illustration, and exactly one primary action.
class JournalEntryScreen extends StatefulWidget {
  const JournalEntryScreen({super.key});

  @override
  State<JournalEntryScreen> createState() => _JournalEntryScreenState();
}

class _JournalEntryScreenState extends State<JournalEntryScreen> {
  final _controller = TextEditingController();
  static const _prompts = [
    'Who was there?',
    'Where were you?',
    'How did it feel?',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _canSubmit => _controller.text.trim().isNotEmpty;

  int get _wordCount {
    final t = _controller.text.trim();
    if (t.isEmpty) return 0;
    return t.split(RegExp(r'\s+')).length;
  }

  Future<void> _createPage() async {
    final journal = context.read<JournalProvider>();
    final text = _controller.text.trim();
    Navigator.of(context).pushNamed(AppRoutes.generation);
    await journal.generateFromText(text);
  }

  /// Drops the prompt into the page as a gentle line the user writes under,
  /// rather than a form field.
  void _appendPrompt(String prompt) {
    final existing = _controller.text;
    final prefix = existing.trim().isEmpty ? '' : existing.trimRight() + '\n\n';
    _controller.text = prefix + prompt + ' ';
    _controller.selection =
        TextSelection.collapsed(offset: _controller.text.length);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final wide = Breakpoints.isWide(context);

    final writing = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(_formattedDate().toUpperCase(),
            style: textTheme.labelSmall?.copyWith(letterSpacing: 1.6)),
        const SizedBox(height: AppSpacing.md),
        Text('What happened today?', style: textTheme.displayMedium),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Write a few lines and turn this moment into a page in your story.',
          style: textTheme.bodyLarge,
        ),
        const SizedBox(height: AppSpacing.lg),
        Expanded(
          child: Container(
            constraints: const BoxConstraints(minHeight: 180),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.divider),
            ),
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: TextField(
              controller: _controller,
              maxLines: null,
              expands: true,
              autofocus: wide,
              textAlignVertical: TextAlignVertical.top,
              cursorColor: AppColors.coral,
              style: textTheme.headlineSmall?.copyWith(
                fontSize: 19,
                height: 1.75,
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                isCollapsed: true,
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText:
                    'We took the long way home because the light was doing '
                    'that late-summer thing…',
                hintStyle: textTheme.headlineSmall?.copyWith(
                  fontSize: 19,
                  height: 1.75,
                  fontWeight: FontWeight.w400,
                  color: AppColors.charcoalFaint,
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.sm,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(_wordCount.toString() + (_wordCount == 1 ? ' word' : ' words'),
                style: textTheme.labelSmall),
            const _StoryChip(),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        AppButton(
          label: 'Turn into an illustration',
          icon: Icons.auto_awesome_outlined,
          onPressed: _canSubmit ? _createPage : null,
        ),
      ],
    );

    final rail = _CharacterRail(prompts: _prompts, onPrompt: _appendPrompt);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Today'),
        leading: const BackButton(),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints:
                BoxConstraints(maxWidth: Breakpoints.contentMaxWidth(context)),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: wide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(flex: 5, child: writing),
                        const SizedBox(width: AppSpacing.xl),
                        SizedBox(
                          width: 264,
                          child: SingleChildScrollView(child: rail),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _CharacterStrip(prompts: _prompts, onPrompt: _appendPrompt),
                        const SizedBox(height: AppSpacing.lg),
                        Expanded(child: writing),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  String _formattedDate() {
    final now = DateTime.now();
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June', 'July',
      'August', 'September', 'October', 'November', 'December',
    ];
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday',
      'Sunday',
    ];
    return days[now.weekday - 1] +
        ' · ' +
        now.day.toString() +
        ' ' +
        months[now.month - 1] +
        ' ' +
        now.year.toString();
  }
}

class _StoryChip extends StatelessWidget {
  const _StoryChip();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.ivoryDim,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text('+ Add to a story',
          style: textTheme.labelSmall?.copyWith(color: AppColors.charcoalSoft)),
    );
  }
}

class _CharacterRail extends StatelessWidget {
  const _CharacterRail({required this.prompts, required this.onPrompt});

  final List<String> prompts;
  final ValueChanged<String> onPrompt;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final config = context.watch<CharacterProvider>().config;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.ivoryDim,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Column(
            children: [
              CharacterPreview(config: config, size: 148),
              const SizedBox(height: AppSpacing.md),
              Text('Ready when you are',
                  textAlign: TextAlign.center, style: textTheme.titleMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Your character appears in today\'s illustration, just as you made them.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("IF YOU'RE STUCK",
                  style: textTheme.labelSmall?.copyWith(letterSpacing: 1.6)),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final p in prompts)
                    _PromptChip(label: p, onTap: () => onPrompt(p)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CharacterStrip extends StatelessWidget {
  const _CharacterStrip({required this.prompts, required this.onPrompt});

  final List<String> prompts;
  final ValueChanged<String> onPrompt;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final config = context.watch<CharacterProvider>().config;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.ivoryDim,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          CharacterPreview(config: config, size: 64),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Ready when you are', style: textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(
                  'Your character will appear in this illustration.',
                  style: textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PromptChip extends StatelessWidget {
  const _PromptChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.ivory,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: AppColors.divider),
        ),
        child: Text(label, style: textTheme.bodyMedium),
      ),
    );
  }
}
