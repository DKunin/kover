import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kover/api/openapi.swagger.dart';
import 'package:kover/generated/l10n/app_localizations.dart';
import 'package:kover/models/volume_model.dart';
import 'package:kover/riverpod/providers/router.dart';
import 'package:kover/riverpod/providers/search.dart';
import 'package:kover/riverpod/providers/series.dart';
import 'package:kover/utils/constants/kover_icons.dart';
import 'package:kover/utils/layout_constants.dart';
import 'package:kover/widgets/cards/cover_image.dart';
import 'package:material_ui/material_ui.dart';

class GlobalSearchResults extends ConsumerWidget {
  const GlobalSearchResults({
    super.key,
    required this.results,
    required this.volumes,
    required this.query,
    required this.controller,
  });

  final SearchResultGroupDto results;
  final List<VolumeModel> volumes;
  final String query;
  final SearchController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final sections = <Widget>[
      _SearchResultTile(
        icon: KoverIcons.search,
        title: l.searchFor(query),
        onTap: () {
          controller.closeView(null);
          AllSeriesRoute(query: query).go(context);
        },
      ),
      _SearchSection(
        title: l.series,
        children: [
          for (final item in results.series ?? const <SearchResultDto>[])
            _SearchResultTile(
              cover: item.seriesId == null
                  ? null
                  : SeriesCoverImage(seriesId: item.seriesId!),
              icon: KoverIcons.series,
              title: _seriesTitle(item, query),
              subtitle: item.libraryName,
              onTap: item.seriesId == null
                  ? null
                  : () {
                      controller.closeView(null);
                      SeriesDetailRoute(seriesId: item.seriesId!).go(context);
                    },
            ),
        ],
      ),
      _SearchSection(
        title: l.volumes,
        children: [
          for (final volume in volumes)
            _VolumeSearchResult(
              volume: volume,
              controller: controller,
            ),
        ],
      ),
      _SearchSection(
        title: l.collections,
        children: [
          for (final item
              in results.collections ?? const <AppUserCollectionDto>[])
            _SearchResultTile(
              cover: item.id == null
                  ? null
                  : CollectionCoverImage(collectionId: item.id!),
              icon: KoverIcons.collection,
              title: item.title ?? l.collections,
              subtitle: item.owner,
              onTap: item.id == null
                  ? null
                  : () {
                      controller.closeView(null);
                      CollectionSeriesRoute(
                        collectionId: item.id!,
                      ).go(context);
                    },
            ),
        ],
      ),
      _SearchSection(
        title: l.readingLists,
        children: [
          for (final item in results.readingLists ?? const <ReadingListDto>[])
            _SearchResultTile(
              cover: item.id == null
                  ? null
                  : ReadingListCoverImage(readingListId: item.id!),
              icon: KoverIcons.readingList,
              title: item.title ?? l.readingLists,
              onTap: item.id == null
                  ? null
                  : () {
                      controller.closeView(null);
                      ReadingListDetailsRoute(
                        readingListId: item.id!,
                      ).go(context);
                    },
            ),
        ],
      ),
      _SearchSection(
        title: l.bookmarks,
        children: [
          for (final item
              in results.bookmarks ?? const <BookmarkSearchResultDto>[])
            _SearchResultTile(
              cover: item.seriesId == null
                  ? null
                  : SeriesCoverImage(seriesId: item.seriesId!),
              icon: KoverIcons.bookmarkOn,
              title: item.seriesName ?? item.localizedSeriesName ?? l.bookmarks,
              onTap: item.seriesId == null || item.chapterId == null
                  ? null
                  : () {
                      controller.closeView(null);
                      ChapterDetailRoute(
                        seriesId: item.seriesId!,
                        chapterId: item.chapterId!,
                      ).go(context);
                    },
            ),
        ],
      ),
      _SearchSection(
        title: l.libraries,
        children: [
          for (final item in results.libraries ?? const <LibraryDto>[])
            _SearchResultTile(
              icon: KoverIcons.library,
              title: item.name ?? l.library,
              onTap: item.id == null
                  ? null
                  : () {
                      controller.closeView(null);
                      SeriesRoute(libraryId: item.id!).go(context);
                    },
            ),
        ],
      ),
      _SearchSection(
        title: l.genres,
        children: [
          for (final item in results.genres ?? const <GenreTagDto>[])
            _SearchResultTile(
              icon: KoverIcons.tag,
              title: item.title ?? l.genres,
              onTap: item.id == null || item.title == null
                  ? null
                  : () {
                      controller.closeView(null);
                      AllSeriesRoute(
                        genreId: item.id,
                        genreName: item.title,
                      ).go(context);
                    },
            ),
        ],
      ),
      _SearchSection(
        title: l.tags,
        children: [
          for (final item in results.tags ?? const <TagDto>[])
            _SearchResultTile(
              icon: KoverIcons.tag,
              title: item.title ?? l.tags,
              onTap: item.title == null
                  ? null
                  : () {
                      controller.closeView(null);
                      AllSeriesRoute(query: item.title).go(context);
                    },
            ),
        ],
      ),
      _SearchSection(
        title: l.people,
        children: [
          for (final item in results.persons ?? const <PersonDto>[])
            _SearchResultTile(
              icon: KoverIcons.person,
              title: item.name ?? l.people,
              subtitle: switch (item.aliases) {
                final aliases? when aliases.isNotEmpty => aliases.join(', '),
                _ => null,
              },
              onTap: item.name == null
                  ? null
                  : () {
                      controller.closeView(null);
                      AllSeriesRoute(query: item.name).go(context);
                    },
            ),
        ],
      ),
      _SearchSection(
        title: l.chapters,
        children: [
          for (final item in results.chapters ?? const <ChapterDto>[])
            _SearchResultTile(
              icon: KoverIcons.chapter,
              title: item.titleName ?? item.title ?? item.range ?? l.chapters,
              subtitle: item.volumeTitle,
              onTap: item.id == null
                  ? null
                  : () => _openResolvedSeries(
                      context,
                      controller,
                      ref.read(searchSeriesForChapterProvider(item.id!).future),
                    ),
            ),
        ],
      ),
      _SearchSection(
        title: l.files,
        children: [
          for (final item in results.files ?? const <MangaFileDto>[])
            _SearchResultTile(
              icon: KoverIcons.chapter,
              title: _fileName(item.filePath) ?? l.files,
              subtitle: item.filePath,
              onTap: item.id == null
                  ? null
                  : () => _openResolvedSeries(
                      context,
                      controller,
                      ref.read(searchSeriesForFileProvider(item.id!).future),
                    ),
            ),
        ],
      ),
      _SearchSection(
        title: l.annotations,
        children: [
          for (final item in results.annotations ?? const <AnnotationDto>[])
            _SearchResultTile(
              cover: SeriesCoverImage(seriesId: item.seriesId),
              icon: KoverIcons.highlight,
              title:
                  item.seriesName ??
                  item.selectedText ??
                  item.commentPlainText ??
                  l.annotations,
              subtitle: item.chapterTitle,
              onTap: () {
                controller.closeView(null);
                ChapterDetailRoute(
                  seriesId: item.seriesId,
                  chapterId: item.chapterId,
                ).go(context);
              },
            ),
        ],
      ),
    ];

