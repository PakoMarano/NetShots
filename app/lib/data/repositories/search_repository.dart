import 'package:netshots/data/services/search/search_service_mock.dart';
import 'package:netshots/data/models/search_user_model.dart';

class SearchRepository {
  final MockSearchService _searchService;

  SearchRepository(this._searchService);

  Future<List<SearchUser>> searchUsers(String query) async {
    return await _searchService.searchUsers(query);
  }
}
