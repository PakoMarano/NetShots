import 'package:flutter/material.dart';
import 'package:netshots/ui/profile/stats/stats_screen.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:netshots/ui/profile/profile_screen/profile_viewmodel.dart';
import 'package:netshots/data/models/user_profile_model.dart';
import 'package:netshots/data/models/match_model.dart';
import 'package:netshots/ui/core/widgets/match_image_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Load the user profile only if it's not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<ProfileViewModel>(context, listen: false);
      if (viewModel.isEmpty && !viewModel.isLoading) {
        viewModel.loadUserProfile();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileViewModel>(
      builder: (context, viewModel, _) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        final userProfile = viewModel.userProfile;
        if (userProfile == null) {
          return const Center(child: Text('Nessun profilo trovato'));
        }
  // Derive gallery images and matches from view model
  final pictures = viewModel.gallery;
  final matches = viewModel.galleryMatches;

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // Top section as a sliver (header)
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
                          _buildTopSection(userProfile),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // If no pictures, show a friendly empty state filling remaining space
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
                // Photos as a vertical feed (one per row)
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      // Prefer the full MatchModel so we can show notes; fallback to picture string
                      if (index < matches.length) {
                        final MatchModel match = matches[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                          child: _buildPhotoWithNote(match, index, isVictory: match.isVictory),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                    childCount: pictures.length,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
  Widget _buildTopSection(UserProfile userProfile) {
    return Column(
      children: [
        // Profile picture and stats row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile picture (center)
            Stack(
              children: [
                Container(
                  width: 85,
                  height: 85,
                  decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  image: userProfile.profilePicture != null && userProfile.profilePicture!.isNotEmpty
                      ? DecorationImage(
                          image: _getImageProvider(userProfile.profilePicture!),
                          fit: BoxFit.cover,
                        )
                      : const DecorationImage(
                          image: AssetImage('assets/default_image_profile.jpg'),
                          fit: BoxFit.cover,
                        ),
                  ),
                ),
                // Edit button — opens options to change/remove profile picture or modify profile
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => _showProfilePictureOptions(userProfile),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).primaryColor,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(50),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.edit,
                        color: Theme.of(context).primaryColor,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            _buildStatColumn(_formatCount(userProfile.totalMatches), 'Giocate'),
            _buildStatColumn(_formatCount(userProfile.victories), 'Vittorie', countColor: Colors.green),
            _buildStatColumn(_formatCount(userProfile.losses), 'Sconfitte', countColor: Colors.red),
          ],
        ),
        const SizedBox(height: 16),
        // Name and stats icon aligned horizontally
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StatsScreen(userId: userProfile.userId)),
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
              '${userProfile.firstName} ${userProfile.lastName}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Helper method for stats columns
  Widget _buildStatColumn(String count, String label, {Color? countColor}) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: countColor ?? Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  /// Format large counts into human-readable strings (e.g. 1.2k, 3.4M)
  String _formatCount(int value) {
    if (value < 1000) return value.toString();
    if (value < 1000000) {
      final double v = value / 1000.0;
      // Show one decimal only when needed
      final s = (v % 1 == 0) ? v.toInt().toString() : v.toStringAsFixed(1);
      return '${s}k';
    }
    final double v = value / 1000000.0;
    final s = (v % 1 == 0) ? v.toInt().toString() : v.toStringAsFixed(1);
    return '${s}M';
  }

  Widget _buildPhotoWithNote(MatchModel match, int index, {bool? isVictory}) {
    return MatchImageCard(
      match: match,
      index: index,
      onTap: () => _selectImage(index),
      onDelete: () => _removeImage(index, Provider.of<ProfileViewModel>(context, listen: false)),
    );
  }

  Future<void> _selectImage(int index) async {
    final viewModel = Provider.of<ProfileViewModel>(context, listen: false);
    final userProfile = viewModel.userProfile;
    
    if (userProfile == null) return;
    
    // Show bottom sheet to allow removal
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Rimuovi Foto', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.of(context).pop();
                  _removeImage(index, viewModel);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showProfilePictureOptions(UserProfile userProfile) {
    final viewModel = Provider.of<ProfileViewModel>(context, listen: false);

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Aggiungi Foto Profilo da Galleria'),
                onTap: () async {
                  await _pickProfileImage(ImageSource.gallery, viewModel);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Scatta Foto Profilo'),
                onTap: () async {
                  await _pickProfileImage(ImageSource.camera, viewModel);
                },
              ),
              if (userProfile.profilePicture != null && userProfile.profilePicture!.isNotEmpty) ...[
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Rimuovi Foto Profilo', style: TextStyle(color: Colors.red)),
                  onTap: () async {
                    // Close the bottom sheet first (use the sheet's context)
                    Navigator.of(context).pop();
                    try {
                      await viewModel.removeProfilePicture();
                      if (!mounted) return;
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(content: Text('Foto profilo rimossa'), backgroundColor: Colors.orange),
                      );
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        SnackBar(content: Text('Errore nella rimozione della foto profilo: $e'), backgroundColor: Colors.red),
                      );
                    }
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickProfileImage(ImageSource source, ProfileViewModel viewModel) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        await viewModel.setProfilePicture(image.path);
        if (!mounted) return;
        // Close the sheet then show confirmation
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto profilo aggiornata'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore nell\'aggiornare la foto profilo: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _removeImage(int index, ProfileViewModel viewModel) {
    viewModel.removePicture(index);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Foto rimossa'),
        backgroundColor: Colors.orange,
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
