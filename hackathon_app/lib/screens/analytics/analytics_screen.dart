import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/exchange_provider.dart';
import '../../core/themes.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});
  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExchangeProvider>().fetchExchanges();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final ep = context.watch<ExchangeProvider>();
    final user = auth.currentUser;
    final totalExchanges = ep.exchanges.length;
    final totalSessions = ep.exchanges.fold<int>(0, (s, e) => s + e.sessions.length);
    final totalHours = ep.exchanges.fold<int>(0, (s, e) =>
        s + e.sessions.fold<int>(0, (sum, ss) => sum + ss.duration)) / 60;
    final skills = user?.skillsOffered ?? [];
    final activeExchanges = ep.exchanges.where((e) => e.status == 'active').toList();
    final skillSessionCounts = <String, int>{};
    for (final ex in ep.exchanges) {
      final key = ex.skill1.isNotEmpty ? ex.skill1 : 'General';
      skillSessionCounts[key] = (skillSessionCounts[key] ?? 0) + ex.sessions.length;
    }
    final sortedSkillEntries = skillSessionCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxSkillSessions = sortedSkillEntries.isEmpty
        ? 1
        : sortedSkillEntries.first.value;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          'Your Progress',
          style: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Track your learning journey with clear insights.',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: context.colors.textMuted,
          ),
        ),
        const SizedBox(height: 24),

        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.95,
          children: [
            _statCard(Icons.swap_horiz_rounded, 'Exchanges', '$totalExchanges', AppColors.green),
            _statCard(Icons.video_camera_front_rounded, 'Sessions', '$totalSessions', AppColors.purple),
            _statCard(Icons.schedule_rounded, 'Hours', totalHours.toStringAsFixed(1), AppColors.blue),
            _statCard(Icons.auto_awesome_rounded, 'Skills', '${skills.length}', const Color(0xFFFFA726)),
          ],
        ),
        const SizedBox(height: 32),

        Text('Weekly Activity', style: AppText.labelMuted),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF1E1E1E)),
          ),
          child: Column(children: [
            _barChart(),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((d) =>
                SizedBox(width: 32, child: Center(
                    child: Text(d, style: GoogleFonts.inter(
                        fontSize: 11, fontWeight: FontWeight.w500, color: context.colors.textHint))))).toList()),
          ]),
        ),
        const SizedBox(height: 32),

        Text('Skill Distribution', style: AppText.labelMuted),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF1E1E1E)),
          ),
          child: sortedSkillEntries.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text('No skill data yet', style: AppText.bodyMd),
                )
              : Column(
                  children: sortedSkillEntries.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final skill = entry.value.key;
                    final count = entry.value.value;
                    final ratio = (count / maxSkillSessions).clamp(0.05, 1.0);
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        border: idx == sortedSkillEntries.length - 1
                            ? null
                            : Border(bottom: BorderSide(color: context.colors.border)),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 90,
                            child: Text(skill, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.bodyMd.copyWith(color: context.colors.textPrimary)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: ratio,
                                minHeight: 6,
                                backgroundColor: const Color(0xFF1E1E1E),
                                valueColor: const AlwaysStoppedAnimation(AppColors.green),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text('$count', style: AppText.bodySm.copyWith(color: context.colors.textPrimary)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ),
        const SizedBox(height: 32),

        Text('Exchange Health', style: AppText.labelMuted),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF1E1E1E)),
          ),
          child: activeExchanges.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text('No active exchanges', style: AppText.bodyMd),
                )
              : Column(
                  children: activeExchanges.map((ex) {
                    final progress = ((ex.user1Progress + ex.user2Progress) / 200).clamp(0.0, 1.0);
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: context.colors.surface3,
                                child: Text(
                                  ex.user2.name.isNotEmpty ? ex.user2.name[0].toUpperCase() : '?',
                                  style: GoogleFonts.inter(color: context.colors.textPrimary, fontWeight: FontWeight.w600),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(ex.user2.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.bodyMd.copyWith(color: context.colors.textPrimary)),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.green.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.green.withValues(alpha: 0.35)),
                                ),
                                child: Text('Active', style: AppText.bodySm.copyWith(color: AppColors.green)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 5,
                              backgroundColor: const Color(0xFF1E1E1E),
                              valueColor: const AlwaysStoppedAnimation(AppColors.green),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ),
        const SizedBox(height: 32),
      ]),
    );
  }

  Widget _statCard(IconData icon, String label, String value, Color accent) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E1E1E)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: accent.withValues(alpha: 0.25)),
          ),
          child: Icon(icon, color: accent, size: 20),
        ),
        const SizedBox(height: 12),
        Text(value, style: GoogleFonts.inter(
            fontSize: 28, fontWeight: FontWeight.w700, color: context.colors.textPrimary)),
        const SizedBox(height: 4),
        Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: context.colors.textMuted)),
      ]),
    );
  }

  Widget _barChart() {
    final rng = Random(42);
    final data = List.generate(7, (_) => rng.nextDouble() * 0.8 + 0.1);
    final maxVal = data.reduce(max);
    return SizedBox(
      height: 140,
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.end,
        children: data.asMap().entries.map((e) {
          final isToday = e.key == 4; // Mock today
          final ratio = e.value / maxVal;
          return Container(
            width: 32, height: 140 * ratio,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              color: isToday ? const Color(0xFF00E676) : const Color(0xFF1E1E1E),
            ),
          );
        }).toList()),
    );
  }
}
