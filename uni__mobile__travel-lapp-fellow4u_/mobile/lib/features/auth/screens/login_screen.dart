import 'package:flutter/material.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/theme/app_theme.dart';

import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!mounted) return;

      if (authProvider.isAuthenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login successful!"), backgroundColor: AppTheme.primaryColor),
        );
        Navigator.of(context).pushReplacementNamed('/explore');
      } else if (authProvider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authProvider.errorMessage!), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50),
                Text(
                  "Sign In",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 10),
                const Text("Welcome back, please sign in to continue."),
                const SizedBox(height: 50),
                CustomTextField(
                  label: "Email",
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: (val) => val != null && val.contains('@') ? null : "Enter a valid email",
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  label: "Password",
                  controller: _passwordController,
                  isPassword: true,
                  prefixIcon: Icons.lock_outline,
                  validator: (val) => val != null && val.length >= 6 ? null : "Password too short",
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
                    child: const Text("Forgot Password?"),
                  ),
                ),
                const SizedBox(height: 30),
                CustomButton(
                  text: "SIGN IN",
                  isLoading: authProvider.isLoading,
                  onPressed: _handleLogin,
                ),
                const SizedBox(height: 30),
                Row(
                  children: const [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text("Or sign in with"),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _socialButton(Icons.facebook, Colors.blue),
                    _socialButton(Icons.chat_bubble, Colors.yellow[700]!), // KakaoTalk color
                    _socialButton(Icons.textsms, Colors.green), // Line color
                  ],
                ),
                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/register'),
                      child: const Text("Sign Up"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _socialButton(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(icon, color: color, size: 30),
    );
  }
}
