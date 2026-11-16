import 'dart:async';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kover/database/app_database.dart';
import 'package:kover/database/dao/chapters_dao.dart';
import 'package:kover/database/dao/series_dao.dart';
import 'package:kover/models/enums/age_rating.dart';
import 'package:kover/models/enums/format.dart';
import 'package:kover/models/enums/library_type.dart';
import 'package:kover/models/enums/person_role.dart';
import 'package:kover/models/enums/publication_status.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(
      DatabaseConnection(
        NativeDatabase.memory(),
        closeStreamsSynchronously: true,
      ),
    );
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> insertLibrary(int id) async {
    await database
        .into(database.libraries)
        .insert(
          LibrariesCompanion.insert(
            id: Value(id),
            name: 'lib$id',
            type: LibraryType.manga,
          ),
        );
  }

  Future<void> insertSeries(
    int id, {
    int libraryId = 1,
    DateTime? lastSynced,
    DateTime? lastChapterAdded,
    DateTime? remoteLastRead,
    int pages = 0,
  }) async {
    await database
        .into(database.series)
        .insert(
          SeriesCompanion(
            id: Value(id),
            libraryId: Value(libraryId),
            name: Value('name$id'),
            format: const Value(Format.epub),
            created: Value(DateTime.now()),
            pages: Value(pages),
            lastChapterAdded: Value.absentIfNull(lastChapterAdded),
            lastSynced: Value.absentIfNull(lastSynced),
            remoteLastRead: Value.absentIfNull(remoteLastRead),
          ),
        );
  }

  Future<void> insertChapter(
    int id, {
    required int seriesId,
    Format format = .epub,
    String? title,
    String? titleName,
    String? isbn,
  }) async {
    await database
        .into(database.chapters)
        .insert(
          ChaptersCompanion.insert(
            id: Value(id),
            volumeId: 0,
            seriesId: seriesId,
            title: Value.absentIfNull(title),
            titleName: Value.absentIfNull(titleName),
            isbn: Value.absentIfNull(isbn),
            format: format,
            minNumber: 0,
            maxNumber: 0,
            sortOrder: 0,
            ageRating: AgeRating.unknown,
            publicationStatus: PublicationStatus.unknown,
            wordCount: 0,
            releaseDate: DateTime.now(),
            created: DateTime.now(),
            lastModified: DateTime.now(),
            pages: 3,
          ),
        );
  }

  Future<void> insertDownloadedPage(int chapterId) async {
    await database
        .into(database.downloadedPages)
        .insert(
          DownloadedPagesCompanion.insert(
            chapterId: chapterId,
            page: 0,
            data: Uint8List.fromList([]),
          ),
        );
  }

  Future<void> insertBookmark({
    required int seriesId,
    required int chapterId,
    bool removed = false,
  }) async {
    await database
        .into(database.bookmarks)
        .insert(
          BookmarksCompanion.insert(
            seriesId: seriesId,
            volumeId: 0,
            chapterId: chapterId,
            page: 0,
            imageOffset: const Value(0),
            removed: Value(removed),
          ),
        );
  }

  Future<void> insertReadingProgress({
    required int chapterId,
    required int seriesId,
    required int pagesRead,
  }) async {
    await database
        .into(database.readingProgress)
        .insert(
          ReadingProgressCompanion.insert(
            chapterId: Value(chapterId),
            volumeId: 0,
            seriesId: seriesId,
            libraryId: 1,
            pagesRead: Value(pagesRead),
            lastModified: Value(DateTime.now()),
          ),
        );
  }

  Future<void> insertPerson(int id, String name) async {
    await database
        .into(database.people)
        .insert(
          PeopleCompanion.insert(id: Value(id), name: name),
        );
  }

  Future<void> insertGenre(int id, String label) async {
    await database
        .into(database.genres)
        .insert(
          GenresCompanion.insert(id: Value(id), label: label),
        );
  }

  Future<void> insertTag(int id, String label) async {
    await database
        .into(database.tags)
        .insert(TagsCompanion.insert(id: Value(id), label: label));
  }

  Future<void> insertSeriesMetadata(
    int id, {
    required int seriesId,
    List<int> writerIds = const [],
    List<int> genreIds = const [],
  }) async {
    await database
        .into(database.seriesMetadata)
        .insert(
          SeriesMetadataCompanion.insert(
            id: Value(id),
            seriesId: seriesId,
            ageRating: AgeRating.unknown,
            maxCount: 0,
            totalCount: 0,
            publicationStatus: PublicationStatus.unknown,
          ),
        );
    for (final writerId in writerIds) {
      await database
          .into(database.seriesPeopleRoles)
          .insert(
            SeriesPeopleRolesCompanion.insert(
              seriesMetadataId: id,
              personId: writerId,
              role: PersonRole.writer,
            ),
          );
    }
    for (final genreId in genreIds) {
      await database
          .into(database.seriesGenres)
          .insert(
            SeriesGenresCompanion.insert(
              seriesMetadataId: id,
              genreId: genreId,
            ),
          );
    }
  }

  ChapterWithRelationsCompanion chapterWithProgress({
    required int id,
    required int seriesId,
    required int pagesRead,
    Format format = Format.epub,
    DateTime? remoteLastRead,
  }) {
    return ChapterWithRelationsCompanion(
      chapter: ChaptersCompanion(
        id: Value(id),
        volumeId: const Value(0),
        seriesId: Value(seriesId),
        format: Value(format),
        minNumber: const Value(0),
        maxNumber: const Value(0),
        sortOrder: const Value(0),
        pages: const Value(10),
        wordCount: const Value(0),
        ageRating: const Value(AgeRating.unknown),
        releaseDate: Value(DateTime.now()),
        publicationStatus: const Value(PublicationStatus.unknown),
        created: Value(DateTime.now()),
        lastModified: Value(DateTime.now()),
        remotePagesRead: Value(pagesRead),
        remoteLastRead: Value.absentIfNull(remoteLastRead),
      ),
      writers: const [],
      coverArtists: const [],
      publishers: const [],
      characters: const [],
      pencillers: const [],
      inkers: const [],
      imprints: const [],
      colorists: const [],
      letterers: const [],
      editors: const [],
      translators: const [],
      teams: const [],
      locations: const [],
      genres: const [],
      tags: const [],
    );
  }

  SeriesDetailCompanions detailWithChapters(
    List<ChapterWithRelationsCompanion> chapters,
  ) {
    return SeriesDetailCompanions(
      seriesId: 1,
      storyline: const [],
      specials: const [],
      chapters: chapters,
      volumes: const [],
    );
  }

  group('SeriesDao', () {
    group('getOutdatedDetailsSeriesIds', () {
      test(
        'returns only series that are never synced or changed since sync',
        () async {
          await insertLibrary(1);

          final synced = DateTime(2024, 1, 1, 12);

          // never synced -> selected
          await insertSeries(1, lastSynced: null);
          // synced, no changes -> not selected
          await insertSeries(
            2,
            lastSynced: synced,
            lastChapterAdded: synced.subtract(const Duration(days: 1)),
          );
          // new chapter since sync -> selected
          await insertSeries(
            3,
            lastSynced: synced,
            lastChapterAdded: synced.add(const Duration(hours: 1)),
          );
          // new read since sync -> selected
          await insertSeries(
            4,
            lastSynced: synced,
            lastChapterAdded: synced,
            remoteLastRead: synced.add(const Duration(hours: 2)),
          );
          // unchanged -> not selected
          await insertSeries(
            5,
            lastSynced: synced,
            lastChapterAdded: synced,
            remoteLastRead: synced,
          );

          final result = await database.seriesDao.getOutdatedDetailsSeriesIds();

          expect(result.toSet(), equals({1, 3, 4}));
        },
      );
    });

    group('allSeries downloadedOnly', () {
      test('returns only series with a downloaded page', () async {
        await insertLibrary(1);

        await insertSeries(1);
        await insertSeries(2);
        await insertSeries(3);

        await insertChapter(10, seriesId: 1);
        await insertChapter(20, seriesId: 2);

        await insertDownloadedPage(10);

        final result = await database.seriesDao
            .allSeries(downloadedOnly: true)
            .get();

        expect(result.map((s) => s.id).toSet(), equals({1}));
      });

      test('emits again when a page is downloaded', () async {
        await insertLibrary(1);

        await insertSeries(1);
        await insertSeries(2);
        await insertChapter(10, seriesId: 1);
        await insertChapter(20, seriesId: 2);

        final stream = database.seriesDao
            .allSeries(downloadedOnly: true)
            .watch()
            .map((rows) => rows.map((s) => s.id).toSet());

        final completer = Completer<Set<int>>();
        final subscription = stream.listen((ids) {
          if (ids.contains(2) && !completer.isCompleted) {
            completer.complete(ids);
          }
        });

        await insertDownloadedPage(20);

        expect(
          await completer.future,
          equals({2}),
        );

        await subscription.cancel();
      });
    });

    group('allSeries bookmarkedOnly', () {
      test(
        'returns only series with a non-removed bookmark on an image chapter',
        () async {
          await insertLibrary(1);

          await insertSeries(1);
          await insertSeries(2);
          await insertSeries(3);

          await insertChapter(10, seriesId: 1, format: .image);
          await insertChapter(20, seriesId: 2, format: .epub);
          await insertChapter(30, seriesId: 3, format: .image);

          await insertBookmark(seriesId: 1, chapterId: 10);
          await insertBookmark(seriesId: 2, chapterId: 20);
          await insertBookmark(seriesId: 3, chapterId: 30, removed: true);

          final result = await database.seriesDao
              .allSeries(bookmarkedOnly: true)
              .get();

          expect(result.map((s) => s.id).toSet(), equals({1}));
        },
      );
    });

    group('series metadata filters', () {
      test('combines writer and genre facets with exact ids', () async {
        await insertLibrary(1);
        await insertSeries(1);
        await insertSeries(2);
        await insertSeries(3);
        await insertSeries(4);
        await insertPerson(10, 'Writer A');
        await insertPerson(20, 'Writer B');
        await insertPerson(30, 'Chapter Writer');
        await insertGenre(100, 'Genre A');
        await insertGenre(200, 'Genre B');
        await insertGenre(300, 'Chapter Genre');
        await insertTag(400, 'Chapter Tag');
        await insertSeriesMetadata(
          1000,
          seriesId: 1,
          writerIds: const [10],
          genreIds: const [100],
        );
        await insertSeriesMetadata(
          2000,
          seriesId: 2,
          writerIds: const [20],
          genreIds: const [100],
        );
        await insertSeriesMetadata(
          3000,
          seriesId: 3,
          writerIds: const [10],
          genreIds: const [200],
        );
        await database
            .into(database.seriesPeopleRoles)
            .insert(
              SeriesPeopleRolesCompanion.insert(
                seriesMetadataId: 2000,
                personId: 10,
                role: PersonRole.coverArtist,
              ),
            );
        await insertChapter(
          40,
          seriesId: 4,
          title: 'Hidden Chapter Title',
          isbn: '9781234567890',
        );
        await database
            .into(database.chapterPeopleRoles)
            .insert(
              ChapterPeopleRolesCompanion.insert(
                chapterId: 40,
                personId: 30,
                role: PersonRole.writer,
              ),
            );
        await database
            .into(database.chapterGenres)
            .insert(
              ChapterGenresCompanion.insert(chapterId: 40, genreId: 300),
            );
        await database
            .into(database.chapterTags)
            .insert(ChapterTagsCompanion.insert(chapterId: 40, tagId: 400));

        final writerOnly = await database.seriesDao
            .allSeries(writerIds: const [10])
            .get();
        final genreOnly = await database.seriesDao
            .allSeries(genreIds: const [100])
            .get();
        final eitherWriter = await database.seriesDao
            .allSeries(writerIds: const [10, 20])
            .get();
        final intersection = await database.seriesDao
            .allSeries(
              writerIds: const [10],
              genreIds: const [100],
            )
            .get();
        final textIntersection = await database.seriesDao.filterSeries(
          'name1',
          writerIds: const [10],
          genreIds: const [100],
        );
        final chapterWriter = await database.seriesDao
            .allSeries(writerIds: const [30])
            .get();
        final chapterGenre = await database.seriesDao
            .allSeries(genreIds: const [300])
            .get();
        final chapterTitle = await database.seriesDao.filterSeries('hidden');
        final chapterIsbn = await database.seriesDao.filterSeries('978123');
        final chapterPerson = await database.seriesDao.filterSeries(
          'chapter writer',
        );
        final chapterGenreSearch = await database.seriesDao.filterSeries(
          'chapter genre',
        );
        final chapterTag = await database.seriesDao.filterSeries('chapter tag');

        expect(writerOnly.map((item) => item.id).toSet(), {1, 3});
        expect(genreOnly.map((item) => item.id).toSet(), {1, 2});
        expect(eitherWriter.map((item) => item.id).toSet(), {1, 2, 3});
        expect(intersection.map((item) => item.id).toSet(), {1});
        expect(textIntersection.map((item) => item.id), [1]);
        expect(chapterWriter.map((item) => item.id), [4]);
        expect(chapterGenre.map((item) => item.id), [4]);
        expect(chapterTitle.map((item) => item.id), [4]);
        expect(chapterIsbn.map((item) => item.id), [4]);
        expect(chapterPerson.map((item) => item.id), [4]);
        expect(chapterGenreSearch.map((item) => item.id), [4]);
        expect(chapterTag.map((item) => item.id), [4]);
      });

      test('scopes available writer and genre facets to the library', () async {
        await insertLibrary(1);
        await insertLibrary(2);
        await insertSeries(1);
        await insertSeries(2, libraryId: 2);
        await insertPerson(10, 'Writer A');
        await insertPerson(20, 'Writer B');
        await insertPerson(30, 'Chapter Writer');
        await insertGenre(100, 'Genre A');
        await insertGenre(200, 'Genre B');
        await insertGenre(300, 'Chapter Genre');
        await insertSeriesMetadata(
          1000,
          seriesId: 1,
          writerIds: const [10],
          genreIds: const [100],
        );
        await insertSeriesMetadata(
          2000,
          seriesId: 2,
          writerIds: const [20],
          genreIds: const [200],
        );
        await insertChapter(10, seriesId: 1);
        await database
            .into(database.chapterPeopleRoles)
            .insert(
              ChapterPeopleRolesCompanion.insert(
                chapterId: 10,
                personId: 30,
                role: PersonRole.writer,
              ),
            );
        await database
            .into(database.chapterGenres)
            .insert(
              ChapterGenresCompanion.insert(chapterId: 10, genreId: 300),
            );

        final writers = await database.seriesDao
            .watchSeriesWriters(libraryId: 1)
            .first;
        final genres = await database.seriesDao
            .watchSeriesGenres(libraryId: 1)
            .first;

        expect(writers.map((item) => item.id), [30, 10]);
        expect(genres.map((item) => item.id), [300, 100]);
      });
    });

    group('watchOnDeck downloadedOnly', () {
      test('returns only on deck series with a downloaded page', () async {
        await insertLibrary(1);

        await insertSeries(1, pages: 10);
        await insertSeries(2, pages: 10);

        await insertChapter(10, seriesId: 1);
        await insertChapter(20, seriesId: 2);

        await insertReadingProgress(
          chapterId: 10,
          seriesId: 1,
          pagesRead: 2,
        );
        await insertReadingProgress(
          chapterId: 20,
          seriesId: 2,
          pagesRead: 2,
        );

        await insertDownloadedPage(10);

        final result = await database.seriesDao
            .watchOnDeck(downloadedOnly: true)
            .first;

        expect(result.map((s) => s.id).toSet(), equals({1}));
      });
    });

    group('upsertDetailsBatch progress', () {
      test('seeds progress for chapters with read pages', () async {
        await insertLibrary(1);
        await insertSeries(1);

        final remoteLastRead = DateTime(2024, 1, 1);

        await database.seriesDao.upsertDetailsBatch([
          detailWithChapters([
            chapterWithProgress(
              id: 10,
              seriesId: 1,
              pagesRead: 2,
              remoteLastRead: remoteLastRead,
            ),
            chapterWithProgress(id: 20, seriesId: 1, pagesRead: 0),
            chapterWithProgress(
              id: 30,
              seriesId: 1,
              pagesRead: 3,
              format: Format.image,
            ),
          ]),
        ]);

        final progress = await database.select(database.readingProgress).get();

        expect(progress, hasLength(2));

        final epub = progress.singleWhere((p) => p.chapterId == 10);
        expect(epub.seriesId, 1);
        expect(epub.libraryId, 1);
        expect(epub.pagesRead, 2);
        expect(epub.lastModified, remoteLastRead);

        final image = progress.singleWhere((p) => p.chapterId == 30);
        expect(image.pagesRead, 3);
      });

      test('does not overwrite existing local progress', () async {
        await insertLibrary(1);
        await insertSeries(1);
        await insertReadingProgress(
          chapterId: 10,
          seriesId: 1,
          pagesRead: 1,
        );

        await database.seriesDao.upsertDetailsBatch([
          detailWithChapters([
            chapterWithProgress(id: 10, seriesId: 1, pagesRead: 2),
          ]),
        ]);

        final progress = await database
            .select(database.readingProgress)
            .getSingle();

        expect(progress.pagesRead, 1);
      });
    });
  });
}
