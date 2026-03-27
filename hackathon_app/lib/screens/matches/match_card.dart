import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../providers/match_provider.dart';
import '../../models/match_model.dart';
import '../../widgets/app_avatar.dart';
import '../chat/chat_screen.dart';
import '../exchange/exchange_detail_screen.dart';
import '../../providers/exchange_provider.dart';
import '../../core/themes.dart';

class MatchCard extends StatelessWidget {
  final MatchModel match;
  final String currentUserId;
  final bool isRequest;
  final bool showPendingBadge;

  const MatchCard({
    super.key,
    required this.match,
    required this.currentUserId,
    required this.isRequest,
    this.showPendingBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    final otherUser = match.requester.id == currentUserId ? match.receiver : match.requester;
    final mySkill = match.requester.id == currentUserId ? match.requesterSkillOffered : match.receiverSkillOffered;
    final theirSkill = match.requester.id == currentUserId ? match.receiverSkillOffered : match.requesterSkillOffered;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.elevatedCard(accentColor: isRequest ? null : AppColors.green),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header row
        Row(children: [
          AppAvatar(initial: otherUser.name.isNotEmpty ? otherUser.name[0] : '?', size: 48),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              otherUser.name,
              style: AppText.displaySm,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (otherUser.location.isNotEmpty) ...[
              const SizedBox(height: 2),
              Row(children: [
                Icon(Icons.location_on_outlined, size: 12, color: context.colors.textHint),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    otherUser.location,
                    style: AppText.bodySm,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ]),
            ],
          ])),
        ]),
        const SizedBox(height: 18),

        // Overflow-safe skill exchange row (plain text only).
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('YOU TEACH', style: AppText.labelMuted, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(
                    mySkill,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.bodyMd.copyWith(color: context.colors.textPrimary),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Icon(Icons.swap_horiz, size: 20, color: AppColors.green),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('YOU LEARN', style: AppText.labelMuted, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(
                    theirSkill,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: AppText.bodyMd.copyWith(color: context.colors.textPrimary),
                  ),
                ],
              ),
            ),
          ],
        ),

        if (isRequest && !showPendingBadge) ...[
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: _secondaryButton(context, 'Decline', Icons.close_rounded, () async {
              await context.read<MatchProvider>().respond(match.id, 'rejected');
            }, color: AppColors.red)),
            const SizedBox(width: 12),
            Expanded(child: _primaryButton(context, 'Accept', Icons.check_rounded, () async {
              await context.read<MatchProvider>().respond(match.id, 'accepted');
            })),
          ]),
        ] else if (showPendingBadge) ...[
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.purple.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.purple.withValues(alpha: 0.25)),
              ),
              child: Text(
                'Pending',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.purpleLight,
                ),
              ),
            ),
          ),
        ] else ...[
          const SizedBox(height: 18),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: 0.2, // Mock progress for matching phase
              minHeight: 4,
              backgroundColor: context.colors.surface3,
              valueColor: const AlwaysStoppedAnimation(AppColors.green),
            ),
          ),
          const SizedBox(height: 6),
          Text('20% exchanged', style: GoogleFonts.inter(
              fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.green, letterSpacing: 0.2)),
          const SizedBox(height: 18),
          Row(children: [
            Expanded(child: _secondaryButton(context, 'Chat', Icons.chat_bubble_outline_rounded, () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => ChatScreen(matchId: match.id, otherUser: otherUser),
              ));
            })),
            const SizedBox(width: 12),
            Expanded(child: _primaryButton(context, 'Exchange', Icons.swap_horiz_rounded, () async {
              final ep = context.read<ExchangeProvider>();
              await ep.fetchExchanges();
              try {
                final exchange = ep.exchanges.firstWhere(
                  (e) => (e.user1.id == match.requester.id && e.user2.id == match.receiver.id) ||
                         (e.user1.id == match.receiver.id && e.user2.id == match.requester.id),
                  orElse: () => ep.exchanges.first,
                );
                if (context.mounted) {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => ExchangeDetailScreen(exchangeId: exchange.id),
                  ));
                }
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('No active exchange found', style: AppText.bodyMd),
                      backgroundColor: context.colors.surface2,
                    )
                  );
                }
              }
            })),
          ]),
        ],
      ]),
    );
  }

  Widget _secondaryButton(BuildContext context, String label, IconData icon, VoidCallback onTap, {Color? color}) {
    final c = color ?? context.colors.textPrimary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: context.colors.surface2,
          border: Border.all(color: context.colors.border),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 16, color: c.withValues(alpha: 0.8)),
          const SizedBox(width: 6),
          Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: c.withValues(alpha: 0.9))),
        ]),
      ),
    );
  }

  Widget _primaryButton(BuildContext context, String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.green.withValues(alpha: 0.12),
          border: Border.all(color: AppColors.green.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: AppColors.green.withValues(alpha: 0.05), blurRadius: 10)],
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 16, color: AppColors.green),
          const SizedBox(width: 6),
          Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.green)),
        ]),
      ),
    );
  }
}
