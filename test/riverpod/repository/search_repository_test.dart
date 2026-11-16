import 'package:chopper/chopper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:kover/api/openapi.swagger.dart';
import 'package:kover/riverpod/repository/search_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([MockSpec<Openapi>()])
import 'search_repository_test.mocks.dart';

void main() {
  late MockOpenapi client;
  late SearchRepository repository;

  setUpAll(() {
    provideDummy<Response<SearchResultGroupDto>>(
      Response(http.Response('', 200), const SearchResultGroupDto()),
    );
    provideDummy<Response<SeriesDto>>(
      Response(http.Response('', 200), const SeriesDto()),
    );
  });

  setUp(() {
    client = MockOpenapi();
    repository = SearchRepository(client: client);
  });

  test('trims the query and requests chapter and file results', () async {
    const expected = SearchResultGroupDto(
      libraries: [LibraryDto(id: 1, name: 'Books')],
    );
    when(
      client.apiSearchSearchGet(
        queryString: 'Dune',
        includeChapterAndFiles: true,
      ),
    ).thenAnswer((_) async => Response(http.Response('', 200), expected));

    final result = await repository.search('  Dune  ');

    expect(result, expected);
    verify(
      client.apiSearchSearchGet(
        queryString: 'Dune',
        includeChapterAndFiles: true,
      ),
    ).called(1);
  });

  test('does not call the server for an empty query', () async {
    final result = await repository.search('   ');

    expect(result, const SearchResultGroupDto());
    verifyNever(
      client.apiSearchSearchGet(
        queryString: anyNamed('queryString'),
        includeChapterAndFiles: anyNamed('includeChapterAndFiles'),
      ),
    );
  });

  test('throws when the server search fails', () async {
    when(
      client.apiSearchSearchGet(
        queryString: 'Dune',
        includeChapterAndFiles: true,
      ),
    ).thenAnswer(
      (_) async => Response(http.Response('', 500), null),
    );

    await expectLater(repository.search('Dune'), throwsException);
  });

  test('resolves series for chapter and file results', () async {
    const expected = SeriesDto(id: 42);
    when(client.apiSearchSeriesForChapterGet(chapterId: 7)).thenAnswer(
      (_) async => Response(http.Response('', 200), expected),
    );
    when(client.apiSearchSeriesForMangafileGet(mangaFileId: 9)).thenAnswer(
      (_) async => Response(http.Response('', 200), expected),
    );

    expect(await repository.seriesForChapter(7), expected);
    expect(await repository.seriesForFile(9), expected);
  });
}
