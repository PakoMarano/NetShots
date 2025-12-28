import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:netshots/ui/profile/create_profile/create_profile_viewmodel.dart';
import 'package:netshots/data/models/user_profile_model.dart';

class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  DateTime? _selectedBirthDate;
  Gender _selectedGender = Gender.male;
  CreateProfileViewModel? _viewModel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel = Provider.of<CreateProfileViewModel>(context, listen: false);
      _viewModel?.addListener(_onViewModelChanged);
    });
  }

  @override
  void dispose() {
    _viewModel?.removeListener(_onViewModelChanged);
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Completa il tuo profilo'),
        automaticallyImplyLeading: false, // Disable back navigation
      ),
      body: SafeArea(
        child: Consumer<CreateProfileViewModel>(
          builder: (context, viewModel, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 30),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: "Nome",
                      border: OutlineInputBorder(),
                    ),
                    controller: _firstNameController,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: const InputDecoration(
                      labelText: "Cognome",
                      border: OutlineInputBorder(),
                    ),
                    controller: _lastNameController,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () => _selectBirthDate(context),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: "Data di nascita",
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        _selectedBirthDate != null
                            ? "${_selectedBirthDate!.day}/${_selectedBirthDate!.month}/${_selectedBirthDate!.year}"
                            : "Seleziona data di nascita",
                        style: TextStyle(
                          color: _selectedBirthDate != null 
                              ? Theme.of(context).textTheme.bodyLarge?.color
                              : Theme.of(context).hintColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<Gender>(
                    decoration: const InputDecoration(
                      labelText: "Genere",
                      border: OutlineInputBorder(),
                    ),
                    initialValue: _selectedGender,
                    items: const [
                      DropdownMenuItem(value: Gender.male, child: Text('Maschio')),
                      DropdownMenuItem(value: Gender.female, child: Text('Femmina')),
                      DropdownMenuItem(value: Gender.other, child: Text('Altro')),
                    ],
                    onChanged: (Gender? value) {
                      if (value != null) {
                        setState(() {
                          _selectedGender = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: viewModel.isLoading ? null : () {
                      if (!_validateInputs(context)) return;
                      viewModel.createProfile(
                        _firstNameController.text.trim(),
                        _lastNameController.text.trim(),
                        _selectedBirthDate!,
                        _selectedGender,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: viewModel.isLoading 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          "Completa Profilo",
                          style: TextStyle(fontSize: 16),
                        ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          }
        ),
      ),
    );
  }

  void _onViewModelChanged() {
    if (!mounted || _viewModel == null) return;
    
    // Handle error message
    if (_viewModel!.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_viewModel!.errorMessage!))
      );
      _viewModel!.clearError();
    }
    
    // Handle navigation
    if (_viewModel!.isProfileCreated) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  Future<void> _selectBirthDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime initialDate = DateTime(now.year - 20, now.month, now.day);
    final DateTime firstDate = DateTime(now.year - 100);
    final DateTime lastDate = DateTime(now.year - 16); // Età minima 16 anni

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      locale: const Locale('it', 'IT'),
      helpText: 'Seleziona la tua data di nascita',
      cancelText: 'Annulla',
      confirmText: 'Conferma',
    );

    if (picked != null && picked != _selectedBirthDate) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  bool _validateInputs(BuildContext context) {
    // Check if all fields are filled
    if (_firstNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Inserisci il nome"))
      );
      return false;
    }
    
    if (_lastNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Inserisci il cognome"))
      );
      return false;
    }
    
    if (_selectedBirthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Seleziona la data di nascita"))
      );
      return false;
    }
    
    // Check if the user is at least 16 years old
    final now = DateTime.now();
    final age = now.year - _selectedBirthDate!.year;
    if (age < 16) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Devi avere almeno 16 anni"))
      );
      return false;
    }
    
    return true;
  }
}
