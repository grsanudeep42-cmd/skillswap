import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../providers/exchange_provider.dart';
import '../../widgets/app_avatar.dart';
import 'exchange_detail_screen.dart';
import '../../core/themes.dart';

class ExchangesScreen extends StatefulWidget {
  const ExchangesScreen({super.key});
  @override
  State<ExchangesScreen> createState() => _ExchangesScreenState();
}

class _ExchangesScreenState extends State<ExchangesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExchangeProvider>().fetchExchanges();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ep = context.watch<ExchangeProvider>();

    return Column(children: [
      const SizedBox(height: 12),
      Expanded(
        child: ep.isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.green, strokeWidth: 2.5))
            : ep.exchanges.isEmpty
                ? Center(child: SizedBox(width: 260, child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 80, height: 80,
                        decoration: BoxDecoration(
                          color: context.colors.surface1,
                          shape: BoxShape.circle,
                          border: Border.all(color: context.colors.border, width: 2),
                          boxShadow: [
                            BoxShadow(color: AppColors.green.withValues(alpha: 0.05), blurRadius: 40, spreadRadius: 10),
                          ],
                        ),
                        child: Icon(Icons.swap_horiz_rounded, size: 36, color: context.colors.textHint),
                      ),
                      const SizedBox(height: 24),
                      Text('No active exchanges', style: AppText.displaySm, textAlign: TextAlign.center),
                      const SizedBox(height: 8),
                      Text('Start exchanging skills by connecting with people in Matches.',
                          style: AppText.bodyMd, textAlign: TextAlign.center),
                    ],
                  )))
                : RefreshIndicator(
                    color: AppColors.green, backgroundColor: context.colors.surface2,
                    onRefresh: () => ep.fetchExchanges(),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      itemCount: ep.exchanges.length,
                      itemBuilder: (ctx, i) {
                        final ex = ep.exchanges[i];
                        return GestureDetector(
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => ExchangeDetailScreen(exchangeId: ex.id))),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(20),
                            decoration: AppDecorations.elevatedCard(
                                accentColor: ex.status == 'active' ? AppColors.green : null),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              // Header: overlapping avatars + names + badge
                              Row(children: [
                                SizedBox(width: 76, height: 50, child: Stack(children: [
                                  AppAvatar(initial: ex.user1.name.isNotEmpty ? ex.user1.name[0] : '?', size: 44),
                                  Positioned(left: 28, child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: const Color(0xFF101014), width: 3), // Match card bg to create knockout effect
                                    ),
                                    child: AppAvatar(initial: ex.user2.name.isNotEmpty ? ex.user2.name[0] : '?', size: 44),
                                  )),
                                ])),
                                const SizedBox(width: 14),
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text('${_shortName(ex.user1.name)} ↔ ${_shortName(ex.user2.name)}',
                                      style: GoogleFonts.syne(fontSize: 16, fontWeight: FontWeight.w700,
                                          color: context.colors.textPrimary, letterSpacing: -0.2),
                                      maxLines: 1, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 4),
                                  Text('${ex.skill1} ⇌ ${ex.skill2}',
                                      style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.green),
                                      maxLines: 1, overflow: TextOverflow.ellipsis),
                                ])),
                                // ACTIVE badge
                                if (ex.status == 'active')
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.green.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: AppColors.green.withValues(alpha: 0.25)),
                                    ),
                                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                                      _PulsingDot(),
                                      const SizedBox(width: 6),
                                      Text('ACTIVE', style: GoogleFonts.dmSans(
                                          fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.green, letterSpacing: 0.5)),
                                    ]),
                                  ),
                              ]),
                              const SizedBox(height: 24),

                              // Progress bars
                              Row(children: [
                                Expanded(child: _progressCol(ex.user1.name, ex.user1Progress, AppColors.green)),
                                const SizedBox(width: 20),
                                Expanded(child: _progressCol(ex.user2.name, ex.user2Progress, AppColors.purpleLight)),
                              ]),
                              const SizedBox(height: 20),

                              // Sessions pill
                              Row(children: [
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: context.colors.surface2,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: context.colors.border),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.history_toggle_off_rounded, size: 14, color: context.colors.textHint),
                                      const SizedBox(width: 6),
                                      Text('${ex.sessions.length} / 10 sessions',
                                          style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600, color: context.colors.textMuted)),
                                    ],
                                  ),
                                ),
                              ]),
                            ]),
                          ),
                        );
                      },
                    ),
                  ),
      ),
    ]);
  }

  String _shortName(String name) {
    if (name.length <= 10) return name;
    return '${name[0]} ${name.substring(0, 4)}...';
  }

  Widget _progressCol(String name, double progress, Color color) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(name.toUpperCase(), style: AppText.labelMuted, maxLines: 1, overflow: TextOverflow.ellipsis)),
          Text('${progress.toStringAsFixed(0)}%', style: GoogleFonts.dmSans(
              fontSize: 12, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
      const SizedBox(height: 8),
      ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: LinearProgressIndicator(
          value: (progress / 100).clamp(0.0, 1.0),
          minHeight: 4,
          backgroundColor: context.colors.surface3,
          valueColor: AlwaysStoppedAnimation(color),
        ),
      ),
    ]);
  }
}

class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _scale = Tween(begin: 1.0, end: 1.5).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(width: 5, height: 5, decoration: const BoxDecoration(
          color: AppColors.green, shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: AppColors.green, blurRadius: 4, spreadRadius: 1)])),
    );
  }
}
