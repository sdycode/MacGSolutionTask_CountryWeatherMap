import 'package:hive_ce/hive.dart';

class CacheEntry {
  const CacheEntry(this.data, this.savedAt);

  final dynamic data;
  final DateTime savedAt;

  bool isYoungerThan(Duration maxAge) =>
      DateTime.now().difference(savedAt) < maxAge;
}

class CacheStore {
  CacheStore(this._box);

  final Box _box;

  CacheEntry? read(String key) {
    final value = _box.get(key);
    if (value is! Map) return null;

    final savedAt = value['savedAt'];
    if (savedAt is! int) return null;

    return CacheEntry(
      value['data'],
      DateTime.fromMillisecondsSinceEpoch(savedAt),
    );
  }

  Future<void> write(String key, Object? data, {DateTime? savedAt}) {
    return _box.put(key, {
      'data': data,
      'savedAt': (savedAt ?? DateTime.now()).millisecondsSinceEpoch,
    });
  }

  Future<void> removeOlderThan(String prefix, Duration maxAge) async {
    final oldKeys = _box.keys.where((key) {
      if (!key.toString().startsWith(prefix)) return false;
      final entry = read(key.toString());
      return entry != null && !entry.isYoungerThan(maxAge);
    }).toList();

    await _box.deleteAll(oldKeys);
  }
}
