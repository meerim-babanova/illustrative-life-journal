import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../state/journal_provider.dart';

/// Basic Journal Entry screen (Section 22 / Section 12).
///
/// Deliberately just one open text field — no required structured
/// metadata — per Section 12: "Do not require users to fill out structured
/// metadata. The AI will eventually infer it."
class JournalEntryScreen extends StatefulWidget {
  const JournalEntryScreen({super.key});

  @override
  State<JournalEntryScreen> createState() => _JournalEntryScreenState();
}

class _JournalEntryScreenState extends State<JournalEntryScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _canSubmit => _controller.text.trim().isNotEmpty;

  Future<void> _createPage() async {
    final journal = context.read<JournalProvider>();
    final text = _controller.text.trim();
    Navigator.of(context).pushNamed(AppRoutes.generation);
    await journal.generateFromText(text);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('What happened today?')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Write freely — no structure needed.',
                style: textTheme.bodyMedium
                    ?.copyWith(color: AppColors.charcoalFaint),
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: TextField(
                  controller: _controller,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  style: textTheme.bodyLarge?.copyWith(color: AppColors.charcoal),
                  decoration: const InputDecoration(
                    hintText:
                        'Today I went to a small café after class. It was '
                        'raining, so I sat near the window and drank matcha '
                        'while watching people outside...',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: 'Create my page',
                onPressed: _canSubmit ? _createPage : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
