import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/providers/auth_provider.dart';
import '../provider/profile_provider.dart';
import 'edit_profile_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _updateSetting(BuildContext context, Map<String, dynamic> data) async {
    final token = context.read<AuthProvider>().token;
    if (token == null) return;
    await context.read<ProfileProvider>().updateSettings(data, token);
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final user = profileProvider.profile;
    final settings = user?.settings;
    final isLoading = profileProvider.isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: isLoading && user == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                const SizedBox(height: 16),
                // Header Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00CEA6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(user?.avatarUrl ?? 'https://via.placeholder.com/150'),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.fullName ?? 'User Name',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'Traveler',
                              style: TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('EDIT PROFILE'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Settings List
                _buildSwitchTile(
                  context,
                  Icons.notifications_none,
                  'Notifications',
                  settings?.enablePushNotifications ?? true,
                  (val) => _updateSetting(context, {'enable_push_notifications': val}),
                ),
                _buildMenuTile(context, Icons.public, 'Languages'),
                _buildMenuTile(context, Icons.payment, 'Payment'),
                _buildMenuTile(context, Icons.shield_outlined, 'Privacy & Policies'),
                _buildMenuTile(context, Icons.email_outlined, 'Feedback'),
                _buildMenuTile(context, Icons.book_outlined, 'Usage'),
                
                const SizedBox(height: 40),
                Center(
                  child: TextButton(
                    onPressed: () {
                      context.read<AuthProvider>().logout();
                      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                    },
                    child: const Text(
                      'Sign out',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
    );
  }

  Widget _buildMenuTile(BuildContext context, IconData icon, String title) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, color: Colors.black54),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
        onTap: () {},
      ),
    );
  }

  Widget _buildSwitchTile(BuildContext context, IconData icon, String title, bool value, Function(bool) onChanged) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, color: Colors.black54),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF00CEA6),
        ),
      ),
    );
  }
}
