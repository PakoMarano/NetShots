import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:netshots/ui/home/settings/settings_viewmodel.dart';
import 'package:netshots/ui/profile/delete_profile/delete_profile_button.dart';

class SettingsDrawer extends StatelessWidget {
  const SettingsDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Consumer<SettingsViewModel>(
        builder: (context, viewModel, _) {
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      Icons.settings,
                      color: Colors.white,
                      size: 40,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Impostazioni',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('Notifiche'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement notifications screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Funzionalità in arrivo!')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip),
                title: const Text('Privacy'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement privacy screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Funzionalità in arrivo!')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.help),
                title: const Text('Aiuto'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement help screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Funzionalità in arrivo!')),
                  );
                },
              ),
              const Divider(),
              const DeleteProfileButton(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.orange),
                title: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.orange),
                ),
                onTap: () => _showLogoutDialog(context, viewModel),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, SettingsViewModel viewModel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Sei sicuro di voler uscire?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annulla'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pop(); // Close the drawer
                
                await viewModel.logout();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.orange,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
