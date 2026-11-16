import 'package:flutter_test/flutter_test.dart';
import 'package:kover/models/enums/library_type.dart';
import 'package:kover/riverpod/providers/settings/general_settings.dart';
import 'package:kover/widgets/util/navigator_container.dart';

void main() {
  const destinations = <NavbarItem>[
    NavbarItem.destination(destination: NavbarDestinations.home),
    NavbarItem.library(
      libraryId: 7,
      name: 'Books',
      type: LibraryType.book,
    ),
    NavbarItem.library(
      libraryId: 9,
      name: 'Comics',
      type: LibraryType.comic,
    ),
  ];

  test('selects a pinned library from the current URI', () {
    expect(
      mapNavigationSelectedIndex(
        shellIndex: NavbarDestinations.home.value,
        destinations: destinations,
        location: Uri.parse('/library/9'),
      ),
      2,
    );
  });

  test('selects More for a library that is not pinned', () {
    expect(
      mapNavigationSelectedIndex(
        shellIndex: NavbarDestinations.home.value,
        destinations: destinations,
        location: Uri.parse('/library/99'),
      ),
      destinations.length,
    );
  });

  test('uses the shell branch for built-in destinations', () {
    expect(
      mapNavigationSelectedIndex(
        shellIndex: NavbarDestinations.home.value,
        destinations: destinations,
        location: Uri.parse('/'),
      ),
      0,
    );
  });
}
