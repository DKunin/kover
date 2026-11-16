import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kover/generated/l10n/app_localizations.dart';
import 'package:kover/utils/constants/kover_icons.dart';
import 'package:kover/utils/layout_constants.dart';

class CoverCard extends ConsumerWidget {
  final String? title;
  final Icon? icon;
  final String? actionLabel;
  final Icon actionIcon;
  final Icon actionDisabledIcon;
  final bool actionDisabled;
  final double progress;
  final Widget coverImage;
  final Widget? downloadStatusIcon;
  final void Function()? onTap;
  final void Function()? onActionTap;

  const CoverCard({
    super.key,
    this.title,
    this.icon,
    this.actionLabel,
    this.actionIcon = const Icon(KoverIcons.read),
    this.actionDisabledIcon = const Icon(KoverIcons.noConnection),
    this.actionDisabled = true,
    required this.coverImage,
    this.downloadStatusIcon,
    this.onTap,
    this.onActionTap,
    double? progress,
  }) : progress = progress ?? 0.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final effectiveActionLabel =
        actionLabel ?? AppLocalizations.of(context).read;

    return Card.filled(
      clipBehavior: .antiAlias,
      child: Column(
        children: [
          Expanded(
            child: InkWell(
              onTap: onTap,
              child: Stack(
                children: [
                  Positioned.fill(child: coverImage),
                  if (downloadStatusIcon != null)
                    Positioned(
                      top: LayoutConstants.smallPadding,
                      left: LayoutConstants.smallPadding,
                      child: downloadStatusIcon!,
                    ),
                ],
              ),
            ),
          ),
          if (progress > 0)
            LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
            ),
          if (title != null || onActionTap != null)
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: onTap,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        LayoutConstants.smallPadding,
                        LayoutConstants.smallPadding,
                        LayoutConstants.smallerPadding,
                        LayoutConstants.smallPadding,
                      ),
                      child: Row(
                        children: [
                          if (icon != null) ...[
                            icon!,
                            const SizedBox(
                              width: LayoutConstants.smallPadding,
                            ),
                          ],
                          if (title != null)
                            Expanded(
                              child: Text(
                                title!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (onActionTap != null)
                  IconButton(
                    tooltip: effectiveActionLabel,
                    onPressed: actionDisabled ? null : onActionTap,
                    icon: actionDisabled ? actionDisabledIcon : actionIcon,
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
