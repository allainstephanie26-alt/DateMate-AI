import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';

import 'screens/ai_recommendation_screen.dart';
import 'screens/bucket_list_screen.dart';
import 'screens/couple_preferences_screen.dart';
import 'screens/home_dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'services/cloud_sync_service.dart';
import 'services/local_database.dart';
import 'services/recommendation_service.dart';
import 'state/app_controller.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local database
  final localDatabase = LocalDatabase();
  await localDatabase.init();

  // Initialize cloud synchronization
  final cloudSync = CloudSyncService();
  await cloudSync.init();

  // Initialize recommendation service
  final recommendations = RecommendationService();

  // Create the main application controller
  final controller = AppController(localDatabase, recommendations, cloudSync);

  // Load saved application data
  await controller.load();

  runApp(
    DevicePreview(
      enabled: true,
      builder: (context) => DateMateApp(controller: controller),
    ),
  );
}

class DateMateApp extends StatelessWidget {
  const DateMateApp({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DateMate AI',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      home: RootShell(controller: controller),
    );
  }
}

class RootShell extends StatefulWidget {
  const RootShell({super.key, required this.controller});

  final AppController controller;

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _tabIndex = 0;

  void _goToTab(int index) {
    setState(() {
      _tabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    // Show Login / Sign Up when there is no logged-in user.
    if (controller.currentUser == null) {
      return LoginScreen(
        controller: controller,
        onLoggedIn: () {
          setState(() {
            _tabIndex = 0;
          });
        },
      );
    }

    // Main 5-screen navigation.
    switch (_tabIndex) {
      case 1:
        return AiRecommendationScreen(
          controller: controller,
          onNavTap: _goToTab,
        );

      case 2:
        return BucketListScreen(controller: controller, onNavTap: _goToTab);

      case 3:
        return CouplePreferencesScreen(
          controller: controller,
          onNavTap: _goToTab,
          onSaved: () {
            setState(() {
              _tabIndex = 0;
            });
          },
        );

      default:
        return HomeDashboardScreen(
          controller: controller,
          onNavTap: _goToTab,
          onGetFreshIdea: () {
            _goToTab(1);
          },
          onCantDecide: () {
            _goToTab(1);
          },
          onOpenBucketList: () {
            _goToTab(2);
          },
        );
    }
  }
}
