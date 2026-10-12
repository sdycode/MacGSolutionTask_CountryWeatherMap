abstract interface class FavoritesRepository {
  Set<String> get favorites;

  Stream<Set<String>> get changes;

  Future<bool> toggle(String code);

  Future<void> clear();
}
