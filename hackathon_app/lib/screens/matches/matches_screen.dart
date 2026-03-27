import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/match_provider.dart';
import 'match_card.dart';
import '../../core/themes.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});
  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  int _tab = 0; // 0=Requests, 1=Sent, 2=Connected
  bool _loadedForUser = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mp = context.read<MatchProvider>();
      mp.fetchMatches();
      mp.fetchPending();
      mp.fetchSent();
    });
  }

  @override
  Widget build(BuildContext context) {
    final mp = context.watch<MatchProvider>();
    final auth = context.watch<AuthProvider>();
    final currentUserId = auth.currentUser?.id ?? '';
    if (!_loadedForUser && currentUserId.isNotEmpty) {
      _loadedForUser = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<MatchProvider>().fetchMatches();
        context.read<MatchProvider>().fetchPending();
        context.read<MatchProvider>().fetchSent();
      });
    }
    debugPrint('MatchesScreen currentUserId: $currentUserId');
    debugPrint('MatchesScreen pendingMatches.length: ${mp.pendingMatches.length}');
    final incomingPending = mp.pendingMatches
        .where((m) => m.requester.id != currentUserId)
        .toList();
    final sentPending = mp.sentMatches;
    final connected = mp.acceptedMatches;

    return Column(children: [
      const SizedBox(height: 12),
      // ── Tab switcher ──
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: context.colors.surface1,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.colors.border.withValues(alpha: 0.8)),
          ),
          child: Row(
            children: [
              Expanded(child: _tabButton(0, 'Requests', incomingPending.length)),
              Expanded(child: _tabButton(1, 'Sent', sentPending.length)),
              Expanded(child: _tabButton(2, 'Connected', connected.length)),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),
      Expanded(
        child: mp.isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.green, strokeWidth: 2.5))
            : _tab == 0
                ? _buildList(incomingPending, currentUserId, isRequest: true)
                : _tab == 1
                    ? _buildList(sentPending, currentUserId, isRequest: true, isSent: true)
                    : _buildList(connected, currentUserId, isRequest: false),
      ),
    ]);
  }

  Widget _tabButton(int index, String label, int count) {
    final isActive = _tab == index;
    return GestureDetector(
      onTap: () => setState(() => _tab = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isActive ? context.colors.surface3 : Colors.transparent,
          borderRadius: BorderRadius.circular(11), // Slightly less than container to fit inside border
        ),
        child: Center(
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(label, style: GoogleFonts.inter(fontSize: 13,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? context.colors.textPrimary : context.colors.textMuted)),
            if (count > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.green.withValues(alpha: 0.15) : context.colors.surface2,
                  borderRadius: BorderRadius.circular(6),
                  border: isActive ? Border.all(color: AppColors.green.withValues(alpha: 0.3)) : null,
                ),
                child: Center(child: Text('$count', style: GoogleFonts.inter(
                    fontSize: 11, fontWeight: FontWeight.w600,
                    color: isActive ? AppColors.green : context.colors.textHint))),
              ),
            ],
          ]),
        ),
      ),
    );
  }

  Widget _buildList(
    List matches,
    String currentUserId, {
    required bool isRequest,
    bool isSent = false,
  }) {
    if (matches.isEmpty) {
      return Center(child: SizedBox(width: 260, child: Column(
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
            child: Icon(
                isSent
                    ? Icons.outbox_rounded
                    : isRequest
                        ? Icons.inbox_rounded
                        : Icons.people_alt_rounded,
                size: 32, color: context.colors.textHint),
          ),
          const SizedBox(height: 24),
          Text(
              isSent
                  ? 'No sent requests'
                  : isRequest
                      ? 'No requests'
                      : 'No connections',
              style: AppText.displaySm, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(isSent
              ? 'Requests you send will appear here as pending.'
              : isRequest
                  ? 'When someone wants to connect with you, their request will appear here.'
                  : 'Connect with people in Discover to start exchanging skills.',
              style: AppText.bodyMd, textAlign: TextAlign.center),
        ],
      )));
    }
    return RefreshIndicator(
      color: AppColors.green, backgroundColor: context.colors.surface2,
      onRefresh: () async {
        await context.read<MatchProvider>().fetchMatches();
        await context.read<MatchProvider>().fetchPending();
        await context.read<MatchProvider>().fetchSent();
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        itemCount: matches.length,
        itemBuilder: (ctx, i) {
          final match = matches[i];
          return MatchCard(
            match: match,
            currentUserId: currentUserId,
            isRequest: isRequest,
            showPendingBadge: isSent,
          );
        },
      ),
    );
  }
}
