import 'package:flutter_test/flutter_test.dart';
import 'package:country_weather_app/features/countries/domain/repositories/recent_search_repository.dart';
import 'package:country_weather_app/features/countries/domain/usecases/add_recent_search.dart';

class _FakeRecentSearches implements RecentSearchRepository {
  List<String> saved = [];

  @override
  Future<List<String>> getAll() async => saved;

  @override
  Future<void> saveAll(List<String> searches) async => saved = searches;

  @override
  Future<void> clear() async => saved = [];
}

void main() {
  late _FakeRecentSearches repository;
  late AddRecentSearch addRecentSearch;

  setUp(() {
    repository = _FakeRecentSearches();
    addRecentSearch = AddRecentSearch(repository);
  });

  test('newest search goes first', () async {
    await addRecentSearch('India');
    await addRecentSearch('Japan');

    expect(repository.saved, ['Japan', 'India']);
  });

  test('a repeated search moves to the top without a duplicate', () async {
    await addRecentSearch('India');
    await addRecentSearch('Japan');
    await addRecentSearch('India');

    expect(repository.saved, ['India', 'Japan']);
  });

  test('keeps only the last 5', () async {
    for (final name in ['A', 'B', 'C', 'D', 'E', 'F']) {
      await addRecentSearch(name);
    }

    expect(repository.saved, ['F', 'E', 'D', 'C', 'B']);
  });

  test('ignores blank searches and trims names', () async {
    await addRecentSearch('   ');
    expect(repository.saved, isEmpty);

    await addRecentSearch('  India ');
    expect(repository.saved, ['India']);
  });
}
