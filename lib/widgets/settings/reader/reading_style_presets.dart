import 'dart:async';

import 'package:kover/generated/l10n/app_localizations.dart';
import 'package:kover/models/reading_style_preset.dart';
import 'package:kover/utils/constants/kover_icons.dart';
import 'package:kover/utils/layout_constants.dart';
import 'package:kover/widgets/settings/option_container.dart';
import 'package:material_ui/material_ui.dart';

class ReadingStylePresets extends StatelessWidget {
  const ReadingStylePresets({
    super.key,
    required this.selected,
    required this.bookDescription,
    required this.comicDescription,
    required this.onSelected,
    required this.onSaved,
  });

  final ReadingStylePreset? selected;
  final String bookDescription;
  final String comicDescription;
  final ValueChanged<ReadingStylePreset> onSelected;
  final FutureOr<void> Function(ReadingStylePreset) onSaved;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return OptionContainer(
      title: l.quickStyle,
      child: Column(
        crossAxisAlignment: .start,
        spacing: LayoutConstants.smallerPadding,
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: .stretch,
              spacing: LayoutConstants.smallPadding,
              children: [
                Expanded(
                  child: _PresetCard(
                    icon: KoverIcons.book,
                    title: l.bookStyle,
                    description: bookDescription,
                    selected: selected == .book,
                    onTap: () => onSelected(.book),
                    onLongPress: () => _save(context, .book, l.bookStyle),
                  ),
                ),
                Expanded(
                  child: _PresetCard(
                    icon: KoverIcons.comic,
                    title: l.comicStyle,
                    description: comicDescription,
                    selected: selected == .comic,
                    onTap: () => onSelected(.comic),
                    onLongPress: () => _save(context, .comic, l.comicStyle),
                  ),
                ),
              ],
            ),
          ),
          Text(
            l.quickStyleSaveHint,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save(
    BuildContext context,
    ReadingStylePreset preset,
    String styleName,
  ) async {
    await onSaved(preset);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).quickStyleSaved(styleName),
          ),
        ),
      );
  }
}

class _PresetCard extends StatelessWidget {
  const _PresetCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.selected,
    required this.onTap,
    required this.onLongPress,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final borderColor = selected
        ? colorScheme.primary
        : colorScheme.outlineVariant;

    return Semantics(
      button: true,
      selected: selected,
      onLongPressHint: AppLocalizations.of(context).quickStyleSaveHint,
      child: Material(
        color: selected
            ? colorScheme.primaryContainer.withValues(alpha: 0.35)
            : colorScheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            LayoutConstants.smallBorderRadius,
          ),
          side: BorderSide(color: borderColor, width: selected ? 2 : 1),
        ),
        clipBehavior: .antiAlias,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: LayoutConstants.mediumEdgeInsets,
            child: Column(
              crossAxisAlignment: .start,
              mainAxisSize: .min,
              spacing: LayoutConstants.smallerPadding,
              children: [
                Row(
                  children: [
                    Icon(icon),
                    const Spacer(),
                    if (selected)
                      Icon(KoverIcons.check, color: colorScheme.primary),
                  ],
                ),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
