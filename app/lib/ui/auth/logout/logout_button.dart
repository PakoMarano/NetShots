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
          onPressed: () async {
            await viewModel.logout();
            if (!context.mounted) return;
            Navigator.pushReplacementNamed(context, '/login');
          },
          child: const Text('Logout'),
        );
      },
    );
  }
}