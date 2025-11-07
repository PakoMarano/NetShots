import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:netshots/ui/user_search/user_search_bar.dart';
import 'friends_viewmodel.dart';

class FriendsScreen extends StatelessWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FriendsViewModel>(
      builder: (context, viewModel, _) {
        return Column(
          children: [
            // Top primary-color container similar to Profile screen
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
                    children: const [
                      SizedBox(height: 12),
                      UserSearchBar(),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Placeholder content
            Expanded(
              child: Center(
                child: Text(
                  'Sezione Amici - in costruzione',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
