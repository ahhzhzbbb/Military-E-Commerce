import 'package:flutter_test/flutter_test.dart';
import 'package:military_e_commerce/core/cache/api_cache.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('write and read returns cached JSON data', () async {
    final data = {
      'items': [
        {'id': 1, 'name': 'Helmet'},
      ],
    };

    await ApiCache.write('catalog:test', data, const Duration(minutes: 5));

    expect(await ApiCache.read('catalog:test'), data);
  });

  test('expired entries are not returned', () async {
    await ApiCache.write(
      'catalog:expired',
      {'value': 1},
      const Duration(milliseconds: -1),
    );

    expect(await ApiCache.read('catalog:expired'), isNull);
  });

  test('different request bodies produce different keys', () {
    final first = ApiCache.buildKey(
      'catalog:search',
      '/api/search',
      body: {'keyword': 'boots', 'index': 0, 'count': 20},
    );
    final second = ApiCache.buildKey(
      'catalog:search',
      '/api/search',
      body: {'keyword': 'helmet', 'index': 0, 'count': 20},
    );

    expect(first, isNot(second));
  });

  test('canonical key generation ignores map insertion order', () {
    final first = ApiCache.buildKey(
      'catalog:search',
      '/api/search',
      body: {'keyword': 'boots', 'index': 0, 'count': 20},
    );
    final second = ApiCache.buildKey(
      'catalog:search',
      '/api/search',
      body: {'count': 20, 'index': 0, 'keyword': 'boots'},
    );

    expect(first, second);
  });

  test('removeByPrefix clears matching product entries only', () async {
    await ApiCache.write(
      'catalog:product:1:/api/get_products:{}',
      {'id': 1},
      const Duration(minutes: 5),
    );
    await ApiCache.write(
      'catalog:product:1:/api/get_rates:{}',
      {'rates': []},
      const Duration(minutes: 5),
    );
    await ApiCache.write(
      'catalog:product:2:/api/get_products:{}',
      {'id': 2},
      const Duration(minutes: 5),
    );

    await ApiCache.removeByPrefix('catalog:product:1');

    expect(
      await ApiCache.read('catalog:product:1:/api/get_products:{}'),
      isNull,
    );
    expect(await ApiCache.read('catalog:product:1:/api/get_rates:{}'), isNull);
    expect(
      await ApiCache.read('catalog:product:2:/api/get_products:{}'),
      {'id': 2},
    );
  });
}
