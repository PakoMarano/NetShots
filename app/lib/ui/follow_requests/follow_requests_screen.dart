import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'follow_request_viewmodel.dart';

class FollowRequestsScreen extends StatelessWidget {
  const FollowRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Richieste di Follow'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Consumer<FollowRequestViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!viewModel.hasRequests) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Nessuna richiesta',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Non hai richieste di follow pendenti',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: viewModel.refreshRequests,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: viewModel.followRequests.length,
              itemBuilder: (context, index) {
                final request = viewModel.followRequests[index];
                return _buildRequestCard(context, request, viewModel);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context, FollowRequest request, FollowRequestViewModel viewModel) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Profile picture
            CircleAvatar(
              radius: 24,
              backgroundImage: request.profilePicture != null
                  ? NetworkImage(request.profilePicture!)
                  : null,
              child: request.profilePicture == null
                  ? const Icon(Icons.person, size: 24)
                  : null,
            ),
            const SizedBox(width: 12),
            // User info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request.fullName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Richiesta inviata ${_formatDate(request.requestDate)}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // Action buttons
            Row(
              children: [
                // Reject button
                IconButton(
                  onPressed: viewModel.isLoading 
                      ? null 
                      : () => _showRejectDialog(context, request, viewModel),
                  icon: const Icon(Icons.close),
                  color: Colors.red,
                  tooltip: 'Rifiuta',
                ),
                // Accept button
                IconButton(
                  onPressed: viewModel.isLoading 
                      ? null 
                      : () => _showAcceptDialog(context, request, viewModel),
                  icon: const Icon(Icons.check),
                  color: Colors.green,
                  tooltip: 'Accetta',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} giorni fa';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ore fa';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minuti fa';
    } else {
      return 'Ora';
    }
  }

  void _showAcceptDialog(BuildContext context, FollowRequest request, FollowRequestViewModel viewModel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Accetta richiesta'),
          content: Text('Vuoi accettare la richiesta di follow di ${request.fullName}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annulla'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                viewModel.acceptFollowRequest(request.userId);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Richiesta di ${request.fullName} accettata'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Accetta'),
            ),
          ],
        );
      },
    );
  }

  void _showRejectDialog(BuildContext context, FollowRequest request, FollowRequestViewModel viewModel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Rifiuta richiesta'),
          content: Text('Vuoi rifiutare la richiesta di follow di ${request.fullName}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annulla'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                viewModel.rejectFollowRequest(request.userId);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Richiesta di ${request.fullName} rifiutata'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Rifiuta'),
            ),
          ],
        );
      },
    );
  }
}
