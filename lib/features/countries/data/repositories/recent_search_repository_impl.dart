import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repositories/recent_search_repository.dart';

class RecentSearchRepositoryImpl implements RecentSearchRepository {
  RecentSearchRepositoryImpl(this._prefs);

  static const _key = 'recent_searches';

  final SharedPreferences _prefs;

  @override
  Future<List<String>> getAll() async => _prefs.getStringList(_key) ?? [];

  @override
  Future<void> saveAll(List<String> searches) async {
    await _prefs.setStringList(_key, searches);
  }

  @override
  Future<void> clear() async {
    await _prefs.remove(_key);
  }
}
