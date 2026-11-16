import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kover/pages/reader/overlay/bookmark_button.dart';
import 'package:kover/pages/reader/overlay/reader_overlay_provider.dart';
import 'package:kover/utils/constants/kover_icons.dart';
import 'package:kover/utils/extensions/format.dart';
import 'package:kover/utils/layout_constants.dart';
import 'package:kover/widgets/util/async_value.dart';
import 'package:material_ui/material_ui.dart';

class ReaderHeader extends ConsumerWidget {
  final int seriesId;
  final int chapterId;
  final int? readingListId;
  final bool hasDrawer;

  const new({
    super.key,
    required this.seriesId,
    required this.chapterId,
    required this.readingListId,
    this.hasDrawer = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final model = (ref.watch(
      readerOverlayProvider(
        seriesId: seriesId,
        chapterId: chapterId,
        readingListId: readingListId,
      ),
    ));

    return SafeArea(
      child: Card.filled(
        margin: const EdgeInsets.all(LayoutConstants.smallPadding),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: LayoutConstants.smallerPadding,
            vertical: LayoutConstants.smallerPadding,
          ),
          child: Async(
            asyncValue: model,
            data: (data) => Row(
              mainAxisAlignment: .spaceBetween,
              crossAxisAlignment: .center,
              mainAxisSize: .min,
              spacing: LayoutConstants.smallPadding,
              children: [
                IconButton(
                  icon: const Icon(KoverIcons.arrowBack),
                  onPressed: () => context.pop(),
                ),
                Expanded(
                  child: Text(
                    '${data.reader.series.name} · ${data.reader.chapter.title}',
                    maxLines: 1,
                    textAlign: .center,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (hasDrawer || data.reader.series.format == .epub)
                  IconButton(
                    icon: const Icon(KoverIcons.tableOfContents),
                    onPressed: () => Scaffold.of(context).openEndDrawer(),
                  )
                else if (data.reader.series.format.isImage)
                  BookmarkButton(
                    seriesId: seriesId,
                    chapterId: chapterId,
                    readingListId: readingListId,
                  )
                else
                  const SizedBox.square(
                    dimension: LayoutConstants.mediumIcon,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
