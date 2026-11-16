import 'package:kover/api/openapi.swagger.dart';
import 'package:kover/riverpod/repository/search_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search.g.dart';

@riverpod
Future<SearchResultGroupDto> globalSearch(
  Ref ref,
  String query, {
  bool includeChapterAndFiles = true,
}) {
  return ref
      .watch(searchRepositoryProvider)
      .search(
        query,
        includeChapterAndFiles: includeChapterAndFiles,
      );
}

@riverpod
Future<SeriesDto> searchSeriesForChapter(Ref ref, int chapterId) {
  return ref.watch(searchRepositoryProvider).seriesForChapter(chapterId);
}

@riverpod
Future<SeriesDto> searchSeriesForFile(Ref ref, int fileId) {
  return ref.watch(searchRepositoryProvider).seriesForFile(fileId);
}
