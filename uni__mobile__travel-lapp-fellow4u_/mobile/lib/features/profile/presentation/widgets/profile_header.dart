import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/profile_provider.dart';
import '../screens/settings_screen.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final user = profileProvider.profile;

    if (user == null) {
      return const SizedBox(
        height: 250,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            // Cover Image
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(user.coverUrl ?? 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=2073&auto=format&fit=crop'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Gradient Overlay for better icon visibility
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.transparent,
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Top Controls
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (Navigator.canPop(context))
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    )
                  else
                    const SizedBox.shrink(),
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white, size: 28),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SettingsScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
            // Cover Camera Icon
            Positioned(
              bottom: 10,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
              ),
            ),
            // Avatar and Info Overlap
            Positioned(
              bottom: -40,
              left: 24,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          radius: 40,
                          backgroundImage: NetworkImage(user.avatarUrl ?? 'https://via.placeholder.com/150'),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Color(0xFF00CEA6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          user.fullName,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          user.email ?? 'yoojin@gmail.com',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 50),
      ],
    );
  }
}
