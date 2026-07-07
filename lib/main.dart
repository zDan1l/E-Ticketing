import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'core/config/app_config.dart';
import 'services/auth_service.dart';
import 'features/auth/presentation/pages/splash_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/auth/presentation/pages/forgot_password_page.dart';
import 'features/ticket/presentation/pages/ticket_detail_page.dart';
import 'features/ticket/presentation/pages/ticket_list_page.dart';
import 'features/ticket/presentation/pages/create_ticket_page.dart';
import 'features/profile/presentation/pages/edit_profile_page.dart';
import 'features/profile/presentation/pages/change_password_page.dart';
import 'features/admin/presentation/pages/user_management_page.dart';
import 'features/admin/presentation/pages/activity_logs_page.dart';
import 'features/admin/presentation/pages/admin_dashboard_page.dart';
import 'features/debug/presentation/pages/connection_test_page.dart';
import 'shared/widgets/main_navigation.dart';
import 'models/ticket_model.dart';

/// Global theme notifier so any widget can toggle dark mode
class ThemeNotifier extends ValueNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.light);

  void toggleTheme() {
    value = value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }

  bool get isDark => value == ThemeMode.dark;
}

final themeNotifier = ThemeNotifier();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize auth service (loads saved session if available)
  await AuthService().initialize();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, themeMode, child) {
        return MaterialApp(
          title: 'HelpDesk — E-Ticketing',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          initialRoute: '/',
          onGenerateRoute: (settings) {
            switch (settings.name) {
              case '/':
                return MaterialPageRoute(
                  builder: (_) => const SplashPage(),
                );
              case '/login':
                return MaterialPageRoute(
                  builder: (_) => const LoginPage(),
                );
              case '/register':
                return MaterialPageRoute(
                  builder: (_) => const RegisterPage(),
                );
              case '/forgot-password':
                return MaterialPageRoute(
                  builder: (_) => const ForgotPasswordPage(),
                );
              case '/main':
                return MaterialPageRoute(
                  builder: (_) => const MainNavigation(),
                );
              case '/ticket-detail':
                final ticket = settings.arguments as TicketModel;
                return MaterialPageRoute(
                  builder: (_) => TicketDetailPage(ticket: ticket),
                );
              case '/create-ticket':
                return MaterialPageRoute(
                  builder: (_) => const CreateTicketPage(),
                  fullscreenDialog: true,
                );
              case '/edit-profile':
                return MaterialPageRoute(
                  builder: (_) => const EditProfilePage(),
                );
              case '/change-password':
                return MaterialPageRoute(
                  builder: (_) => const ChangePasswordPage(),
                );
              case '/ticket-list':
                return MaterialPageRoute(
                  builder: (_) => const TicketListPage(),
                );
              case '/user-management':
                return MaterialPageRoute(
                  builder: (_) => const UserManagementPage(),
                );
              case '/activity-logs':
                return MaterialPageRoute(
                  builder: (_) => const ActivityLogsPage(),
                );
              case '/admin-dashboard':
                return MaterialPageRoute(
                  builder: (_) => const AdminDashboardPage(),
                );
              case '/connection-test':
                return MaterialPageRoute(
                  builder: (_) => const ConnectionTestPage(),
                );
              default:
                return MaterialPageRoute(
                  builder: (_) => const SplashPage(),
                );
            }
          },
        );
      },
    );
  }
}
