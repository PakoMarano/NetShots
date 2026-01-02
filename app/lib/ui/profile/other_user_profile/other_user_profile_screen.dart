import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:netshots/data/models/match_model.dart';
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
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 55,
                              backgroundColor: Colors.grey.shade300,
                              backgroundImage: userProfile.profilePicture != null && userProfile.profilePicture!.isNotEmpty
                                  ? _getImageProvider(userProfile.profilePicture!)
                                  : null,
                              child: userProfile.profilePicture == null || userProfile.profilePicture!.isEmpty
                                  ? Icon(Icons.person, size: 54, color: Colors.grey.shade600)
                                  : null,
                            ),
                            const SizedBox(height: 14),
                            Text(
                              userProfile.fullName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${userProfile.age} anni',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildStatColumn(_formatCount(userProfile.totalMatches), 'Giocate', color: Colors.white),
                                _buildStatColumn(_formatCount(userProfile.victories), 'Vittorie', color: Colors.greenAccent),
                                _buildStatColumn(_formatCount(userProfile.losses), 'Sconfitte', color: Colors.redAccent),
                              ],
                            ),
                            const SizedBox(height: 16),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hasLocation = match?.latitude != null && match?.longitude != null;

    return Card(
      elevation: isDark ? 3 : 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: theme.colorScheme.surface,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 320,
          decoration: BoxDecoration(
            border: Border.all(color: isDark ? Colors.white10 : Colors.grey.shade300),
            image: DecorationImage(
              image: _getImageProvider(photoUrl),
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
          child: hasLocation
              ? Stack(
                  children: [
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: GestureDetector(
                          onTap: () => _launchMap(context, match!.latitude!, match.longitude!),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : null,
        ),
      ),
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

  Future<void> _launchMap(BuildContext context, double latitude, double longitude) async {
    try {
      final url = Uri.parse('geo:$latitude,$longitude');
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossibile aprire la mappa')),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore nell\'apertura della mappa: $e')),
      );
    }
  }
}
