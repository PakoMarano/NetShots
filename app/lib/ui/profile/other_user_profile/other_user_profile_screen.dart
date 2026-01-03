import 'dart:io';

import 'package:flutter/material.dart';
import 'package:netshots/ui/profile/stats/stats_screen.dart';
import 'package:provider/provider.dart';
import 'package:netshots/data/models/match_model.dart';
import 'package:netshots/ui/core/widgets/match_image_card.dart';
import 'other_user_profile_viewmodel.dart';
import 'package:netshots/data/repositories/profile_repository.dart';
import 'package:netshots/data/repositories/match_repository.dart';
import 'package:netshots/ui/follow/follow_button.dart';


class OtherUserProfileScreen extends StatelessWidget {
  final String userId;
  final String displayName;

  const OtherUserProfileScreen({
    super.key,
    required this.userId,
    required this.displayName,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final profileRepo = Provider.of<ProfileRepository>(context, listen: false);
        final matchRepo = Provider.of<MatchRepository>(context, listen: false);
        final viewModel = OtherUserProfileViewModel(profileRepo, matchRepo, userId);
        viewModel.loadUserProfile();
        return viewModel;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(displayName),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
        ),
        body: Consumer<OtherUserProfileViewModel>(
          builder: (context, viewModel, _) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.errorMessage != null) {
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
                      onPressed: () => viewModel.loadUserProfile(),
                      child: const Text('Riprova'),
                    ),
                  ],
                ),
              );
            }

            final userProfile = viewModel.userProfile;
            if (userProfile == null) {
              return const Center(child: Text('Profilo non trovato'));
            }

            final pictures = viewModel.pictures;

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
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
                            // Profile picture and stats row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Profile picture (center)
                                CircleAvatar(
                                  radius: 42.5,
                                  backgroundColor: Colors.white,
                                  child: CircleAvatar(
                                    radius: 40,
                                    backgroundColor: Colors.grey.shade300,
                                    backgroundImage: userProfile.profilePicture != null && userProfile.profilePicture!.isNotEmpty
                                        ? _getImageProvider(userProfile.profilePicture!)
                                        : null,
                                    child: userProfile.profilePicture == null || userProfile.profilePicture!.isEmpty
                                        ? Icon(Icons.person, size: 40, color: Colors.grey.shade600)
                                        : null,
                                  ),
                                ),
                                _buildStatColumn(_formatCount(userProfile.totalMatches), 'Giocate', color: Colors.white),
                                _buildStatColumn(_formatCount(userProfile.victories), 'Vittorie', color: Colors.greenAccent),
                                _buildStatColumn(_formatCount(userProfile.losses), 'Sconfitte', color: Colors.redAccent),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Name, age, and stats icon
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => StatsScreen(userId: userId)),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.white, width: 1.5),
                                        ),
                                        child: const Icon(
                                          Icons.show_chart,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      userProfile.fullName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${userProfile.age} anni',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            FollowButton(
                              targetId: userId,
                              displayName: userProfile.fullName,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (pictures.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 12.0),
                      child: Center(
                        child: Text(
                          'Non ci sono ancora foto di partite.',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                        ),
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final photoUrl = pictures[index];
                        final matches = viewModel.pictureMatches[photoUrl] ?? [];
                        final match = matches.isNotEmpty ? matches.first : null;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                          child: _buildPhotoCard(context, photoUrl, match),
                        );
                      },
                      childCount: pictures.length,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatColumn(String value, String label, {Color? color}) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: color ?? Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoCard(BuildContext context, String photoUrl, MatchModel? match) {
    if (match == null) {
      // Fallback: Simple image container matching MatchImageCard height
      return Card(
        elevation: Theme.of(context).brightness == Brightness.dark ? 3 : 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Theme.of(context).colorScheme.surface,
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
          child: Container(
            height: 320,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: _getImageProvider(photoUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      );
    }

    return MatchImageCard(
      match: match,
      index: 0,
      onTap: () {
        // Navigate to full match details if needed
      },
    );
  }

  String _formatCount(int value) {
    if (value < 1000) return value.toString();
    if (value < 1000000) {
      final double v = value / 1000.0;
      final s = (v % 1 == 0) ? v.toInt().toString() : v.toStringAsFixed(1);
      return '${s}k';
    }
    final double v = value / 1000000.0;
    final s = (v % 1 == 0) ? v.toInt().toString() : v.toStringAsFixed(1);
    return '${s}M';
  }

  ImageProvider _getImageProvider(String imagePath) {
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return NetworkImage(imagePath);
    }
    return FileImage(File(imagePath));
  }
}
