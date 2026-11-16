import 'package:kover/models/want_to_find_model.dart';
import 'package:kover/riverpod/repository/want_to_find_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'want_to_find.g.dart';

@riverpod
class WantToFindList extends _$WantToFindList {
  @override
  Future<List<WantToFindModel>> build() {
    return ref.watch(wantToFindRepositoryProvider).getAll();
  }

  Future<void> save({
    WantToFindModel? existing,
    required WantToFindDraft draft,
  }) async {
    final repository = ref.read(wantToFindRepositoryProvider);
    final saved = existing == null
        ? await repository.create(draft)
        : await repository.update(existing.id, draft);
    final items = [...?state.value];
    final index = items.indexWhere((item) => item.id == saved.id);
    if (index < 0) {
      items.add(saved);
    } else {
      items[index] = saved;
    }
    items.sort(_newestFirst);
    state = AsyncData(items);
  }

  Future<void> delete(int id) async {
    await ref.read(wantToFindRepositoryProvider).delete(id);
    state = AsyncData([
      for (final item in state.value ?? const <WantToFindModel>[])
        if (item.id != id) item,
    ]);
  }

  Future<void> resolve({
    required int wantToFindId,
    required int seriesId,
    required bool addToWantToRead,
  }) async {
    await ref
        .read(wantToFindRepositoryProvider)
        .resolve(
          wantToFindId: wantToFindId,
          seriesId: seriesId,
          addToWantToRead: addToWantToRead,
        );
    state = AsyncData([
      for (final item in state.value ?? const <WantToFindModel>[])
        if (item.id != wantToFindId) item,
    ]);
  }
}

int _newestFirst(WantToFindModel left, WantToFindModel right) {
  return (right.createdUtc ?? DateTime.fromMillisecondsSinceEpoch(0)).compareTo(
    left.createdUtc ?? DateTime.fromMillisecondsSinceEpoch(0),
  );
}
