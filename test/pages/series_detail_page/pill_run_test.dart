import 'package:flutter_test/flutter_test.dart';
import 'package:kover/generated/l10n/app_localizations.dart';
import 'package:kover/models/series_model.dart';
import 'package:kover/pages/series_detail_page/pill_run.dart';
import 'package:kover/widgets/list_page/series_filter_bar.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('people pill invokes its person callback', (tester) async {
    PersonModel? selected;
    const writer = PersonModel(id: 7, name: 'Octavia Butler');

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: PeopleRun(
            title: 'Writers',
            items: const [writer],
            onTap: (person) => selected = person,
          ),
        ),
      ),
    );

    await tester.tap(find.text(writer.name));

    expect(selected, writer);
  });

  testWidgets('writer filter picker selects an exact writer', (tester) async {
    List<PersonModel> selected = const [];
    const writer = PersonModel(id: 7, name: 'Octavia Butler');

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SeriesFilterBar(
            writerOptions: const [writer],
            genreOptions: const [],
            selectedWriters: const [],
            selectedGenres: const [],
            onWritersChanged: (value) => selected = value,
            onGenresChanged: (_) {},
          ),
        ),
      ),
    );

    await tester.tap(find.text('Writers'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(writer.name));

    expect(selected, const [writer]);
  });
}
