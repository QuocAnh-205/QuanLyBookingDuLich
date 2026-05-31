import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/onboarding_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/auth/screens/forgot_password_screen.dart';
import 'features/explore/presentation/provider/explore_provider.dart';
import 'features/explore/presentation/screens/explore_screen.dart';
import 'features/main/presentation/screens/main_screen.dart';
import 'features/details/presentation/provider/detail_provider.dart';
import 'features/search/presentation/provider/search_provider.dart';
import 'features/categories/presentation/provider/category_provider.dart';
import 'features/details/presentation/provider/wishlist_provider.dart';
import 'features/trips/presentation/provider/trips_provider.dart';
import 'features/chat/presentation/provider/chat_provider.dart';
import 'features/notifications/presentation/provider/notification_provider.dart';
import 'features/profile/presentation/provider/profile_provider.dart';
import 'features/payment/presentation/provider/payment_provider.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ExploreProvider()..fetchExploreData()),
        ChangeNotifierProvider(create: (_) => DetailProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => TripsProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()..setMockProfile()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
      ],
      child: const Fellow4UApp(),
    ),
  );
}

class Fellow4UApp extends StatefulWidget {
  const Fellow4UApp({super.key});

  @override
  State<Fellow4UApp> createState() => _Fellow4UAppState();
}

class _Fellow4UAppState extends State<Fellow4UApp> {
  @override
  void initState() {
    super.initState();
    // Thử tự động đăng nhập khi mở app
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).tryAutoLogin();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fellow4U',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/', // Reverted to Onboarding for proper flow
      routes: {
        '/': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/explore': (context) => const MainScreen(),
      },
    );
  }
}
