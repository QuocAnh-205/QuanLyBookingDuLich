import 'package:flutter/material.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/theme/app_theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isSent = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isSent ? "Check Email" : "Forgot Password",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 20),
              Text(
                _isSent 
                ? "We have sent a password recover instruction to your email."
                : "Enter your email address to receive instructions on how to reset your password.",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 50),
              if (!_isSent) ...[
                CustomTextField(
                  label: "Email Address",
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                ),
                const SizedBox(height: 40),
                CustomButton(
                  text: "SEND INSTRUCTIONS",
                  onPressed: () {
                    setState(() => _isSent = true);
                  },
                ),
              ] else ...[
                Center(
                  child: Icon(Icons.mark_email_read_outlined, size: 100, color: AppTheme.primaryColor),
                ),
                const SizedBox(height: 50),
                CustomButton(
                  text: "BACK TO LOGIN",
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
