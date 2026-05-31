import 'package:flutter/material.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/theme/app_theme.dart';

import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  String _selectedRole = 'Traveler';

  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.register(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        roleType: _selectedRole,
      );

      if (authProvider.errorMessage == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Account created! Please sign in."), backgroundColor: AppTheme.primaryColor),
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(authProvider.errorMessage!), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Create Account",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 30),
                const Text("Join as a:"),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _roleOption("Traveler"),
                    const SizedBox(width: 20),
                    _roleOption("Guide"),
                  ],
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: "First Name",
                        controller: _firstNameController,
                        validator: (val) => val != null && val.isNotEmpty ? null : "Required",
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: CustomTextField(
                        label: "Last Name",
                        controller: _lastNameController,
                        validator: (val) => val != null && val.isNotEmpty ? null : "Required",
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  label: "Email",
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) => val != null && val.contains('@') ? null : "Invalid email",
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  label: "Password",
                  controller: _passwordController,
                  isPassword: true,
                  validator: (val) => val != null && val.length >= 6 ? null : "Min 6 chars",
                ),
                const SizedBox(height: 40),
                CustomButton(
                  text: "SIGN UP",
                  isLoading: authProvider.isLoading,
                  onPressed: _handleRegister,
                ),
                const SizedBox(height: 30),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Already have an account? Sign In"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _roleOption(String role) {
    bool isSelected = _selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRole = role),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor : Colors.white,
            border: Border.all(color: AppTheme.primaryColor),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(
            role,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
