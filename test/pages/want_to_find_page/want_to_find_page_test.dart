import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kover/generated/l10n/app_localizations.dart';
import 'package:kover/models/user_model.dart';
import 'package:kover/models/want_to_find_model.dart';
import 'package:kover/pages/want_to_find_page/want_to_find_page.dart';
import 'package:kover/riverpod/providers/auth.dart';
import 'package:kover/riverpod/providers/settings/credentials.dart';
import 'package:kover/riverpod/providers/want_to_find.dart';
import 'package:material_ui/material_ui.dart';

class _FakeCurrentUser extends CurrentUser {
  @override
  Future<UserModel> build() async {
    return const UserModel(id: 1, username: 'reader');
  }
}

class _FakeWantToFindList extends WantToFindList {
  @override
  Future<List<WantToFindModel>> build() async {
    return const [
      WantToFindModel(
        id: 1,
        title: 'The Left Hand of Darkness',
        authors: 'Ursula K. Le Guin',
      ),
    ];
  }
}

void main() {
  testWidgets('renders the metadata-only wanted-title grid', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          loginStatusProvider.overrideWith((ref) => .loggedIn),
          currentUserProvider.overrideWith(_FakeCurrentUser.new),
          wantToFindListProvider.overrideWith(_FakeWantToFindList.new),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: WantToFindPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Want To Find'), findsWidgets);
    expect(find.text('The Left Hand of Darkness'), findsOneWidget);
    expect(find.text('Ursula K. Le Guin'), findsOneWidget);
    expect(find.byTooltip('Add title'), findsOneWidget);
  });
}
