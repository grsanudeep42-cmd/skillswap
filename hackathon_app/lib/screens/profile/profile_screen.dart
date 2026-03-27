import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_avatar.dart';
import 'edit_profile_screen.dart';
import '../../core/themes.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    if (user == null) return const Center(child: CircularProgressIndicator(color: AppColors.green, strokeWidth: 2.5));

    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(
        backgroundColor: context.colors.bg, 
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('Profile', style: AppText.displaySm),
        iconTheme: IconThemeData(color: context.colors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF1E1E1E)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.green, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.green.withValues(alpha: 0.28),
                          blurRadius: 18,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: AppAvatar(initial: user.name.isNotEmpty ? user.name[0] : '?', size: 80),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    user.name,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  if (user.bio.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      user.bio,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: context.colors.textMuted,
                        height: 1.35,
                      ),
                    ),
                  ],
                  if (user.location.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: context.colors.surface2,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: context.colors.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_on_rounded, size: 14, color: context.colors.textMuted),
                          const SizedBox(width: 6),
                          Text(
                            user.location,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: context.colors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(child: _heroStatPill(context, '${user.completedExchanges}', 'Exchanges', AppColors.green)),
                      const SizedBox(width: 8),
                      Expanded(child: _heroStatPill(context, user.rating.toStringAsFixed(1), 'Rating ★', const Color(0xFFFFA726))),
                      const SizedBox(width: 8),
                      Expanded(child: _heroStatPill(context, '${user.totalRatings}', 'Reviews', AppColors.purple)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
            Row(
              children: [
                Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.green, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Text('I Teach', style: AppText.bodyLg),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: user.skillsOffered.isEmpty
                  ? [_emptyChip(context, 'No teaching skills yet')]
                  : user.skillsOffered.map((s) => _compactSkillChip(context, s, AppColors.green)).toList(),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.purple, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Text('I Learn', style: AppText.bodyLg),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: user.skillsWanted.isEmpty
                  ? [_emptyChip(context, 'No learning goals yet')]
                  : user.skillsWanted.map((s) => _compactSkillChip(context, s, AppColors.purple)).toList(),
            ),
            const SizedBox(height: 34),
            _ActionButton(
              label: 'Edit Profile',
              icon: Icons.edit_outlined,
              isPrimary: true,
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EditProfileScreen())),
            ),
            const SizedBox(height: 12),
            _ActionButton(
              label: 'Log Out',
              icon: Icons.logout_rounded,
              isPrimary: false,
              onTap: () async {
                await auth.logout();
                if (!context.mounted) return;
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroStatPill(BuildContext context, String value, String label, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: context.colors.surface2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        children: [
          Text(value, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: accent)),
          const SizedBox(height: 4),
          Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: context.colors.textMuted)),
        ],
      ),
    );
  }

  Widget _compactSkillChip(BuildContext context, String text, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.45)),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: accent),
      ),
    );
  }

  Widget _emptyChip(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: context.colors.surface2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.border),
      ),
      child: Text(text, style: AppText.bodySm),
    );
  }
}

class _ActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback onTap;
  const _ActionButton({required this.label, required this.icon, this.isPrimary = true, required this.onTap});
  @override
  State<_ActionButton> createState() => _ABState();
}
class _ABState extends State<_ActionButton> {
  bool _p = false;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTapDown: (_) => setState(() => _p = true),
    onTapUp: (_) { setState(() => _p = false); widget.onTap(); },
    onTapCancel: () => setState(() => _p = false),
    child: AnimatedScale(scale: _p ? 0.98 : 1.0, duration: const Duration(milliseconds: 100),
      child: Container(width: double.infinity, height: 52,
        decoration: BoxDecoration(
          color: widget.isPrimary ? const Color(0xFF00E676) : Colors.transparent,
          border: Border.all(color: widget.isPrimary ? const Color(0xFF00E676) : const Color(0xFFFF3B30)),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(widget.icon, color: widget.isPrimary ? Colors.black : const Color(0xFFFF3B30), size: 18),
          const SizedBox(width: 8),
          Text(widget.label, style: GoogleFonts.inter(
              fontSize: 15, fontWeight: FontWeight.w700, color: widget.isPrimary ? Colors.black : const Color(0xFFFF3B30))),
        ]))));
}
