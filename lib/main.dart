import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/pages/splash_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/auth/presentation/pages/forgot_password_page.dart';
import 'features/ticket/presentation/pages/ticket_detail_page.dart';
import 'features/ticket/presentation/pages/create_ticket_page.dart';
import 'features/profile/presentation/pages/edit_profile_page.dart';
import 'features/profile/presentation/pages/change_password_page.dart';
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

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
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
