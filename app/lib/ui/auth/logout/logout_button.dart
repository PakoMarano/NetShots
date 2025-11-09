import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:netshots/ui/auth/logout/logout_viewmodel.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LogoutViewModel>(
      builder: (context, viewModel, _) {
        return ElevatedButton(
          onPressed: viewModel.isLoggingOut
              ? null
              : () async {
                  await viewModel.logout();
                  if (!context.mounted) return;
                  // Clear the navigation stack and go to login to avoid stale routes
                  Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil('/login', (route) => false);
                },
          child: viewModel.isLoggingOut
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Logout'),
        );
      },
    );
  }
}