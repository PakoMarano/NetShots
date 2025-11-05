import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:netshots/ui/profile/delete_profile/delete_profile_viewmodel.dart';

class DeleteProfileButton extends StatelessWidget {
  const DeleteProfileButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DeleteProfileViewModel>(
      builder: (context, viewModel, _) {
        return ListTile(
          leading: Icon(Icons.delete, color: Colors.red[700]),
          title: Text(
            'Elimina Profilo',
            style: TextStyle(color: Colors.red[700]),
          ),
          enabled: !viewModel.isDeleting,
          onTap: () => _showDeleteConfirmationDialog(context, viewModel),
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, DeleteProfileViewModel viewModel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Elimina Profilo'),
          content: const Text(
            'Sei sicuro di voler eliminare il tuo profilo? Questa azione non può essere annullata e perderai tutti i tuoi dati.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annulla'),
            ),
            Consumer<DeleteProfileViewModel>(
              builder: (context, viewModel, _) {
                return TextButton(
                  onPressed: viewModel.isDeleting 
                    ? null 
                    : () async {
                        Navigator.of(context).pop(); // Close the dialog
                        Navigator.of(context).pop(); // Close the drawer
                        
                        final success = await viewModel.deleteProfile();
                        if (context.mounted && success) {
                          // After deleting the profile, go back to create profile screen
                          Navigator.pushReplacementNamed(context, '/create-profile');
                        } else if (context.mounted) {
                          // Show error message if deletion failed
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Errore durante l\'eliminazione del profilo'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  child: viewModel.isDeleting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                        ),
                      )
                    : const Text('Elimina'),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
