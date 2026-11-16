import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:kover/generated/l10n/app_localizations.dart';
import 'package:kover/models/enums/library_type.dart';
import 'package:kover/riverpod/providers/router.dart';
import 'package:kover/riverpod/providers/settings/general_settings.dart';
import 'package:kover/utils/constants/kover_icons.dart';

extension NavbarDestinationsExtension on NavbarDestinations {
  IconData get icon {
    return switch (this) {
      .home => KoverIcons.home,
      .allSeries => KoverIcons.library,
      .wantToRead => KoverIcons.wantToRead,
      .wantToFind => KoverIcons.wantToFind,
      .collections => KoverIcons.collection,
      .readingLists => KoverIcons.readingList,
      .bookmarks => KoverIcons.bookmarkOn,
    };
  }

  String getLabel(AppLocalizations l) {
    return switch (this) {
      .home => l.home,
      .allSeries => l.library,
      .wantToRead => l.wantToRead,
      .wantToFind => l.wantToFind,
      .collections => l.collections,
      .readingLists => l.readingLists,
      .bookmarks => l.bookmarks,
    };
  }

  GoRouteData get route {
    return switch (this) {
      .home => const HomeRoute(),
      .allSeries => const AllSeriesRoute(),
      .wantToRead => const WantToReadRoute(),
      .wantToFind => const WantToFindRoute(),
      .collections => const CollectionsRoute(),
      .readingLists => const ReadingListsRoute(),
      .bookmarks => const BookmarksRoute(),
    };
  }
}

extension NavbarItemExtension on NavbarItem {
  IconData get icon => switch (this) {
    NavbarDestinationItem(:final destination) => destination.icon,
    NavbarLibraryItem(:final type) => type.icon,
  };

  String getLabel(AppLocalizations l) => switch (this) {
    NavbarDestinationItem(:final destination) => destination.getLabel(l),
    NavbarLibraryItem(:final name) => name,
  };

  int? get shellIndex => switch (this) {
    NavbarDestinationItem(:final destination) => destination.value,
    NavbarLibraryItem() => null,
  };

  int? get libraryId => switch (this) {
    NavbarDestinationItem() => null,
    NavbarLibraryItem(libraryId: final id) => id,
  };
}

extension LibraryTypeIcon on LibraryType {
  IconData get icon => switch (this) {
    .book || .lightNovel => KoverIcons.book,
    .manga || .comic || .comicLegacy => KoverIcons.comic,
    .image => KoverIcons.image,
    _ => KoverIcons.unknownFormat,
  };
}
