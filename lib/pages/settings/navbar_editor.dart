import 'package:material_ui/material_ui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kover/generated/l10n/app_localizations.dart';
import 'package:kover/models/library_model.dart';
import 'package:kover/riverpod/providers/library.dart';
import 'package:kover/riverpod/providers/settings/general_settings.dart';
import 'package:kover/utils/constants/kover_icons.dart';
import 'package:kover/utils/extensions/navbar_destination.dart';
import 'package:kover/utils/layout_constants.dart';
import 'package:kover/widgets/settings/bottom_sheet_option.dart';
import 'package:kover/widgets/util/async_value.dart';
import 'package:kover/widgets/util/sliver_bottom_padding.dart';

class NavbarEditor extends StatelessWidget {
  const NavbarEditor({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return BottomSheetOption(
      title: l.bottomBar,
      leadingIcon: KoverIcons.navbar,
      bottomSheetBuilder: (context) => const _NavbarEditorSheet(),
    );
  }
}

class _NavbarEditorSheet extends ConsumerWidget {
  const _NavbarEditorSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final navbar = ref.watch(
      generalSettingsProvider.select(
        (state) => state.whenData((state) => state.navbarDestinations),
      ),
    );
    final libraries =
        ref.watch(librariesProvider).value ?? const <LibraryModel>[];

    return Async(
      asyncValue: navbar,
      data: (destinations) {
        final hiddenEntries = <NavbarItem>[
          ...NavbarDestinations.values
              .where(
                (destination) => !destinations.any(
                  (item) =>
                      item is NavbarDestinationItem &&
                      item.destination == destination,
                ),
              )
              .map(
                (destination) => NavbarItem.destination(
                  destination: destination,
                ),
              ),
          ...libraries
              .where(
                (library) => !destinations.any(
                  (item) =>
                      item is NavbarLibraryItem && item.libraryId == library.id,
                ),
              )
              .map(
                (library) => NavbarItem.library(
                  libraryId: library.id,
                  name: library.name,
                  type: library.type,
                ),
              ),
        ];
        final canReorder = destinations.length > 1;
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: .start,
            spacing: LayoutConstants.mediumPadding,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: LayoutConstants.mediumPadding,
                ),
                child: Text(
                  l.bottomBar,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: LayoutConstants.mediumPadding,
                ),
                child: Text(l.bottomBarDescription),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: LayoutConstants.mediumPadding,
                ),
                child: Text(
                  l.shownDestinations,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Card.filled(
                margin: const EdgeInsets.symmetric(
                  horizontal: LayoutConstants.mediumPadding,
                ),
                child: ReorderableListView.builder(
                  shrinkWrap: true,
                  buildDefaultDragHandles: false,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: destinations.length,
                  itemBuilder: (context, index) {
                    final destination = destinations[index];

                    return ReorderableDragStartListener(
                      key: ValueKey(destination),
                      index: index,
                      child: _NavbarEntry(
                        destination: destination,
                        trailing: Row(
                          mainAxisSize: .min,
                          children: [
                            IconButton(
                              icon: Icon(
                                KoverIcons.minus,
                                color: canReorder
                                    ? Theme.of(context).colorScheme.error
                                    : null,
                              ),
                              onPressed: canReorder
                                  ? () async {
                                      final updatedList = List<NavbarItem>.from(
                                        destinations,
                                      );
                                      updatedList.removeAt(index);

                                      await ref
                                          .read(
                                            generalSettingsProvider.notifier,
                                          )
                                          .setNavbarDestinations(updatedList);
                                    }
                                  : null,
                            ),
                            const Icon(KoverIcons.dragHandle),
                          ],
                        ),
                      ),
                    );
                  },
                  onReorderItem: (oldIndex, newIndex) async {
                    final updatedList = List<NavbarItem>.from(
                      destinations,
                    );
                    final item = updatedList.removeAt(oldIndex);
                    updatedList.insert(newIndex, item);

                    await ref
                        .read(generalSettingsProvider.notifier)
                        .setNavbarDestinations(updatedList);
                  },
                ),
              ),
              if (hiddenEntries.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: LayoutConstants.mediumPadding,
                  ),
                  child: Text(
                    l.availableDestinations,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Card.filled(
                  margin: const EdgeInsets.symmetric(
                    horizontal: LayoutConstants.mediumPadding,
                  ),
                  child: Column(
                    mainAxisSize: .min,
                    children: hiddenEntries.map(
                      (destination) {
                        return _NavbarEntry(
                          destination: destination,
                          trailing: IconButton(
                            icon: const Icon(KoverIcons.add),
                            onPressed: () async {
                              final updatedShown = [
                                ...destinations,
                                destination,
                              ];

                              await ref
                                  .read(generalSettingsProvider.notifier)
                                  .setNavbarDestinations(updatedShown);
                            },
                          ),
                        );
                      },
                    ).toList(),
                  ),
                ),
              ],
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: LayoutConstants.mediumPadding,
                ),
                child: Row(
                  mainAxisAlignment: .end,
                  children: [
                    FilledButton.icon(
                      onPressed: () async {
                        await ref
                            .read(generalSettingsProvider.notifier)
                            .resetNavbarDestinations();
                      },
                      icon: const Icon(KoverIcons.reset),
                      label: Text(l.reset),
                    ),
                  ],
                ),
              ),
              const ListBottomPadding(),
            ],
          ),
        );
      },
    );
  }
}

class _NavbarEntry extends StatelessWidget {
  final NavbarItem destination;
  final Widget? trailing;

  const _NavbarEntry({
    required this.destination,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ListTile(
      title: Text(destination.getLabel(l)),
      leading: Icon(destination.icon),
      trailing: trailing,
    );
  }
}
