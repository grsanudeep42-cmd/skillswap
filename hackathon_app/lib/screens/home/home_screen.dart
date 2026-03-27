import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_avatar.dart';
import '../discover/discover_screen.dart';
import '../matches/matches_screen.dart';
import '../exchange/exchanges_screen.dart';
import '../chat/conversations_screen.dart';
import '../analytics/analytics_screen.dart';
import '../profile/profile_screen.dart';
import '../../core/themes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final _pages = const [
    DiscoverScreen(),
    MatchesScreen(),
    ExchangesScreen(),
    ConversationsScreen(),
    AnalyticsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(
        backgroundColor: context.colors.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: RichText(text: TextSpan(children: [
          TextSpan(text: 'Skill', style: GoogleFonts.syne(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.green, letterSpacing: -0.8)),
          TextSpan(text: 'Swap', style: GoogleFonts.syne(fontSize: 24, fontWeight: FontWeight.w800, color: const Color(0xFFF0F1F6), letterSpacing: -0.8)),
        ])),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileScreen())),
              child: AppAvatar(
                initial: user?.name.isNotEmpty == true ? user!.name[0] : '?',
                size: 32,
              ),
            ),
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            decoration: BoxDecoration(
              color: context.colors.bg.withValues(alpha: 0.85),
              border: Border(top: BorderSide(color: context.colors.border.withValues(alpha: 0.5), width: 0.5)),
            ),
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
            height: 68 + MediaQuery.of(context).padding.bottom,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(0, Icons.explore_outlined, Icons.explore, 'Discover'),
                _navItem(1, Icons.people_alt_outlined, Icons.people_alt, 'Matches'),
                _navItem(2, Icons.swap_horiz_rounded, Icons.swap_horiz_rounded, 'Exchange'),
                _navItem(3, Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded, 'Chat'),
                _navItem(4, Icons.bar_chart_rounded, Icons.bar_chart_rounded, 'Stats'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, IconData activeIcon, String label) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? AppColors.green.withValues(alpha: 0.10) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isActive ? activeIcon : icon,
                size: 20,
                color: isActive ? AppColors.green : context.colors.textHint,
              ),
            ),
            const SizedBox(height: 2),
            Text(label, style: GoogleFonts.dmSans(
                fontSize: 10, fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? AppColors.green : context.colors.textHint)),
          ],
        ),
      ),
    );
  }
}
