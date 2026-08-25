import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../../data/customization_catalog.dart';
import '../../models/customization_asset.dart';
import '../../state/character_provider.dart';
import '../widgets/category_tab_bar.dart';
import '../widgets/character_preview.dart';
import '../widgets/option_grid.dart';

/// Figma "Screen 2": Character Studio.
///
/// For Phase 1 the category list is limited to Face, Hair, and Skin (per
/// Section 22's Phase 1 deliverable). Body, Clothes, and Accessories exist
/// in the data model/catalog already and can be added to [_phase1Categories]
/// with no other code changes once their screens are prioritized.
class CharacterStudioScreen extends StatefulWidget {
  const CharacterStudioScreen({super.key});

  @override
  State<CharacterStudioScreen> createState() => _CharacterStudioScreenState();
}

class _CharacterStudioScreenState extends State<CharacterStudioScreen> {
  static const _phase1Categories = [
    CustomizationCategory.face,
    CustomizationCategory.eyes,
    CustomizationCategory.hair,
    CustomizationCategory.skin,
  ];

  CustomizationCategory _selectedCategory = CustomizationCategory.face;

  String? _selectedIdFor(CustomizationCategory category, CharacterProvider provider) {
    final config = provider.config;
    switch (category) {
      case CustomizationCategory.face:
        return 'face_${config.headShape}';
      case CustomizationCategory.eyes:
        return null; // eyes combine shape+color; no single catalog id maps cleanly for MVP
      case CustomizationCategory.hair:
        return _hairIdFromStyle(config.hairStyle);
      case CustomizationCategory.skin:
        return _skinIdFromTone(config.skinTone);
      case CustomizationCategory.body:
        return 'body_${config.bodyType}';
      case CustomizationCategory.clothes:
        return null;
      case CustomizationCategory.accessories:
        return null;
    }
  }

  String? _hairIdFromStyle(String style) {
    final match = CustomizationCatalog.byCategory(CustomizationCategory.hair)
        .where((a) => a.renderingAsset == 'hair/$style');
    return match.isEmpty ? null : match.first.id;
  }

  String? _skinIdFromTone(String tone) {
    final match = CustomizationCatalog.byCategory(CustomizationCategory.skin)
        .where((a) => a.renderingAsset == 'skin/$tone');
    return match.isEmpty ? null : match.first.id;
  }

  void _handleSelection(CustomizationAsset asset, CharacterProvider provider) {
    switch (asset.category) {
      case CustomizationCategory.face:
        // renderingAsset looks like "face/round"
        provider.updateField(headShape: asset.renderingAsset.split('/').last);
        break;
      case CustomizationCategory.eyes:
        provider.updateField(
          eyeShape: asset.renderingAsset.split('/').last,
          eyeColor: asset.name.toLowerCase(),
        );
        break;
      case CustomizationCategory.hair:
        provider.updateField(hairStyle: asset.renderingAsset.split('/').last);
        break;
      case CustomizationCategory.skin:
        provider.updateField(skinTone: asset.renderingAsset.split('/').last);
        break;
      case CustomizationCategory.body:
        provider.updateField(bodyType: asset.renderingAsset.split('/').last);
        break;
      case CustomizationCategory.clothes:
        provider.updateField(outfitTop: asset.renderingAsset.split('/').last);
        break;
      case CustomizationCategory.accessories:
        final current = List<String>.from(provider.config.accessories);
        if (current.contains(asset.id)) {
          current.remove(asset.id);
        } else {
          current.add(asset.id);
        }
        provider.updateField(accessories: current);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CharacterProvider>();
    final textTheme = Theme.of(context).textTheme;
    final options = CustomizationCatalog.byCategory(_selectedCategory);

    return Scaffold(
      appBar: AppBar(title: const Text('Character Studio')),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: Text(
                'This little version of you will appear in your stories.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium,
              ),
            ),
            Center(
              child: CharacterPreview(config: provider.config, size: 190),
            ),
            const SizedBox(height: AppSpacing.lg),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: CategoryTabBar(
                categories: _phase1Categories,
                selected: _selectedCategory,
                onSelected: (category) =>
                    setState(() => _selectedCategory = category),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                child: OptionGrid(
                  options: options,
                  selectedId: _selectedIdFor(_selectedCategory, provider),
                  onSelected: (asset) => _handleSelection(asset, provider),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: AppButton(
                label: 'Continue →',
                onPressed: () async {
                  await provider.completeSetup();
                  if (!context.mounted) return;
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
                },
              ),
            ),
          ],
        ),
      ),
      backgroundColor: AppColors.ivory,
    );
  }
}
