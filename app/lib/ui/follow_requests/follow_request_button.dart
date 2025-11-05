import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'follow_request_viewmodel.dart';
import 'follow_requests_screen.dart';

class FollowRequestButton extends StatelessWidget {
  const FollowRequestButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FollowRequestViewModel>(
      builder: (context, viewModel, _) {
        return Stack(
          children: [
            IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const FollowRequestsScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.person_add_outlined),
              tooltip: 'Richieste di Follow',
            ),
            // Badge for notification count
            if (viewModel.hasRequests)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    '${viewModel.requestCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
