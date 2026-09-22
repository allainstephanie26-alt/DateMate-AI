
import 'package:flutter/material.dart';

import 'screens/ai_recommendation_screen.dart';
import 'screens/bucket_list_screen.dart';
import 'screens/couple_preferences_screen.dart';
import 'screens/home_dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'theme.dart';

void main() {
  runApp(const DateMateApp());
}

class DateMateApp extends StatelessWidget {
  const DateMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DateMate AI',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home: const RootShell(),
    );
  }
}

/// Controls the main DateMate AI flow.
///
/// Five main screens:
/// 1. Login / Sign Up
/// 2. Couple Preferences
/// 3. Home Dashboard
/// 4. AI Date Recommendation
/// 5. Date Bucket List
class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  bool _loggedIn = false;
  int _tabIndex = 0;

  void _goToTab(int index) {
    setState(() {
      _tabIndex = index;
    });
  }

  void _handleLogin() {
    setState(() {
      _loggedIn = true;
      _tabIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Screen 1: Login / Sign Up
    if (!_loggedIn) {
      return LoginScreen(
        onLoggedIn: _handleLogin,
      );
    }

    switch (_tabIndex) {
      // Screen 2: Couple Preferences
      case 3:
        return CouplePreferencesScreen(
          onBack: () => _goToTab(0),
          onNavTap: _goToTab,
        );

      // Screen 5: Date Bucket List
      case 2:
        return BucketListScreen(
          onBack: () => _goToTab(0),
          onNavTap: _goToTab,
        );

      // Screen 4: AI Date Recommendation
      case 1:
        return AiRecommendationScreen(
          onBack: () => _goToTab(0),
          onAddToBucket: (suggestion) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Added ${suggestion.title} to your Bucket List',
                ),
              ),
            );
          },
        );

      // Screen 3: Home Dashboard
      case 0:
      default:
        return HomeDashboardScreen(
          onNavTap: _goToTab,
          onGetFreshIdea: () => _goToTab(1),
          onCantDecide: () => _goToTab(1),
          onOpenBucketList: () => _goToTab(2),
        );
    }
  }
}
