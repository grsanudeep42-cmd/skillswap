import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/api_service.dart';
import '../../providers/auth_provider.dart';
import '../../core/themes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _iconFade;
  late Animation<Offset> _titleSlide;
  late Animation<double> _subtitleFade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _iconFade = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.4, curve: Curves.easeOut)));
    _titleSlide = Tween(begin: const Offset(0, 0.3), end: Offset.zero).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.3, 0.7, curve: Curves.easeOut)));
    _subtitleFade = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.6, 1.0, curve: Curves.easeOut)));
    _ctrl.forward();
    _initApp();
  }

  Future<void> _initApp() async {
    final auth = context.read<AuthProvider>();
    await auth.init();
    // Seed demo users if needed (safe no-op if already seeded)
    ApiService().seedDemoUsers();
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(auth.isLoggedIn ? '/home' : '/login');
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bg,
      body: Stack(
        children: [
          // Subtle ambient glow
          Positioned(
            top: MediaQuery.of(context).size.height * 0.25,
            left: MediaQuery.of(context).size.width * 0.5 - 120,
            child: FadeTransition(
              opacity: _iconFade,
              child: Container(
                width: 240, height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    AppColors.green.withValues(alpha: 0.08),
                    AppColors.green.withValues(alpha: 0.02),
                    Colors.transparent,
                  ], stops: const [0.0, 0.5, 1.0]),
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FadeTransition(
                  opacity: _iconFade,
                  child: Container(
                    width: 88, height: 88,
                    decoration: BoxDecoration(
                      color: context.colors.surface1,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: context.colors.border.withValues(alpha: 0.6)),
                      boxShadow: [
                        BoxShadow(color: AppColors.green.withValues(alpha: 0.10), blurRadius: 40, spreadRadius: 0),
                        BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8)),
                      ],
                    ),
                    child: const Icon(Icons.swap_horiz_rounded, color: AppColors.green, size: 38),
                  ),
                ),
                const SizedBox(height: 28),
                SlideTransition(
                  position: _titleSlide,
                  child: FadeTransition(
                    opacity: _iconFade,
                    child: RichText(text: TextSpan(children: [
                      TextSpan(text: 'Skill', style: GoogleFonts.syne(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.green, letterSpacing: -1.0)),
                      TextSpan(text: 'Swap', style: GoogleFonts.syne(fontSize: 32, fontWeight: FontWeight.w800, color: const Color(0xFFF0F1F6), letterSpacing: -1.0)),
                    ])),
                  ),
                ),
                const SizedBox(height: 10),
                FadeTransition(
                  opacity: _subtitleFade,
                  child: Text('Exchange skills, not money',
                      style: GoogleFonts.dmSans(fontSize: 14, color: context.colors.textMuted, letterSpacing: 0.3)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
