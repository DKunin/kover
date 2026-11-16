import 'dart:convert';

import 'package:chopper/chopper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:kover/api/openapi.swagger.dart';
import 'package:kover/models/want_to_find_model.dart';
import 'package:kover/riverpod/repository/want_to_find_repository.dart';

void main() {
  late List<http.Request> requests;
  late ChopperClient client;
  late WantToFindRepository repository;

  setUp(() {
    requests = [];
    client = ChopperClient(
      baseUrl: Uri.parse('https://books.example'),
      client: MockClient((request) async {
        requests.add(request);
        final path = request.url.path;
        if (request.method == 'GET' && path == '/api/want-to-find') {
          return http.Response(
            jsonEncode([
              {
                'id': 7,
                'title': 'The Left Hand of Darkness',
                'authors': 'Ursula K. Le Guin',
                'isbn': '9780441478125',
                'createdUtc': '2026-11-15T12:00:00Z',
              },
            ]),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        if (request.method == 'POST' &&
            (path == '/api/want-to-find/create' ||
                path == '/api/want-to-find/update')) {
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          return http.Response(
            jsonEncode({
              ...body,
              'id': path.endsWith('create') ? 8 : body['id'],
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        if ((request.method == 'DELETE' && path == '/api/want-to-find') ||
            (request.method == 'POST' && path == '/api/want-to-find/resolve')) {
          return http.Response('', 204);
        }
        return http.Response('Not found', 404);
      }),
      converter: $JsonSerializableConverter(),
      interceptors: const [
        HeadersInterceptor({'x-api-key': 'test-key'}),
      ],
    );
    repository = WantToFindRepository(client);
  });

  tearDown(() => client.dispose());

  test('loads metadata-only wanted titles', () async {
    final result = await repository.getAll();

    expect(result, hasLength(1));
    expect(result.single.id, 7);
    expect(result.single.title, 'The Left Hand of Darkness');
    expect(result.single.authors, 'Ursula K. Le Guin');
    expect(result.single.createdUtc, DateTime.utc(2026, 11, 15, 12));
    expect(requests.single.headers['x-api-key'], 'test-key');
  });

  test('creates and updates wanted titles with normalized payloads', () async {
    const draft = WantToFindDraft(
      title: '  Dune  ',
      authors: '  Frank Herbert  ',
      coverUrl: ' https://example.com/dune.jpg ',
      notes: '   ',
    );

    final created = await repository.create(draft);
    final updated = await repository.update(8, draft);

    expect(created.id, 8);
    expect(updated.id, 8);
    for (final request in requests) {
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      expect(body['title'], 'Dune');
      expect(body['authors'], 'Frank Herbert');
      expect(body['coverUrl'], 'https://example.com/dune.jpg');
      expect(body['notes'], isNull);
    }
  });

  test('deletes and resolves wanted titles with the server contract', () async {
    await repository.delete(11);
    await repository.resolve(
      wantToFindId: 12,
      seriesId: 99,
      addToWantToRead: true,
    );

    expect(requests.first.method, 'DELETE');
    expect(requests.first.url.queryParameters['wantToFindId'], '11');
    final resolveBody = jsonDecode(requests.last.body) as Map<String, dynamic>;
    expect(resolveBody, {
      'wantToFindId': 12,
      'seriesId': 99,
      'addToWantToRead': true,
    });
  });
}
