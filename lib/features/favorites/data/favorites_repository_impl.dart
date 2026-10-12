import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/favorites_repository.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  FavoritesRepositoryImpl(this._prefs);

  static const _key = 'favorite_countries';

  final SharedPreferences _prefs;
  final _controller = StreamController<Set<String>>.broadcast();

  @override
  Set<String> get favorites => (_prefs.getStringList(_key) ?? []).toSet();

  @override
  Stream<Set<String>> get changes => _controller.stream;

  @override
  Future<bool> toggle(String code) async {
    final updated = favorites;
    final isFavorite = updated.add(code);
    if (!isFavorite) updated.remove(code);

    await _prefs.setStringList(_key, updated.toList());
    _controller.add(updated);
    return isFavorite;
  }

  @override
  Future<void> clear() async {
    await _prefs.remove(_key);
    _controller.add({});
  }
}
