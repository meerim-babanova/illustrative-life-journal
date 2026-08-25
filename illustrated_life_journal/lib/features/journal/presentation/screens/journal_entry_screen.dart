import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../character/presentation/widgets/character_preview.dart';
import '../../../character/state/character_provider.dart';
import '../../state/journal_provider.dart';

/// The Write Memory experience.
///
/// Design intent: this should feel like opening a blank diary page, not
/// filling out a form. A minimal AppBar (back button only — no title
/// competing with the headline below), a large editorial headline, a
/// small glimpse of the user's own character to tie the moment to "their"
/// story, one open-ended writing area, and a single unmistakable action.
class JournalEntryScreen extends StatefulWidget {
  const JournalEntryScreen({super.key});

  @override
  State<JournalEntryScreen> createState() => _JournalEntryScreenState();
}

class _JournalEntryScreenState extends State<JournalEntryScreen> {
  static const _maxLength = 4000;
  static const _minLength = 3;

  final _titleController = TextEditingController();
  final _textController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  bool get _canSave => _textController.text.trim().length >= _minLength;

  Future<void> _save() async {
    if (!_canSave || _isSaving) return;
    setState(() => _isSaving = true);

    final journal = context.read<JournalProvider>();
    final entry = await journal.createEntry(
      text: _textController.text,
      title: _titleController.text,
    );

    if (!mounted) return;
    // Navigate to the generation screen for this specific entry. The
    // generation screen itself kicks off the request (in initState, not
    // here in a tap handler that could get skipped on hot restart) so the
    // flow is resumable if the user ever lands on that route directly.
    await Navigator.of(context).pushNamed(
      AppRoutes.generation,
      arguments: entry.id,
    );

    if (mounted) setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final character = context.watch<CharacterProvider>();
    final remaining = _maxLength - _textController.text.length;

    return Scaffold(
      // No title text here — the editorial headline in the body carries
      // that role instead, so the screen opens like a diary page rather
      // than a titled form.
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.of(context).maybePop()),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > AppBreakpoints.compact;
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: isWide ? AppSpacing.sm : 0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'What happened today?',
                                  style: textTheme.displayMedium,
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  'Write a few lines and turn this moment '
                                  'into a page in your story.',
                                  style: textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          // A small glimpse of the character, reinforcing
                          // that this memory will feature them — not a
                          // functional control, just a warm reminder.
                          CharacterPreview(config: character.config, size: 56),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      TextField(
                        controller: _titleController,
                        style: textTheme.titleMedium,
                        decoration: const InputDecoration(
                          hintText: 'Give it a title (optional)',
                        ),
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          maxLines: null,
                          expands: true,
                          maxLength: _maxLength,
                          textAlignVertical: TextAlignVertical.top,
                          textCapitalization: TextCapitalization.sentences,
                          style: textTheme.bodyLarge?.copyWith(color: AppColors.charcoal),
                          decoration: const InputDecoration(
                            hintText:
                                'Today I went to a small café after class. It was '
                                'raining, so I sat near the window and drank matcha '
                                'while watching people outside...',
                            counterText: '',
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '$remaining characters left',
                          style: textTheme.labelSmall,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppButton(
                        label: 'Turn into a page',
                        isLoading: _isSaving,
                        onPressed: _canSave ? _save : null,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
