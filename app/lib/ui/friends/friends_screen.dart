import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:netshots/ui/user_search/user_search_bar.dart';
import 'package:netshots/ui/user_search/user_search_sheet.dart';
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
                    children: [
                      const SizedBox(height: 12),
                      UserSearchBar(
                        onTap: () async {
                          // When tapped, open the search UI in a modal bottom sheet
                          // so results are visible without leaving the current flow.
                          final height = MediaQuery.of(context).size.height * 0.75;
                          await showModalBottomSheet<void>(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) {
                              return SizedBox(
                                height: height,
                                child: const UserSearchScreen(autoFocus: true),
                              );
                            },
                          );

                          if (!context.mounted) return;

                          // When the sheet closes (by dragging down or tapping outside),
                          // ensure the keyboard is dismissed / search field is unfocused.
                          try {
                            FocusScope.of(context).unfocus();
                            // Extra force-hide for the keyboard to cover edge cases
                            // where focus lingers inside the sheet's state.
                            SystemChannels.textInput.invokeMethod('TextInput.hide');
                          } catch (_) {
                            // Ignore any errors during cleanup.
                          }
                        },
                      ),
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
