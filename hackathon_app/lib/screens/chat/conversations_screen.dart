import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../core/constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/match_provider.dart';
import '../../widgets/app_avatar.dart';
import 'chat_screen.dart';
import '../../core/themes.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});
  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MatchProvider>().fetchMatches();
    });
  }

  @override
  Widget build(BuildContext context) {
    final mp = context.watch<MatchProvider>();
    final auth = context.watch<AuthProvider>();
    final currentUserId = auth.currentUser?.id ?? '';
    final conversations = mp.acceptedMatches;

    return Column(children: [
      const SizedBox(height: 12),
      Expanded(
        child: mp.isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.green, strokeWidth: 2.5))
            : conversations.isEmpty
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
                        child: Icon(Icons.chat_bubble_outline_rounded, size: 32, color: context.colors.textHint),
                      ),
                      const SizedBox(height: 24),
                      Text('No messages', style: AppText.displaySm, textAlign: TextAlign.center),
                      const SizedBox(height: 8),
                      Text('Start a conversation with your connections.',
                          style: AppText.bodyMd, textAlign: TextAlign.center),
                    ],
                  )))
                : RefreshIndicator(
                    color: AppColors.green, backgroundColor: context.colors.surface2,
                    onRefresh: () => mp.fetchMatches(),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      itemCount: conversations.length,
                      itemBuilder: (ctx, i) {
                        final match = conversations[i];
                        final otherUser = match.requester.id == currentUserId ? match.receiver : match.requester;
                        return GestureDetector(
                          onTap: () => Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => ChatScreen(matchId: match.id, otherUser: otherUser))),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: AppDecorations.elevatedCard(),
                            child: Row(children: [
                              AppAvatar(initial: otherUser.name.isNotEmpty ? otherUser.name[0] : '?', size: 52),
                              const SizedBox(width: 16),
                              Expanded(child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(otherUser.name, style: GoogleFonts.syne(
                                            fontSize: 16, fontWeight: FontWeight.w700, color: context.colors.textPrimary, letterSpacing: -0.2),
                                            maxLines: 1, overflow: TextOverflow.ellipsis),
                                      ),
                                      Text(timeago.format(match.createdAt), style: GoogleFonts.dmSans(
                                          fontSize: 12, fontWeight: FontWeight.w500, color: context.colors.textHint)),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: context.colors.surface2,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: context.colors.border),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.swap_horiz_rounded, size: 12, color: context.colors.textMuted),
                                        const SizedBox(width: 4),
                                        Text('${match.requesterSkillOffered} ⇌ ${match.receiverSkillOffered}',
                                            style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w600, color: context.colors.textMuted),
                                            maxLines: 1, overflow: TextOverflow.ellipsis),
                                      ],
                                    ),
                                  ),
                                ],
                              )),
                            ]),
                          ),
                        );
                      },
                    ),
                  ),
      ),
    ]);
  }
}
