import 'package:netshots/data/services/search/search_service_mock.dart';

class SearchRepository {
  final MockSearchService _searchService;

  SearchRepository(this._searchService);

  Future<List<String>> searchUsers(String query) async {
    return await _searchService.searchUsers(query);
  }
}
