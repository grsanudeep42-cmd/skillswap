import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/themes.dart';
import 'providers/theme_provider.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';

class SkillSwapApp extends StatelessWidget {
  const SkillSwapApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return AnimatedTheme(
      duration: const Duration(milliseconds: 300),
      data: themeProvider.isDark ? AppThemes.dark : AppThemes.light,
      child: MaterialApp(
        title: 'SkillSwap',
        debugShowCheckedModeBanner: false,
        themeMode: themeProvider.themeMode,
        theme: AppThemes.light,
        darkTheme: AppThemes.dark,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const HomeScreen(),
        },
      ),
    );
  }
}
