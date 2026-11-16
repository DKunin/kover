import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kover/api/openapi.swagger.dart';
import 'package:kover/generated/l10n/app_localizations.dart';
import 'package:kover/widgets/search/global_search_results.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('shows the global Kavita search result groups', (tester) async {
    final controller = SearchController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: GlobalSearchResults(
                controller: controller,
                query: 'Dune',
                volumes: const [],
                results: const SearchResultGroupDto(
                  libraries: [LibraryDto(id: 1, name: 'Books')],
                  persons: [PersonDto(id: 2, name: 'Frank Herbert')],
                  genres: [GenreTagDto(id: 3, title: 'Science Fiction')],
                  tags: [TagDto(id: 4, title: 'Classic')],
                  chapters: [ChapterDto(id: 5, title: 'Arrakis')],
                  files: [MangaFileDto(id: 6, filePath: '/books/dune.epub')],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Search for “Dune”'), findsOneWidget);
    expect(find.text('Books'), findsOneWidget);
    expect(find.text('Frank Herbert'), findsOneWidget);
    expect(find.text('Science Fiction'), findsOneWidget);
    expect(find.text('Classic'), findsOneWidget);
    expect(find.text('Arrakis'), findsOneWidget);
    expect(find.text('dune.epub'), findsOneWidget);
  });

  testWidgets('shows an empty state while keeping full catalog search', (
    tester,
  ) async {
    final controller = SearchController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: GlobalSearchResults(
              controller: controller,
              query: 'missing',
              volumes: const [],
              results: const SearchResultGroupDto(),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Search for “missing”'), findsOneWidget);
    expect(find.text('No results found'), findsOneWidget);
  });
}
