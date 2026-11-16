import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:kover/utils/constants/kover_icons.dart';
import 'package:kover/widgets/util/breakpoint_builder.dart';
import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kover/generated/l10n/app_localizations.dart';
import 'package:kover/riverpod/providers/settings/general_settings.dart';
import 'package:kover/riverpod/providers/settings/oneoffs.dart';
import 'package:kover/riverpod/providers/theme.dart' hide Theme;
import 'package:kover/utils/extensions/navbar_destination.dart';
import 'package:kover/utils/layout_constants.dart';
import 'package:kover/widgets/util/async_value.dart';
import 'package:kover/widgets/util/monitoring_opt_out_popup.dart';

class NavigatorContainer extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;
  final Uri location;

  const NavigatorContainer({
    super.key,
    required this.navigationShell,
    required this.location,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final oneOffs = ref.watch(oneOffsProvider);
    final destinations = ref.watch(
      generalSettingsProvider.select(
        (value) => value.whenData(
          (value) => value.navbarDestinations,
        ),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      oneOffs.whenData((oneOffs) async {
        if (!oneOffs.monitoringOptOutPopupShown) {
          await showDialog(
            context: context,
            builder: (context) => const MonitoringOptOutPopup(),
          );
          await ref
              .read(oneOffsProvider.notifier)
              .setMonitoringOptOutPopupShown();
        }
      });
    });

    return Async(
      asyncValue: destinations,
      data: (destinations) {
        final selectedIndex = mapNavigationSelectedIndex(
          shellIndex: navigationShell.currentIndex,
          destinations: destinations,
          location: location,
        );
        void onDestinationSelected(int index) {
          if (index >= destinations.length) {
            navigationShell.goBranch(
              navigationShell.route.branches.length - 1,
              initialLocation: true,
            );
            return;
          }

          switch (destinations[index]) {
            case NavbarDestinationItem(:final destination):
              navigationShell.goBranch(
                destination.value,
                initialLocation: true,
              );
            case NavbarLibraryItem(:final libraryId):
              context.go('/library/$libraryId');
          }
        }

        return BreakpointBuilder(
          compactBuilder: (context) {
            return _CompactNavigationShell(
              navigationShell: navigationShell,
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
              destinations: destinations,
            );
          },
          expandedBuilder: (context) {
            return _ExpandedNavigationLayout(
              key: const ValueKey('expanded_navigation_layout'),
              navigationShell: navigationShell,
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
              destinations: destinations,
            );
          },
          largestBuilder: (context) {
            return _ExpandedNavigationLayout(
              key: const ValueKey('largest_navigation_layout'),
              navigationShell: navigationShell,
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
              destinations: destinations,
              startExtended: true,
            );
          },
        );
      },
    );
  }
}

@visibleForTesting
int mapNavigationSelectedIndex({
  required int shellIndex,
  required List<NavbarItem> destinations,
  required Uri location,
}) {
  if (location.pathSegments case ['library', final id]) {
    final libraryId = int.tryParse(id);
    final libraryIndex = destinations.indexWhere(
      (destination) => destination.libraryId == libraryId,
    );
    return libraryIndex < 0 ? destinations.length : libraryIndex;
  }

  final index = destinations.indexWhere(
    (destination) => destination.shellIndex == shellIndex,
  );
  return index < 0 ? destinations.length : index;
}

class _CompactNavigationShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;
  final int selectedIndex;
  final void Function(int) onDestinationSelected;
  final List<NavbarItem> destinations;

  const new({
    required this.navigationShell,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = ref.watch(themeProvider);

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Async(
        asyncValue: theme,
        data: (theme) {
          final colorScheme = Theme.of(context).colorScheme;
          return DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              border: theme.outlined
                  ? Border(top: BorderSide(color: colorScheme.outline))
                  : null,
            ),
            child: SafeArea(
              top: false,
              child: NavigationBar(
                backgroundColor: Colors.transparent,
                selectedIndex: selectedIndex,
                onDestinationSelected: onDestinationSelected,
                destinations: [
                  ...destinations.map((destination) {
                    return NavigationDestination(
                      icon: Icon(destination.icon),
                      label: destination.getLabel(l),
                    );
                  }),
                  NavigationDestination(
                    icon: const Icon(KoverIcons.more),
                    label: l.more,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ExpandedNavigationLayout extends HookWidget {
  final StatefulNavigationShell navigationShell;
  final int selectedIndex;
  final void Function(int) onDestinationSelected;
  final List<NavbarItem> destinations;
  final bool startExtended;

  const new({
    super.key,
    required this.navigationShell,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    this.startExtended = false,
  });

  @override
  Widget build(BuildContext context) {
    final extended = useState(startExtended);

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            extended: extended.value,
            scrollable: true,
            trailingAtBottom: true,
            trailing: Padding(
              padding: LayoutConstants.smallestEdgeInsets,
              child: IconButton(
                icon: Icon(
                  extended.value
                      ? KoverIcons.collapsePanel
                      : KoverIcons.expandPanel,
                ),
                onPressed: () {
                  extended.value = !extended.value;
                },
              ),
            ),
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
            destinations: [
              ...destinations.map((destination) {
                return NavigationRailDestination(
                  icon: Icon(destination.icon),
                  label: Text(
                    destination.getLabel(AppLocalizations.of(context)),
                  ),
                );
              }),
              NavigationRailDestination(
                icon: const Icon(KoverIcons.more),
                label: Text(AppLocalizations.of(context).menu),
              ),
            ],
          ),
          const VerticalDivider(width: 1.0, thickness: 1.0),
          Expanded(child: navigationShell),
        ],
      ),
    );
  }
}
