import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:netshots/ui/auth/login/login_viewmodel.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  LoginViewModel? _viewModel;

  @override
  void initState() {
    super.initState();
    // Initialize the LoginViewModel and set a listener for changes
    // This will allow us to react to login success or failure
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel = Provider.of<LoginViewModel>(context, listen: false);
      _viewModel?.addListener(_onViewModelChanged);
    });
  }

  @override
  void dispose() {
    _viewModel?.removeListener(_onViewModelChanged);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Accedi")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Consumer<LoginViewModel>(
          builder: (context, viewModel, _) {
            return Column(
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: "Email"),
                  controller: _emailController,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: "Password"),
                  controller: _passwordController,
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: viewModel.isLoading ? null : () {
                    if (!_validateInputs(context)) return;
                    viewModel.login(_emailController.text, _passwordController.text);
                  },
                  child: viewModel.isLoading 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Accedi"),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/register'),
                  child: const Text("Non hai un account? Registrati"),
                ),
              ],
            );
          }
        ),
      ),
    );
  }

  void _onViewModelChanged() {
    if (!mounted) return;
    final viewModel = _viewModel;
    
    // Handle navigation
    if (viewModel?.isLoginSuccessful == true) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  bool _validateInputs(BuildContext context) {
    // Check if email and password are not empty
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email e password non possono essere vuoti"))
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
    return true;
  }
}

