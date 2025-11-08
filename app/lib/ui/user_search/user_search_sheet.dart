import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'user_search_viewmodel.dart';
import 'user_search_bar.dart';

class UserSearchScreen extends StatelessWidget {
  final bool autoFocus;

  const UserSearchScreen({super.key, this.autoFocus = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Top drag handle (no app bar in bottom sheet)
            const SizedBox(height: 8),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Search bar
            UserSearchBar(autoFocus: autoFocus),
            const SizedBox(height: 16),
            // Results
            Expanded(
              child: Consumer<UserSearchViewModel>(
                builder: (context, viewModel, _) {
                  // If the user hasn't typed anything yet, prompt them.
                  if (viewModel.isEmpty) {
                    return const Center(
                      child: Text(
                        'Inizia a digitare per cercare utenti',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }

                  // If a search is running but we already have previous results, keep
                  // showing them and only show a small inline indicator in the search
                  // bar. Only show a full-screen spinner when we have no results yet.
                  if (viewModel.isSearching && !viewModel.hasResults) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  // If the search finished and we have no results, show empty state.
                  if (!viewModel.hasResults) {
                    return const Center(
                      child: Text(
                        'Nessun utente trovato',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }

                  // Otherwise show the result list. While a new search runs this list
                  // remains visible (better UX than replacing it with a spinner).
                  return ListView.separated(
                    itemCount: viewModel.searchResults.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final user = viewModel.searchResults[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey.shade300,
                          child: Icon(
                            Icons.person,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        title: _buildHighlightedText(user, viewModel.searchQuery, context),
                        subtitle: Text('@${user.toLowerCase().replaceAll(' ', '')}'),
                        trailing: ElevatedButton(
                          onPressed: () {
                            // TODO: Implement follow functionality
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          child: const Text('Segui'),
                        ),
                        onTap: () {
                          // TODO: Navigate to user profile
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightedText(String text, String query, BuildContext context) {
    if (query.isEmpty) return Text(text);

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final start = lowerText.indexOf(lowerQuery);
    if (start == -1) return Text(text);
    final end = start + query.length;

    final baseStyle = Theme.of(context).textTheme.titleMedium ?? const TextStyle(fontSize: 16);
    final highlightStyle = baseStyle.copyWith(fontWeight: FontWeight.bold);

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(text: text.substring(0, start), style: baseStyle),
          TextSpan(text: text.substring(start, end), style: highlightStyle),
          TextSpan(text: text.substring(end), style: baseStyle),
        ],
      ),
    );
  }
}

