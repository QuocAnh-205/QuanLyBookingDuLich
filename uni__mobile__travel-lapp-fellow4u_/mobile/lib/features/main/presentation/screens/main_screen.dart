import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../explore/presentation/screens/explore_screen.dart';
import '../../../trips/presentation/screens/trips_screen.dart';
import '../../../chat/presentation/screens/chat_list_screen.dart';
import '../../../notifications/presentation/screens/notification_screen.dart';
import '../../../notifications/presentation/provider/notification_provider.dart';
import '../../../profile/presentation/screens/profile_screen.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const ExploreScreen(),
    const TripsScreen(),
    const ChatListScreen(),
    const NotificationScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.token != null) {
        // Start polling for notifications globally
        context.read<NotificationProvider>().startPolling(auth.token!);
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF00CEA6),
          unselectedItemColor: Colors.grey,
          showSelectedLabels: true,
          showUnselectedLabels: false,
          elevation: 0,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined),
              activeIcon: Icon(Icons.explore),
              label: 'Explore',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.place_outlined),
              activeIcon: Icon(Icons.place),
              label: 'My Trips',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              activeIcon: Icon(Icons.chat_bubble),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: _buildNotificationIcon(Icons.notifications_outlined),
              activeIcon: _buildNotificationIcon(Icons.notifications),
              label: 'Notification',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(IconData icon) {
    return Consumer<NotificationProvider>(
      builder: (context, provider, child) {
        return Stack(
          children: [
            Icon(icon),
            if (provider.unreadCount > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    provider.unreadCount > 9 ? '9+' : provider.unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
