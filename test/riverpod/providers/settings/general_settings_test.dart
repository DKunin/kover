import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kover/generated/l10n/app_localizations.dart';
import 'package:kover/models/enums/library_type.dart';
import 'package:kover/riverpod/providers/settings/general_settings.dart';
import 'package:kover/utils/constants/kover_icons.dart';
import 'package:kover/utils/extensions/navbar_destination.dart';

void main() {
  Locale? localeOrNull(String tag) =>
      GeneralSettingsState(localeString: tag).locale;

  Locale localeOf(String tag) => localeOrNull(tag)!;

  test('uses the reading-first navigation by default', () {
    expect(
      const GeneralSettingsState().navbarDestinations,
      const [
        NavbarItem.destination(destination: NavbarDestinations.home),
        NavbarItem.destination(destination: NavbarDestinations.allSeries),
        NavbarItem.destination(destination: NavbarDestinations.wantToRead),
      ],
    );
  });

  test('migrates legacy destination strings from persisted JSON', () {
    final state = GeneralSettingsState.fromJson({
      'navbarDestinations': ['home', 'wantToRead'],
    });

    expect(
      state.navbarDestinations,
      const [
        NavbarItem.destination(destination: NavbarDestinations.home),
        NavbarItem.destination(destination: NavbarDestinations.wantToRead),
      ],
    );
  });

  test('round trips a pinned library navigation item', () {
    const state = GeneralSettingsState(
      navbarDestinations: [
        NavbarItem.destination(destination: NavbarDestinations.home),
        NavbarItem.library(
          libraryId: 42,
          name: 'Comics',
          type: LibraryType.comic,
        ),
      ],
    );

    expect(GeneralSettingsState.fromJson(state.toJson()), state);
  });

  test('uses distinct semantic icons for Library and More', () {
    expect(NavbarDestinations.allSeries.icon, KoverIcons.library);
    expect(KoverIcons.more, isNot(KoverIcons.library));
  });

  group('GeneralSettingsState.locale', () {
    test('returns null when unset or unparseable', () {
      expect(const GeneralSettingsState().locale, isNull);
      expect(localeOrNull('not a locale'), isNull);
    });

    test('parses a language-only tag', () {
      expect(localeOf('it'), equals(const Locale('it')));
    });

    test('parses a country tag', () {
      expect(localeOf('pt_BR'), equals(const Locale('pt', 'BR')));
      expect(localeOf('pt-BR'), equals(const Locale('pt', 'BR')));
    });

    test('parses a script tag', () {
      expect(
        localeOf('zh_Hant_TW'),
        equals(
          const Locale.fromSubtags(
            languageCode: 'zh',
            scriptCode: 'Hant',
            countryCode: 'TW',
          ),
        ),
      );
    });

    test('falls back to the language for an unsupported region', () {
      expect(
        basicLocaleListResolution(
          <Locale>[localeOf('en_GB')],
          AppLocalizations.supportedLocales,
        ),
        equals(const Locale('en')),
      );
    });
  });
}
