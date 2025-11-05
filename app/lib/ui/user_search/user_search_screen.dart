import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'user_search_viewmodel.dart';
import 'user_search_bar.dart';

class UserSearchScreen extends StatelessWidget {
  const UserSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cerca Utenti'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search bar
            const UserSearchBar(),
            const SizedBox(height: 16),
            // Results
            Expanded(
              child: Consumer<UserSearchViewModel>(
                builder: (context, viewModel, _) {
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

                  if (viewModel.isSearching) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

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
                        title: Text(user),
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
}
