import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:netshots/ui/auth/register/register_viewmodel.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  RegisterViewModel? _viewModel; 
  
  @override
  void initState() {
    super.initState();
    // Initialize the view model and set a listener for changes
    // This will allow us to handle navigation and state changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel = Provider.of<RegisterViewModel>(context, listen: false);
      _viewModel?.addListener(_onViewModelChanged);
    });
  }

  @override
  void dispose() {
    _viewModel?.removeListener(_onViewModelChanged);
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registrati")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Consumer<RegisterViewModel>(
          builder: (context, viewModel, _) {
            return Column(
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: "Email"),
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: "Password"),
                  controller: _passwordController,
                  obscureText: true,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: "Conferma Password"),
                  controller: _confirmPasswordController,
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: viewModel.isLoading ? null : () {
                    if (!_validateInputs(context)) return;
                    viewModel.register(_emailController.text, _passwordController.text);
                  },
                  child: viewModel.isLoading 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Registrati"),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                  child: const Text("Hai già un account? Accedi"),
                ),
              ],
            );
          },
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
    if (_viewModel!.isRegistrationSuccessful) {
      Navigator.pushReplacementNamed(context, '/create-profile');
    }
  }

  bool _validateInputs(BuildContext context) {
    // Check if all fields are filled
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty || _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tutti i campi sono obbligatori"))
      );
      return false;
    }
    // Check if passwords match
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Le password non corrispondono"))
      );
      return false;
    }
    // Check if email is valid
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(_emailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email non valida"))
      );
      return false;
    }
    // Check if password is strong enough
    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("La password deve essere di almeno 6 caratteri"))
      );
      return false;
    }
    return true;
  }
}