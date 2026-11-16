import 'package:kover/generated/l10n/app_localizations.dart';
import 'package:kover/models/series_model.dart';
import 'package:kover/utils/constants/kover_icons.dart';
import 'package:kover/utils/layout_constants.dart';
import 'package:material_ui/material_ui.dart';

class SeriesFilterBar extends StatelessWidget {
  final List<PersonModel> writerOptions;
  final List<GenreModel> genreOptions;
  final List<PersonModel> selectedWriters;
  final List<GenreModel> selectedGenres;
  final ValueChanged<List<PersonModel>> onWritersChanged;
  final ValueChanged<List<GenreModel>> onGenresChanged;

  const SeriesFilterBar({
    super.key,
    required this.writerOptions,
    required this.genreOptions,
    required this.selectedWriters,
    required this.selectedGenres,
    required this.onWritersChanged,
    required this.onGenresChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final hasFilters = selectedWriters.isNotEmpty || selectedGenres.isNotEmpty;

    Future<void> showWriters() {
      return _showFacetPicker<PersonModel>(
        context,
        title: l.writers,
        icon: KoverIcons.person,
        options: writerOptions,
        selected: selectedWriters,
        idOf: (writer) => writer.id,
        labelOf: (writer) => writer.name,
        onChanged: onWritersChanged,
      );
    }

    Future<void> showGenres() {
      return _showFacetPicker<GenreModel>(
        context,
        title: l.genres,
        icon: KoverIcons.tag,
        options: genreOptions,
        selected: selectedGenres,
        idOf: (genre) => genre.id,
        labelOf: (genre) => genre.name,
        onChanged: onGenresChanged,
      );
    }

    return Wrap(
      spacing: LayoutConstants.smallPadding,
      runSpacing: LayoutConstants.smallPadding,
      crossAxisAlignment: .center,
      children: [
        FilterChip(
          avatar: const Icon(KoverIcons.person),
          label: Text(
            selectedWriters.isEmpty
                ? l.writers
                : '${l.writers} (${selectedWriters.length})',
          ),
          selected: selectedWriters.isNotEmpty,
          onSelected: (_) async => showWriters(),
        ),
        FilterChip(
          avatar: const Icon(KoverIcons.tag),
          label: Text(
            selectedGenres.isEmpty
                ? l.genres
                : '${l.genres} (${selectedGenres.length})',
          ),
          selected: selectedGenres.isNotEmpty,
          onSelected: (_) async => showGenres(),
        ),
        ...selectedWriters.map(
          (writer) => InputChip(
            avatar: const Icon(KoverIcons.person),
            label: Text(writer.name),
            onPressed: showWriters,
            onDeleted: () => onWritersChanged(
              selectedWriters.where((item) => item.id != writer.id).toList(),
            ),
          ),
        ),
        ...selectedGenres.map(
          (genre) => InputChip(
            avatar: const Icon(KoverIcons.tag),
            label: Text(genre.name),
            onPressed: showGenres,
            onDeleted: () => onGenresChanged(
              selectedGenres.where((item) => item.id != genre.id).toList(),
            ),
          ),
        ),
        if (hasFilters)
          TextButton(
            onPressed: () {
              onWritersChanged(const []);
              onGenresChanged(const []);
            },
            child: Text(l.clearAll),
          ),
      ],
    );
  }
}

Future<void> _showFacetPicker<T>(
  BuildContext context, {
  required String title,
  required IconData icon,
  required List<T> options,
  required List<T> selected,
  required int Function(T item) idOf,
  required String Function(T item) labelOf,
  required ValueChanged<List<T>> onChanged,
}) async {
  final l = AppLocalizations.of(context);
  final controller = TextEditingController();
  final allOptions = <int, T>{for (final item in options) idOf(item): item};
  for (final item in selected) {
    allOptions.putIfAbsent(idOf(item), () => item);
  }
  final selectedById = <int, T>{
    for (final item in selected) idOf(item): item,
  };
  var query = '';

  try {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final visibleOptions = allOptions.values
              .where(
                (item) => labelOf(
                  item,
                ).toLowerCase().contains(query.toLowerCase()),
              )
              .toList();

          return FractionallySizedBox(
            heightFactor: .85,
            child: Column(
              children: [
                ListTile(
                  leading: Icon(icon),
                  title: Text(title),
                  trailing: IconButton(
                    icon: const Icon(KoverIcons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: LayoutConstants.mediumPadding,
                  ),
                  child: TextField(
                    controller: controller,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: '${l.filter} $title',
                      prefixIcon: const Icon(KoverIcons.search),
                      suffixIcon: query.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(KoverIcons.clear),
                              onPressed: () {
                                controller.clear();
                                setModalState(() => query = '');
                              },
                            ),
                    ),
                    onChanged: (value) => setModalState(() => query = value),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    keyboardDismissBehavior: .onDrag,
                    itemCount: visibleOptions.length,
                    itemBuilder: (context, index) {
                      final option = visibleOptions[index];
                      final id = idOf(option);
                      return CheckboxListTile(
                        value: selectedById.containsKey(id),
                        title: Text(labelOf(option)),
                        controlAffinity: .leading,
                        onChanged: (checked) {
                          setModalState(() {
                            if (checked ?? false) {
                              selectedById[id] = option;
                            } else {
                              selectedById.remove(id);
                            }
                          });
                          onChanged(selectedById.values.toList());
                        },
                      );
                    },
                  ),
                ),
                if (selectedById.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(
                      LayoutConstants.mediumPadding,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () {
                          setModalState(selectedById.clear);
                          onChanged(const []);
                        },
                        child: Text(l.clearAll),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  } finally {
    controller.dispose();
  }
}
