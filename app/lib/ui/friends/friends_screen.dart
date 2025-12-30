import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:netshots/ui/user_search/user_search_bar.dart';
import 'package:netshots/ui/user_search/user_search_sheet.dart';
import 'package:netshots/ui/profile/other_user_profile/other_user_profile_screen.dart';
import 'package:intl/intl.dart';
import 'dart:io';
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
    final dateFormat = DateFormat('dd/MM/yyyy');
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
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
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        child: Card(
          elevation: isDark ? 3 : 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          color: theme.colorScheme.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // User info header
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: user.profilePicture != null && user.profilePicture!.isNotEmpty
                      ? _getImageProvider(user.profilePicture!)
                      : null,
                  child: user.profilePicture == null || user.profilePicture!.isEmpty
                      ? Icon(Icons.person, color: Colors.grey.shade600)
                      : null,
                ),
                title: Text(
                  user.displayName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              // Match image
              if (match.picture.isNotEmpty)
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  ),
                  child: Container(
                    height: 320,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: match.isVictory ? Colors.green : Colors.red,
                      ),
                      image: DecorationImage(
                        image: _getImageProvider(match.picture),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: isDark
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.6),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : null,
                    ),
                    child: Stack(
                      children: [
                        // Victory/loss badge (top-left)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: match.isVictory ? Colors.green : Colors.red,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              match.isVictory ? Icons.emoji_events : Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                        // Date label (bottom-left)
                        Positioned(
                          bottom: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              dateFormat.format(match.date),
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              // Match notes (if available)
              if (match.notes != null && match.notes!.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.03) : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.9),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                    ),
                  ),
                  child: Text(
                    match.notes!,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.95),
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper method to get the appropriate ImageProvider based on the image path
  ImageProvider _getImageProvider(String imagePath) {
    // Check if it's a network URL
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return NetworkImage(imagePath);
    }
    // Otherwise, it's a local file
    return FileImage(File(imagePath));
  }
}
