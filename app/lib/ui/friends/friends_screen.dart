import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:netshots/ui/user_search/user_search_bar.dart';
import 'friends_viewmodel.dart';

class FriendsScreen extends StatelessWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<FriendsViewModel>(
      create: (_) => FriendsViewModel(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search bar at the top of the friends screen
            const UserSearchBar(),
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
        ),
      ),
    );
  }
}
