import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/providers/auth_provider.dart';
import '../provider/profile_provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _retypePasswordController = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureRetype = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _retypePasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      if (_newPasswordController.text != _retypePasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('New passwords do not match')),
        );
        return;
      }
      final token = context.read<AuthProvider>().token;
      if (token == null) return;

      final success = await context.read<ProfileProvider>().changePassword({
        'current_password': _currentPasswordController.text,
        'new_password': _newPasswordController.text,
      }, token);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password changed successfully')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.read<ProfileProvider>().error ?? 'Change password failed')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<ProfileProvider>().isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Change Password',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(right: 16),
                child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
              ),
            )
          else
            TextButton(
              onPressed: _handleSave,
              child: const Text(
                'SAVE',
                style: TextStyle(color: Color(0xFF00CEA6), fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPasswordField('Current Password', _currentPasswordController, _obscureCurrent, () {
                setState(() => _obscureCurrent = !_obscureCurrent);
              }),
              const SizedBox(height: 32),
              _buildPasswordField('New Password', _newPasswordController, _obscureNew, () {
                setState(() => _obscureNew = !_obscureNew);
              }),
              const SizedBox(height: 32),
              _buildPasswordField('Retype New Password', _retypePasswordController, _obscureRetype, () {
                setState(() => _obscureRetype = !_obscureRetype);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller, bool obscureText, VoidCallback onToggle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: '••••••',
            hintStyle: const TextStyle(color: Colors.black, fontSize: 16, letterSpacing: 2),
            enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF00CEA6))),
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
              ),
              onPressed: onToggle,
            ),
          ),
          validator: (value) => value == null || value.isEmpty ? 'Required' : null,
        ),
      ],
    );
  }
}
