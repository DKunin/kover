import 'package:kover/api/openapi.swagger.dart';
import 'package:kover/riverpod/providers/client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search_repository.g.dart';

@Riverpod(keepAlive: true)
SearchRepository searchRepository(Ref ref) {
  return SearchRepository(client: ref.watch(restClientProvider));
}

class SearchRepository {
  const SearchRepository({required this.client});

  final Openapi client;

  Future<SearchResultGroupDto> search(
    String query, {
    bool includeChapterAndFiles = true,
  }) async {
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty) return const SearchResultGroupDto();

    final response = await client.apiSearchSearchGet(
      queryString: normalizedQuery,
      includeChapterAndFiles: includeChapterAndFiles,
    );

    if (!response.isSuccessful || response.body == null) {
      throw Exception('Failed to search Kavita: ${response.error}');
    }

    return response.body!;
  }

  Future<SeriesDto> seriesForChapter(int chapterId) async {
    final response = await client.apiSearchSeriesForChapterGet(
      chapterId: chapterId,
    );

    if (!response.isSuccessful || response.body == null) {
      throw Exception(
        'Failed to resolve series for chapter $chapterId: ${response.error}',
      );
    }

    return response.body!;
  }

  Future<SeriesDto> seriesForFile(int fileId) async {
    final response = await client.apiSearchSeriesForMangafileGet(
      mangaFileId: fileId,
    );

    if (!response.isSuccessful || response.body == null) {
      throw Exception(
        'Failed to resolve series for file $fileId: ${response.error}',
      );
    }

    return response.body!;
  }
}
