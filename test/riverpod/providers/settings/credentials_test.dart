import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/experimental/persist.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kover/riverpod/providers/settings/credentials.dart';
import 'package:kover/riverpod/repository/secure_storage.dart';
import 'package:kover/utils/constants/kunini_server.dart';

void main() {
  test('fresh installs default to the Kunini Kavita server', () async {
    final container = ProviderContainer.test(
      overrides: [
        secureStorageProvider.overrideWith(
          (ref) => Storage<String, String>.inMemory(),
        ),
      ],
    );

    final credentials = await container.read(credentialsProvider.future);

    expect(defaultKavitaServerUrl, 'https://books.kunini.ru');
    expect(credentials.url, defaultKavitaServerUrl);
    expect(credentials.apiKey, isNull);
  });
}
