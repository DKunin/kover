import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/experimental/persist.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kover/models/reading_style_preset.dart';
import 'package:kover/riverpod/providers/settings/epub_reader_settings.dart';
import 'package:kover/riverpod/providers/settings/image_reader_settings.dart';
import 'package:kover/riverpod/repository/storage_repository.dart';

void main() {
  group('EPUB reading styles', () {
    test('book preset applies a comfortable text layout', () {
      final result = const EpubReaderSettingsState().applyPreset(
        ReadingStylePreset.book,
      );

      expect(result.theme, EpubTheme.sepia);
      expect(result.mode, EpubReaderMode.horizontal);
      expect(result.fontSize, 16);
      expect(result.lineHeight, 1.6);
      expect(result.ignoreSafeAreas, isFalse);
      expect(
        EpubReadingStylePresetsState.defaults().matchingPreset(result),
        ReadingStylePreset.book,
      );
    });

    test('comic preset applies an edge-to-edge vertical layout', () {
      final result = const EpubReaderSettingsState().applyPreset(
        ReadingStylePreset.comic,
      );

      expect(result.theme, EpubTheme.black);
      expect(result.mode, EpubReaderMode.vertical);
      expect(result.horizontalMarginSize, 4);
      expect(result.verticalMarginSize, 4);
      expect(result.highlightResumePoint, isFalse);
      expect(result.ignoreSafeAreas, isTrue);
      expect(
        EpubReadingStylePresetsState.defaults().matchingPreset(result),
        ReadingStylePreset.comic,
      );
    });

    test('fine tuning clears the exact preset selection', () {
      final result = const EpubReaderSettingsState()
          .applyPreset(ReadingStylePreset.book)
          .copyWith(fontSize: 18);

      expect(
        EpubReadingStylePresetsState.defaults().matchingPreset(result),
        isNull,
      );
    });

    test('saved customization replaces and applies the book slot', () {
      final custom = const EpubReaderSettingsState().copyWith(
        fontSize: 21,
        lineHeight: 2,
      );
      final presets = EpubReadingStylePresetsState.defaults().copyWith(
        book: custom,
      );

      expect(presets.style(.book), custom);
      expect(presets.matchingPreset(custom), ReadingStylePreset.book);
    });

    test('saved current settings are applied on the next selection', () async {
      final container = ProviderContainer.test(
        overrides: [
          storageProvider.overrideWith(
            (ref) => Storage<String, String>.inMemory(),
          ),
        ],
      );
      final provider = epubReaderSettingsProvider(seriesId: 1);
      await container.read(provider.future);

      await container
          .read(provider.notifier)
          .applyReadingStyle(ReadingStylePreset.book);
      await container.read(provider.notifier).setFontSize(21);
      await container
          .read(provider.notifier)
          .saveReadingStyle(ReadingStylePreset.book);
      await container.read(provider.notifier).setFontSize(13);
      await container
          .read(provider.notifier)
          .applyReadingStyle(ReadingStylePreset.book);

      expect(container.read(provider).requireValue.fontSize, 21);
    });

    test('saved customization persists after provider recreation', () async {
      final storage = Storage<String, String>.inMemory();
      final custom = const EpubReaderSettingsState().copyWith(fontSize: 23);
      var container = ProviderContainer(
        overrides: [
          storageProvider.overrideWith((ref) => storage),
        ],
      );
      await container.read(epubReadingStylePresetsProvider.future);
      await container
          .read(epubReadingStylePresetsProvider.notifier)
          .save(ReadingStylePreset.book, custom);
      container.dispose();

      container = ProviderContainer(
        overrides: [
          storageProvider.overrideWith((ref) => storage),
        ],
      );
      addTearDown(container.dispose);

      final restored = await container.read(
        epubReadingStylePresetsProvider.future,
      );
      expect(restored.style(ReadingStylePreset.book), custom);
    });
  });

  group('image reading styles', () {
    test('book preset shows one contained page', () {
      final result = const ImageReaderSettingsState().applyPreset(
        ReadingStylePreset.book,
      );

      expect(result.readerMode, ReaderMode.horizontal);
      expect(result.scaleType, ImageScaleType.contain);
      expect(result.ignoreSafeAreas, isFalse);
      expect(result.lockHorizontalPan, isFalse);
      expect(
        ImageReadingStylePresetsState.defaults().matchingPreset(result),
        ReadingStylePreset.book,
      );
    });

    test('comic preset uses full-width vertical scrolling', () {
      final result = const ImageReaderSettingsState().applyPreset(
        ReadingStylePreset.comic,
      );

      expect(result.readerMode, ReaderMode.vertical);
      expect(result.scaleType, ImageScaleType.fitWidth);
      expect(result.verticalReaderGap, 0);
      expect(result.verticalReaderPadding, 0);
      expect(result.ignoreSafeAreas, isTrue);
      expect(result.lockHorizontalPan, isTrue);
      expect(
        ImageReadingStylePresetsState.defaults().matchingPreset(result),
        ReadingStylePreset.comic,
      );
    });

    test('saved customization replaces and applies the comic slot', () {
      final custom = const ImageReaderSettingsState().copyWith(
        readerMode: ReaderMode.spread,
        spreadReaderGap: 12,
      );
      final presets = ImageReadingStylePresetsState.defaults().copyWith(
        comic: custom,
      );

      expect(presets.style(.comic), custom);
      expect(presets.matchingPreset(custom), ReadingStylePreset.comic);
    });

    test('saved current settings are applied on the next selection', () async {
      final container = ProviderContainer.test(
        overrides: [
          storageProvider.overrideWith(
            (ref) => Storage<String, String>.inMemory(),
          ),
        ],
      );
      final provider = imageReaderSettingsProvider(seriesId: 1);
      await container.read(provider.future);

      await container
          .read(provider.notifier)
          .applyReadingStyle(ReadingStylePreset.comic);
      await container.read(provider.notifier).setVerticalReaderGap(24);
      await container
          .read(provider.notifier)
          .saveReadingStyle(ReadingStylePreset.comic);
      await container.read(provider.notifier).setVerticalReaderGap(0);
      await container
          .read(provider.notifier)
          .applyReadingStyle(ReadingStylePreset.comic);

      expect(container.read(provider).requireValue.verticalReaderGap, 24);
    });
  });
}
