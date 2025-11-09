import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:netshots/ui/follow/follow_viewmodel.dart';

class FollowButton extends StatelessWidget {
  final String targetId;
  final String displayName;

  const FollowButton({super.key, required this.targetId, required this.displayName});

  @override
  Widget build(BuildContext context) {
  final vm = Provider.of<FollowViewModel>(context);
  final isFollowing = vm.isFollowing(targetId);
  final isLoading = vm.isLoading(targetId);

    final primary = Theme.of(context).primaryColor;
    return ElevatedButton(
      onPressed: isLoading
          ? null
          : () async {
              final messenger = ScaffoldMessenger.of(context);
              try {
                await vm.toggleFollow(targetId);
              } catch (e) {
                messenger.showSnackBar(SnackBar(content: Text('Errore: Impossibile aggiornare follow: $e')));
              }
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: isFollowing ? Colors.grey.shade200 : primary,
        foregroundColor: isFollowing ? Colors.black87 : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: isLoading
          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
          : Text(isFollowing ? 'Seguito' : 'Segui'),
    );
  }
}
