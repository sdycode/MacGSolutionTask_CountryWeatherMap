abstract interface class RecentSearchRepository {
  Future<List<String>> getAll();

  Future<void> saveAll(List<String> searches);

  Future<void> clear();
}
