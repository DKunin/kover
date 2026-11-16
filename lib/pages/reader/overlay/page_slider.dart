import 'package:material_ui/material_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kover/riverpod/providers/reader/reader_navigation.dart';
import 'package:kover/utils/layout_constants.dart';
import 'package:kover/widgets/util/async_value.dart';

class PageSlider extends ConsumerWidget {
  final int seriesId;
  final int chapterId;
  final int? readingListId;
  final void Function(int page)? onJumpToPage;

  const PageSlider({
    super.key,
    required this.seriesId,
    required this.chapterId,
    required this.readingListId,
    this.onJumpToPage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navState = ref.watch(
      readerNavigationProvider(
        seriesId: seriesId,
        chapterId: chapterId,
        readingListId: readingListId,
      ),
    );

    return Async(
      asyncValue: navState,
      data: (navState) => HookBuilder(
        builder: (context) {
          final max = navState.totalPages - 1;
          final divisions = max > 0 ? max : null;
          final currentPage = navState.currentPage.clamp(0, max);
          final sliderValue = useState(currentPage.toDouble());

          useEffect(() {
            sliderValue.value = currentPage.toDouble();
            return null;
          }, [currentPage]);

          return Row(
            children: [
              const SizedBox(width: LayoutConstants.smallPadding),
              Text(
                '${currentPage + 1} / ${navState.totalPages}',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              Expanded(
                child: Slider(
                  value: sliderValue.value,
                  min: 0,
                  max: max.toDouble(),
                  divisions: divisions,
                  label: '${sliderValue.value.floor() + 1}',
                  onChanged: (value) {
                    sliderValue.value = value;
                  },
                  onChangeEnd: (value) {
                    onJumpToPage?.call(
                      sliderValue.value.floor(),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      loading: () => const LinearProgressIndicator(),
    );
  }
}
