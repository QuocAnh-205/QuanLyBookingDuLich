import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/providers/auth_provider.dart';
import '../provider/profile_provider.dart';
import 'change_password_screen.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileProvider>().profile;
    _firstNameController = TextEditingController(text: profile?.firstName ?? '');
    _lastNameController = TextEditingController(text: profile?.lastName ?? '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      final token = context.read<AuthProvider>().token;
      if (token == null) return;

      final success = await context.read<ProfileProvider>().updateProfile({
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
      }, token);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.read<ProfileProvider>().error ?? 'Update failed')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<ProfileProvider>().isLoading;
    final user = context.watch<ProfileProvider>().profile;

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
          'Edit Profile',
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
              // Avatar with camera icon
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(user?.avatarUrl ?? 'https://via.placeholder.com/150'),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFF00CEA6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              // Side-by-side names
              Row(
                children: [
                  Expanded(child: _buildUnderlineField('First Name', _firstNameController)),
                  const SizedBox(width: 24),
                  Expanded(child: _buildUnderlineField('Last Name', _lastNameController)),
                ],
              ),
              const SizedBox(height: 32),
              // Password field
              const Text(
                'Password',
                style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextField(
                obscureText: _obscurePassword,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: '••••••',
                  hintStyle: const TextStyle(color: Colors.black, fontSize: 16, letterSpacing: 2),
                  enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF00CEA6))),
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
                  );
                },
                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                child: const Text(
                  'Change Password',
                  style: TextStyle(color: Color(0xFF00CEA6), fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnderlineField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        TextFormField(
          controller: controller,
          decoration: const InputDecoration(
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF00CEA6))),
            contentPadding: EdgeInsets.symmetric(vertical: 8),
          ),
          validator: (value) => value == null || value.isEmpty ? 'Required' : null,
        ),
      ],
    );
  }
}
