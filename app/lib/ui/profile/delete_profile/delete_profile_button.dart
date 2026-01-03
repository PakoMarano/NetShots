import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:netshots/ui/profile/delete_profile/delete_profile_viewmodel.dart';

class DeleteProfileButton extends StatefulWidget {
  const DeleteProfileButton({super.key});

  @override
  State<DeleteProfileButton> createState() => _DeleteProfileButtonState();
}

class _DeleteProfileButtonState extends State<DeleteProfileButton> {
  DeleteProfileViewModel? _viewModel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel = Provider.of<DeleteProfileViewModel>(context, listen: false);
      _viewModel?.addListener(_onViewModelChanged);
    });
  }

  @override
  void dispose() {
    _viewModel?.removeListener(_onViewModelChanged);
    super.dispose();
  }

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

  void _onViewModelChanged() {
    if (!mounted || _viewModel == null) return;
    
    // Handle error message
    if (_viewModel!.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_viewModel!.errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
      _viewModel!.clearError();
    }
    
    // Handle navigation after successful deletion
    if (_viewModel!.isDeleted) {
      Navigator.pushReplacementNamed(context, '/create-profile');
    }
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
                    : () {
                        Navigator.of(context).pop(); // Close the dialog
                        Navigator.of(context).pop(); // Close the drawer
                        viewModel.deleteProfile();
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
