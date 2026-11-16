import 'package:chopper/chopper.dart';
import 'package:kover/models/want_to_find_model.dart';
import 'package:kover/riverpod/providers/client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'want_to_find_repository.g.dart';

@Riverpod(keepAlive: true)
WantToFindRepository wantToFindRepository(Ref ref) {
  return WantToFindRepository(ref.watch(authenticatedClientProvider));
}

class WantToFindRepository {
  const WantToFindRepository(this.client);

  final ChopperClient client;

  static final _basePath = Uri.parse('/api/want-to-find');

  Future<List<WantToFindModel>> getAll() async {
    final response = await client.get<List<dynamic>, dynamic>(_basePath);
    _ensureSuccess(response, 'load Want To Find');

    return (response.body ?? const <dynamic>[])
        .map(
          (item) => WantToFindModel.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList(growable: false);
  }

  Future<WantToFindModel> create(WantToFindDraft draft) {
    return _upsert(Uri.parse('/api/want-to-find/create'), draft);
  }

  Future<WantToFindModel> update(int id, WantToFindDraft draft) {
    return _upsert(
      Uri.parse('/api/want-to-find/update'),
      draft,
      id: id,
    );
  }

  Future<void> delete(int id) async {
    final response = await client.delete<dynamic, dynamic>(
      _basePath,
      parameters: {'wantToFindId': id},
    );
    _ensureSuccess(response, 'delete Want To Find item');
  }

  Future<void> resolve({
    required int wantToFindId,
    required int seriesId,
    required bool addToWantToRead,
  }) async {
    final response = await client.post<dynamic, dynamic>(
      Uri.parse('/api/want-to-find/resolve'),
      body: {
        'wantToFindId': wantToFindId,
        'seriesId': seriesId,
        'addToWantToRead': addToWantToRead,
      },
    );
    _ensureSuccess(response, 'resolve Want To Find item');
  }

  Future<WantToFindModel> _upsert(
    Uri path,
    WantToFindDraft draft, {
    int id = 0,
  }) async {
    final response = await client.post<Map<String, dynamic>, dynamic>(
      path,
      body: draft.toJson(id: id),
    );
    _ensureSuccess(response, 'save Want To Find item');
    final body = response.body;
    if (body == null) throw StateError('Want To Find response has no body');
    return WantToFindModel.fromJson(body);
  }

  void _ensureSuccess(Response<dynamic> response, String action) {
    if (!response.isSuccessful) {
      throw Exception('Failed to $action: ${response.error}');
    }
  }
}
