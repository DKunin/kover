import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kover/generated/l10n/app_localizations.dart';
import 'package:kover/models/series_model.dart';
import 'package:kover/models/enums/order_by_option.dart';
import 'package:kover/models/enums/sort_direction.dart';
import 'package:kover/riverpod/providers/collections.dart';
import 'package:kover/riverpod/providers/library.dart';
import 'package:kover/riverpod/providers/series.dart';
import 'package:kover/widgets/list_page/series_list_page.dart';
import 'package:kover/widgets/list_page/series_filter_bar.dart';
import 'package:kover/widgets/list_page/sort_options_menu.dart';
import 'package:kover/widgets/util/async_value.dart';
import 'package:kover/widgets/util/login_guard.dart';
import 'package:material_ui/material_ui.dart';

class AllSeriesPage extends StatelessWidget {
  final String initialQuery;
  final PersonModel? initialWriter;
  final GenreModel? initialGenre;

  const AllSeriesPage({
    super.key,
    this.initialQuery = '',
    this.initialWriter,
    this.initialGenre,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      extendBody: true,
      body: LoginGuard(
        child: SeriesPage(
          title: l.library,
          initialQuery: initialQuery,
          initialWriters: [?initialWriter],
          initialGenres: [?initialGenre],
        ),
      ),
    );
  }
}

class LibrarySeriesPage extends ConsumerWidget {
  final int libraryId;

  const LibrarySeriesPage({
    super.key,
    required this.libraryId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final library = ref.watch(libraryProvider(libraryId: libraryId));
    return Async(
      asyncValue: library,
      data: (data) {
        return SeriesPage(
          title: data.name,
          libraryId: data.id,
        );
      },
    );
  }
}

class CollectionSeriesPage extends ConsumerWidget {
  final int collectionId;

  const CollectionSeriesPage({
    super.key,
    required this.collectionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collection = ref.watch(
      collectionProvider(collectionId: collectionId),
    );
    return Async(
      asyncValue: collection,
      data: (data) {
        return SeriesPage(
          title: data.title,
          collectionId: data.id,
        );
      },
    );
  }
}

class SeriesPage extends HookConsumerWidget {
  final String title;
  final String? subtitle;
  final int? libraryId;
  final int? collectionId;
  final String initialQuery;
  final List<PersonModel> initialWriters;
  final List<GenreModel> initialGenres;

  const SeriesPage({
    super.key,
    required this.title,
    this.subtitle,
    this.libraryId,
    this.collectionId,
    this.initialQuery = '',
    this.initialWriters = const [],
    this.initialGenres = const [],
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderBy = useState(UnorderedSortOption.name);
    final sortDirection = useState(SortDirection.ascending);
    final hideRead = useState(false);
    final downloadedOnly = useState(false);
    final controller = useTextEditingController(text: initialQuery);
    final selectedWriters = useState<List<PersonModel>>(
      List.of(initialWriters),
    );
    final selectedGenres = useState<List<GenreModel>>(
      List.of(initialGenres),
    );

    useListenable(controller);

    final initialWriterIds = initialWriters.map((item) => item.id).join(',');
    final initialGenreIds = initialGenres.map((item) => item.id).join(',');
    useEffect(() {
      final selectedWriterIds = selectedWriters.value
          .map((item) => item.id)
          .join(',');
      final selectedGenreIds = selectedGenres.value
          .map((item) => item.id)
          .join(',');
      if (selectedWriterIds != initialWriterIds) {
        selectedWriters.value = List.of(initialWriters);
      }
      if (selectedGenreIds != initialGenreIds) {
        selectedGenres.value = List.of(initialGenres);
      }
      if (controller.text != initialQuery) {
        controller.text = initialQuery;
      }
      return null;
    }, [initialWriterIds, initialGenreIds, initialQuery]);

    final writerIds = useMemoized(
      () => selectedWriters.value.map((item) => item.id).toList(),
      [selectedWriters.value],
    );
    final genreIds = useMemoized(
      () => selectedGenres.value.map((item) => item.id).toList(),
      [selectedGenres.value],
    );

    final query = ref.watch(
      filterSeriesProvider(
        controller.text,
        libraryId: libraryId,
        collectionId: collectionId,
        writerIds: writerIds,
        genreIds: genreIds,
        orderBy: orderBy.value,
        direction: sortDirection.value,
        hideRead: hideRead.value,
        downloadedOnly: downloadedOnly.value,
      ),
    );
    final writerOptions =
        ref
            .watch(
              seriesWritersProvider(
                libraryId: libraryId,
                collectionId: collectionId,
              ),
            )
            .value ??
        const [];
    final genreOptions =
        ref
            .watch(
              seriesGenresProvider(
                libraryId: libraryId,
                collectionId: collectionId,
              ),
            )
            .value ??
        const [];

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: SeriesListPage(
        title: title,
        controller: controller,
        filterControls: SeriesFilterBar(
          writerOptions: writerOptions,
          genreOptions: genreOptions,
          selectedWriters: selectedWriters.value,
          selectedGenres: selectedGenres.value,
          onWritersChanged: (value) => selectedWriters.value = value,
          onGenresChanged: (value) => selectedGenres.value = value,
        ),
        sortMenu: UnorderedSortMenu(
          sortDirection: sortDirection.value,
          onSortDirectionChanged: (onSort) => sortDirection.value = onSort,
          orderBy: orderBy.value,
          onOrderByChanged: (onOrder) => orderBy.value = onOrder,
          hideRead: hideRead.value,
          onHideReadChanged: (onHideRead) => hideRead.value = onHideRead,
          downloadedOnly: downloadedOnly.value,
          onDownloadedOnlyChanged: (value) => downloadedOnly.value = value,
        ),
        series: query,
      ),
    );
  }
}
