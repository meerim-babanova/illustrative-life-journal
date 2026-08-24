import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../state/journal_provider.dart';

/// The Write Memory experience.
///
/// One open-ended text field (Section 12: no required structured
/// metadata), plus an optional short title, a character counter, and
/// simple validation — a polished journal-entry screen rather than a
/// generic form (Section 7 of the Phase 2 spec).
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
    final remaining = _maxLength - _textController.text.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Write about your day'),
        leading: BackButton(
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 640;
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isWide ? 640 : double.infinity),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'What happened?',
                        style: textTheme.headlineSmall,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        "Write a few lines about a moment you'd like to remember.",
                        style: textTheme.bodyMedium,
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
                        label: 'Save & continue',
                        isLoading: _isSaving,
                        onPressed: _canSave ? _save : null,
                      ),
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
