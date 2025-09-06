import 'package:flutter/material.dart';
import '../presentation/report_issue/report_issue.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/issue_dashboard/issue_dashboard.dart';
import '../presentation/user_profile/user_profile.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/interactive_map/interactive_map.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String reportIssue = '/report-issue';
  static const String splash = '/splash-screen';
  static const String issueDashboard = '/issue-dashboard';
  static const String userProfile = '/user-profile';
  static const String login = '/login-screen';
  static const String interactiveMap = '/interactive-map';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    reportIssue: (context) => const ReportIssue(),
    splash: (context) => const SplashScreen(),
    issueDashboard: (context) => const IssueDashboard(),
    userProfile: (context) => const UserProfile(),
    login: (context) => const LoginScreen(),
    interactiveMap: (context) => const InteractiveMap(),
    // TODO: Add your other routes here
  };
}
