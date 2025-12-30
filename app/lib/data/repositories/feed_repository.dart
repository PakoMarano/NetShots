import 'package:netshots/data/services/feed/feed_service_interface.dart';
import 'package:netshots/data/models/feed_item_model.dart';

class FeedRepository {
  final FeedServiceInterface _feedService;

  FeedRepository(this._feedService);

  /// Get feed items from followed users
  /// [limit] - Maximum number of items to return
  /// [offset] - Number of items to skip for pagination
  Future<List<FeedItem>> getFeed({int? limit, int? offset}) async {
    final feedData = await _feedService.getFeed(limit: limit, offset: offset);
    return feedData.map((item) => FeedItem.fromMap(item)).toList();
  }
}
