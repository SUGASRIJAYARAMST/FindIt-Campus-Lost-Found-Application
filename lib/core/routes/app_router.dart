import 'package:flutter/material.dart';

import '../../presentation/screens/admin/admin_dashboard.dart';
import '../../presentation/screens/admin/item_management_screen.dart';
import '../../presentation/screens/admin/user_management_screen.dart';
import '../../presentation/screens/archive/archive_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/chat/chat_list_screen.dart';
import '../../presentation/screens/chat/conversation_screen.dart';
import '../../presentation/screens/favorites/favorites_screen.dart';
import '../../presentation/screens/history/report_history_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/items/item_detail_screen.dart';
import '../../presentation/screens/items/item_list_screen.dart';
import '../../presentation/screens/items/my_reports_screen.dart';
import '../../presentation/screens/items/upload_item_screen.dart';
import '../../presentation/screens/matching/matching_screen.dart';
import '../../presentation/screens/notifications/notifications_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/rewards/rewards_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/screens/splash/splash_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String items = '/items';
  static const String itemDetail = '/items/detail';
  static const String uploadItem = '/items/upload';
  static const String uploadLost = '/items/upload/lost';
  static const String uploadFound = '/items/upload/found';
  static const String myReports = '/items/my-reports';
  static const String profile = '/profile';
  static const String rewards = '/rewards';
  static const String settings = '/settings';
  static const String matching = '/matching';
  static const String favorites = '/favorites';
  static const String reportHistory = '/report-history';
  static const String archive = '/archive';
  static const String adminDashboard = '/admin/dashboard';
  static const String adminUsers = '/admin/users';
  static const String adminItems = '/admin/items';
  static const String notifications = '/notifications';
  static const String chatList = '/chat';
  static const String conversation = '/chat/conversation';

  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case splash:
        return _buildRoute(const SplashScreen(), routeSettings);
      case login:
        return _buildRoute(const LoginScreen(), routeSettings);
      case register:
        return _buildRoute(const RegisterScreen(), routeSettings);
      case home:
        return _buildRoute(const HomeScreen(), routeSettings);
      case items:
        return _buildRoute(const ItemListScreen(), routeSettings);
      case itemDetail:
        return _buildRoute(const ItemDetailScreen(), routeSettings);
      case uploadLost:
        return _buildRoute(const ReportItemScreen(type: 'lost'), routeSettings);
      case uploadFound:
        return _buildRoute(const ReportItemScreen(type: 'found'), routeSettings);
      case uploadItem:
        return _buildRoute(const ReportItemScreen(type: 'lost'), routeSettings);
      case myReports:
        return _buildRoute(const MyReportsScreen(), routeSettings);
      case profile:
        return _buildRoute(const ProfileScreen(), routeSettings);
      case rewards:
        return _buildRoute(const RewardsScreen(), routeSettings);
      case settings:
        return _buildRoute(const SettingsScreen(), routeSettings);
      case matching:
        return _buildRoute(const MatchingScreen(), routeSettings);
      case favorites:
        return _buildRoute(const FavoritesScreen(), routeSettings);
      case reportHistory:
        return _buildRoute(const ReportHistoryScreen(), routeSettings);
      case archive:
        return _buildRoute(const ArchiveScreen(), routeSettings);
      case adminDashboard:
        return _buildRoute(const AdminDashboard(), routeSettings);
      case adminUsers:
        return _buildRoute(const UserManagementScreen(), routeSettings);
      case adminItems:
        return _buildRoute(const ItemManagementScreen(), routeSettings);
      case notifications:
        return _buildRoute(const NotificationsScreen(), routeSettings);
      case chatList:
        return _buildRoute(const ChatListScreen(), routeSettings);
      case conversation:
        return _buildRoute(const ConversationScreen(), routeSettings);
      default:
        return _buildRoute(
          const Scaffold(body: Center(child: Text('Route not found'))),
          routeSettings,
        );
    }
  }

  static PageRouteBuilder _buildRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        );
        return FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curved),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.05, 0.0),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 350),
    );
  }
}