    final visibleSections = sections.where(
      (section) => section is! _SearchSection || section.children.isNotEmpty,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: LayoutConstants.mediumPadding,
      ),
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          ...visibleSections,
          if (results.isEmpty && volumes.isEmpty)
            Padding(
              padding: LayoutConstants.largeEdgeInsets,
              child: Text(
                l.noSearchResults,
                textAlign: .center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
        ],
      ),
    );
  }
}

class _SearchSection extends StatelessWidget {
  const _SearchSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: LayoutConstants.mediumPadding,
            bottom: LayoutConstants.smallPadding,
          ),
          child: Text(title, style: Theme.of(context).textTheme.headlineSmall),
        ),
        ...children,
      ],
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  const _SearchResultTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.cover,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? cover;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card.filled(
      margin: const EdgeInsets.only(bottom: LayoutConstants.smallerPadding),
      clipBehavior: .antiAlias,
      child: ListTile(
        leading: SizedBox(
          width: LayoutConstants.largestIcon,
          height: LayoutConstants.largestIcon,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              LayoutConstants.smallBorderRadius,
            ),
            child: cover ?? Icon(icon),
          ),
        ),
        title: Text(title, maxLines: 1, overflow: .ellipsis),
        subtitle: subtitle == null || subtitle!.isEmpty
            ? null
            : Text(subtitle!, maxLines: 1, overflow: .ellipsis),
        trailing: onTap == null ? null : const Icon(KoverIcons.chevronRight),
        onTap: onTap,
      ),
    );
  }
}

class _VolumeSearchResult extends ConsumerWidget {
  const _VolumeSearchResult({
    required this.volume,
    required this.controller,
  });

  final VolumeModel volume;
  final SearchController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seriesName = ref.watch(
      seriesProvider(
        seriesId: volume.seriesId,
      ).select((state) => state.value?.name),
    );

    return _SearchResultTile(
      cover: VolumeCoverImage(volumeId: volume.id),
      icon: KoverIcons.volume,
      title: volume.name,
      subtitle: seriesName,
      onTap: () {
        controller.closeView(null);
        VolumeDetailRoute(
          seriesId: volume.seriesId,
          volumeId: volume.id,
        ).go(context);
      },
    );
  }
}

Future<void> _openResolvedSeries(
  BuildContext context,
  SearchController controller,
  Future<SeriesDto> seriesFuture,
) async {
  try {
    final series = await seriesFuture;
    if (!context.mounted) return;
    final seriesId = series.id;
    if (seriesId == null) throw StateError('Search result has no series id');

    controller.closeView(null);
    SeriesDetailRoute(seriesId: seriesId).go(context);
  } catch (_) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).searchResultUnavailable),
        ),
      );
  }
}

String _seriesTitle(SearchResultDto item, String query) {
  final normalizedQuery = query.toLowerCase();
  final name = item.name;
  final localizedName = item.localizedName;
  if (name != null && name.toLowerCase().contains(normalizedQuery)) return name;
  return localizedName ?? name ?? item.originalName ?? item.sortName ?? '';
}

String? _fileName(String? path) {
  if (path == null || path.isEmpty) return null;
  return path.split(RegExp(r'[/\\]')).last;
}

extension on SearchResultGroupDto {
  bool get isEmpty =>
      (libraries?.isEmpty ?? true) &&
      (this.series?.isEmpty ?? true) &&
      (collections?.isEmpty ?? true) &&
      (readingLists?.isEmpty ?? true) &&
      (persons?.isEmpty ?? true) &&
      (genres?.isEmpty ?? true) &&
      (tags?.isEmpty ?? true) &&
      (files?.isEmpty ?? true) &&
      (chapters?.isEmpty ?? true) &&
      (bookmarks?.isEmpty ?? true) &&
      (annotations?.isEmpty ?? true);
}
