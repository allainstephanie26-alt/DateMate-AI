import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/ai_recommendation_screen.dart';
import 'screens/bucket_list_screen.dart';
import 'screens/couple_preferences_screen.dart';
import 'screens/home_dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'services/cloud_sync_service.dart';
import 'services/local_database.dart';
import 'services/place_catalog_service.dart';
import 'state/app_controller.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Light status/navigation icons over the dark romantic theme.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.backgroundDeep,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize local database.
  final localDatabase = LocalDatabase();
  await localDatabase.init();

  // Initialize cloud synchronization.
  final cloudSync = CloudSyncService();
  await cloudSync.init();

  final catalog = PlaceCatalogService();

  // Create the main application controller.
  final controller = AppController(localDatabase, catalog, cloudSync);

  // Load saved application data.
  await controller.load();

  runApp(
    DevicePreview(
      enabled: kIsWeb,
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

      // Device Preview support.
      locale: DevicePreview.locale(context),

      builder: (context, child) => DevicePreview.appBuilder(
        context,
        AppBackdrop(child: child ?? const SizedBox.shrink()),
      ),

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

    Widget child;
    switch (_tabIndex) {
      case 1:
        child = AiRecommendationScreen(
          key: const ValueKey('recommend'),
          controller: controller,
          onNavTap: _goToTab,
        );
        break;

      case 2:
        child = BucketListScreen(
          key: const ValueKey('bucket'),
          controller: controller,
          onNavTap: _goToTab,
        );
        break;

      case 3:
        child = CouplePreferencesScreen(
          key: const ValueKey('preferences'),
          controller: controller,
          onNavTap: _goToTab,
          onSaved: () {
            setState(() {
              _tabIndex = 0;
            });
          },
        );
        break;

      default:
        child = HomeDashboardScreen(
          key: const ValueKey('home'),
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

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (widget, animation) =>
          FadeTransition(opacity: animation, child: widget),
      child: child,
    );
  }
}
