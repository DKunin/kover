import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kover/generated/l10n/app_localizations.dart';
import 'package:kover/widgets/cards/cover_card.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('keeps the cover clear and exposes a compact read action', (
    tester,
  ) async {
    var actionInvoked = false;

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SizedBox(
              width: 180,
              height: 280,
              child: CoverCard(
                title: 'A Book',
                coverImage: const ColoredBox(color: Colors.blue),
                actionDisabled: false,
                onActionTap: () => actionInvoked = true,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(FilledButton), findsNothing);
    expect(find.byType(IconButton), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNothing);

    await tester.tap(find.byType(IconButton));
    expect(actionInvoked, isTrue);
  });
}
