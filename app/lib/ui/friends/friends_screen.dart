import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:netshots/ui/user_search/user_search_bar.dart';
import 'package:netshots/ui/user_search/user_search_sheet.dart';
import 'package:netshots/ui/profile/other_user_profile/other_user_profile_screen.dart';
import 'package:intl/intl.dart';
import 'friends_viewmodel.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load feed when screen is first displayed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<FriendsViewModel>(context, listen: false);
      if (viewModel.feedItems.isEmpty && !viewModel.isLoading) {
        viewModel.loadFeed();
      }
    });

    // Add scroll listener for pagination
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final viewModel = Provider.of<FriendsViewModel>(context, listen: false);
      viewModel.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FriendsViewModel>(
      builder: (context, viewModel, _) {
        return Column(
          children: [
            // Top primary-color container with search bar
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      UserSearchBar(
                        onTap: () async {
                          final height = MediaQuery.of(context).size.height * 0.75;
                          await showModalBottomSheet<void>(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) {
                              return SizedBox(
                                height: height,
                                child: const UserSearchScreen(autoFocus: true),
                              );
                            },
                          );

                          if (!context.mounted) return;

                          try {
                            FocusScope.of(context).unfocus();
                            SystemChannels.textInput.invokeMethod('TextInput.hide');
                          } catch (_) {
                            // Ignore any errors during cleanup.
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Feed content
            Expanded(
              child: _buildFeedContent(context, viewModel),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFeedContent(BuildContext context, FriendsViewModel viewModel) {
    // Initial loading state
    if (viewModel.isLoading && viewModel.feedItems.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Error state
    if (viewModel.errorMessage != null && viewModel.feedItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              viewModel.errorMessage!,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => viewModel.loadFeed(),
              child: const Text('Riprova'),
            ),
          ],
        ),
      );
    }

    // Empty state
    if (viewModel.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.photo_camera_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'Nessun contenuto',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Segui altri utenti per vedere i loro match nel feed',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Feed list with pull-to-refresh
    return RefreshIndicator(
      onRefresh: () => viewModel.refreshFeed(),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: viewModel.feedItems.length + (viewModel.isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == viewModel.feedItems.length) {
            // Loading indicator at bottom
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final feedItem = viewModel.feedItems[index];
          return _FeedItemCard(feedItem: feedItem);
        },
      ),
    );
  }
}

class _FeedItemCard extends StatelessWidget {
  final feedItem;

  const _FeedItemCard({required this.feedItem});

  @override
  Widget build(BuildContext context) {
    final match = feedItem.match;
    final user = feedItem.user;
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info header
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey.shade300,
              backgroundImage: user.profilePicture != null && user.profilePicture!.isNotEmpty
                  ? NetworkImage(user.profilePicture!)
                  : null,
              child: user.profilePicture == null || user.profilePicture!.isEmpty
                  ? Icon(Icons.person, color: Colors.grey.shade600)
                  : null,
            ),
            title: Text(
              user.displayName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(dateFormat.format(match.date)),
            trailing: Icon(
              match.isVictory ? Icons.emoji_events : Icons.sentiment_neutral,
              color: match.isVictory ? Colors.amber : Colors.grey,
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => OtherUserProfileScreen(
                    userId: user.userId,
                    displayName: user.displayName,
                  ),
                ),
              );
            },
          ),
          // Match image
          if (match.picture.isNotEmpty)
            GestureDetector(
              onTap: () {
                // Could open full screen image viewer
              },
              child: Image.network(
                match.picture,
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 300,
                    color: Colors.grey.shade300,
                    child: const Center(
                      child: Icon(Icons.broken_image, size: 64),
                    ),
                  );
                },
              ),
            ),
          // Match notes
          if (match.notes != null && match.notes!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                match.notes!,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          // Result indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: match.isVictory ? Colors.green.shade100 : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    match.isVictory ? 'Vittoria' : 'Sconfitta',
                    style: TextStyle(
                      color: match.isVictory ? Colors.green.shade800 : Colors.red.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
