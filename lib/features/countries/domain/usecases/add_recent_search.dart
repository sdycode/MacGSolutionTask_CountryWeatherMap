import '../repositories/recent_search_repository.dart';

class AddRecentSearch {
  AddRecentSearch(this._repository);

  static const maxItems = 5;

  final RecentSearchRepository _repository;

  Future<List<String>> call(String query) async {
    final name = query.trim();
    final current = await _repository.getAll();
    if (name.isEmpty) return current;

    final updated = [
      name,
      ...current.where((search) => search != name),
    ].take(maxItems).toList();

    await _repository.saveAll(updated);
    return updated;
  }
}
