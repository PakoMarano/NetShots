import 'package:netshots/data/models/search_user_model.dart';

abstract class SearchServiceInterface {
  Future<List<SearchUser>> searchUsers(String query);
}
