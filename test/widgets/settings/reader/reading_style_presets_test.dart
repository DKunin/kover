import 'package:flutter_test/flutter_test.dart';
import 'package:kover/generated/l10n/app_localizations.dart';
import 'package:kover/models/reading_style_preset.dart';
import 'package:kover/utils/constants/kover_icons.dart';
import 'package:kover/widgets/settings/reader/reading_style_presets.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('shows both quick styles and reports selection', (tester) async {
    ReadingStylePreset? selected;
    ReadingStylePreset? saved;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SizedBox(
            width: 420,
            height: 220,
            child: ReadingStylePresets(
              selected: ReadingStylePreset.book,
              bookDescription: 'Sepia · comfortable',
              comicDescription: 'Vertical · full width',
              onSelected: (value) => selected = value,
              onSaved: (value) => saved = value,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Quick Style'), findsOneWidget);
    expect(find.text('Book'), findsOneWidget);
    expect(find.text('Comic'), findsOneWidget);
    expect(find.byIcon(KoverIcons.check), findsOneWidget);

    await tester.tap(find.text('Comic'));
    expect(selected, ReadingStylePreset.comic);

    await tester.longPress(find.text('Book'));
    await tester.pump();
    expect(saved, ReadingStylePreset.book);
    expect(find.text('Book style updated'), findsOneWidget);
  });
}
