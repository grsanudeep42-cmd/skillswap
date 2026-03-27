import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/exchange_provider.dart';
import '../session/video_call_screen.dart';
import '../../core/themes.dart';

class ExchangeDetailScreen extends StatefulWidget {
  final String exchangeId;
  const ExchangeDetailScreen({super.key, required this.exchangeId});
  @override
  State<ExchangeDetailScreen> createState() => _ExchangeDetailScreenState();
}

class _ExchangeDetailScreenState extends State<ExchangeDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExchangeProvider>().fetchExchange(widget.exchangeId);
    });
  }

  void _showLogSheet() {
    final durCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (ctx) => Container(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        decoration: BoxDecoration(
          color: context.colors.surface1,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border(top: BorderSide(color: context.colors.borderStrong)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 36, height: 4, decoration: BoxDecoration(
              color: context.colors.borderStrong, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 24),
          Align(alignment: Alignment.centerLeft,
              child: Text('Log Session', style: AppText.displayMd)),
          const SizedBox(height: 24),
          TextFormField(
            controller: durCtrl, keyboardType: TextInputType.number,
            style: GoogleFonts.dmSans(color: context.colors.textPrimary, fontSize: 14),
            decoration: AppDecorations.inputDecor(hint: 'Duration (minutes)', icon: Icons.timer_outlined),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: notesCtrl, maxLines: 3,
            style: GoogleFonts.dmSans(color: context.colors.textPrimary, fontSize: 14),
            decoration: AppDecorations.inputDecor(hint: 'Session notes (e.g. what you learned)', icon: Icons.notes_rounded),
          ),
          const SizedBox(height: 28),
          _PrimaryButton(label: 'Log Session', onTap: () async {
            final dur = int.tryParse(durCtrl.text) ?? 0;
            if (dur <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Enter valid duration'), backgroundColor: AppColors.red));
              return;
            }
            final ep = context.read<ExchangeProvider>();
            final nav = Navigator.of(context);
            final msg = ScaffoldMessenger.of(context);
            final ok = await ep.logSession(widget.exchangeId, dur, notesCtrl.text.trim());
            nav.pop();
            msg.showSnackBar(SnackBar(content: Text(ok ? 'Session logged successfully' : (ep.error ?? 'Failed')),
                backgroundColor: ok ? AppColors.green : AppColors.red));
          }),
        ]),
      ),
    );
  }

  void _showRateDialog() {
    int rating = 5;
    final revCtrl = TextEditingController();
    showDialog(context: context, builder: (ctx) => StatefulBuilder(
      builder: (context, ss) => AlertDialog(
        backgroundColor: context.colors.surface1,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: context.colors.border)),
        title: Text('Rate Exchange', style: AppText.displaySm),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (i) =>
            GestureDetector(onTap: () => ss(() => rating = i + 1),
              child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: const Color(0xFFFFAB40), size: 36))))),
          const SizedBox(height: 20),
          TextFormField(controller: revCtrl, maxLines: 3,
            style: GoogleFonts.dmSans(color: context.colors.textPrimary, fontSize: 14),
            decoration: AppDecorations.inputDecor(hint: 'Write a review...', icon: Icons.edit_outlined)),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: AppText.bodyMd)),
          TextButton(onPressed: () async {
            final ep = context.read<ExchangeProvider>();
            final ok = await ep.rate(widget.exchangeId, rating, revCtrl.text.trim());
            if (!context.mounted) return;
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(ok ? 'Rating submitted successfully' : (ep.error ?? 'Failed')),
                backgroundColor: ok ? AppColors.green : AppColors.red));
          }, child: Text('Submit', style: AppText.labelGreen)),
        ],
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final ep = context.watch<ExchangeProvider>();
    final ex = ep.currentExchange;
    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(backgroundColor: context.colors.bg, elevation: 0,
          scrolledUnderElevation: 0,
          title: Text('Exchange Details', style: AppText.displaySm),
          iconTheme: IconThemeData(color: context.colors.textPrimary)),
      body: ep.isLoading || ex == null
          ? const Center(child: CircularProgressIndicator(color: AppColors.green, strokeWidth: 2.5))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Progress circles
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  decoration: AppDecorations.elevatedCard(),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                    Expanded(child: _progressCircle(ex.user1.name, ex.skill1, ex.user1Progress, AppColors.green)),
                    Container(width: 44, height: 44, decoration: BoxDecoration(
                        color: context.colors.surface2, shape: BoxShape.circle,
                        border: Border.all(color: context.colors.border)),
                      child: const Icon(Icons.swap_horiz_rounded, color: AppColors.green, size: 20)),
                    Expanded(child: _progressCircle(ex.user2.name, ex.skill2, ex.user2Progress, AppColors.purpleLight)),
                  ]),
                ),
                const SizedBox(height: 24),
                
                if (ex.status == 'active')
                  _PrimaryButton(label: 'Log Hours', icon: Icons.history_edu_rounded, onTap: _showLogSheet),
                if (ex.status == 'active') ...[
                  const SizedBox(height: 12),
                  _VideoSessionBtn(ex: ex),
                ],
                if (ex.user1Progress >= 100 && ex.user2Progress >= 100 && ex.status == 'active') ...[
                  const SizedBox(height: 12),
                  GestureDetector(onTap: _showRateDialog, child: Container(
                    width: double.infinity, height: 52,
                    decoration: BoxDecoration(
                      color: context.colors.surface1,
                      border: Border.all(color: context.colors.border), borderRadius: BorderRadius.circular(50)),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.star_rounded, color: Color(0xFFFFAB40), size: 18),
                      const SizedBox(width: 8),
                      Text('Complete & Rate', style: GoogleFonts.syne(
                          fontSize: 15, fontWeight: FontWeight.w700, color: context.colors.textPrimary)),
                    ]),
                  )),
                ],
                const SizedBox(height: 32),
                Text('SESSIONS HISTORY', style: AppText.labelMuted),
                const SizedBox(height: 16),
                if (ex.sessions.isEmpty)
                  Container(width: double.infinity, padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(color: context.colors.surface1, borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: context.colors.border)),
                    child: Column(children: [
                      Container(
                        width: 50, height: 50,
                        decoration: BoxDecoration(color: context.colors.surface3, shape: BoxShape.circle),
                        child: Icon(Icons.history_rounded, size: 24, color: context.colors.textHint),
                      ),
                      const SizedBox(height: 16),
                      Text('No sessions logged', style: GoogleFonts.syne(
                          fontSize: 16, fontWeight: FontWeight.w700, color: context.colors.textPrimary)),
                      const SizedBox(height: 4),
                      Text('Log your first session above.', style: AppText.bodyMd),
                    ]))
                else
                  ...ex.sessions.asMap().entries.map((entry) {
                    final s = entry.value;
                    final isFirst = entry.key % 2 == 0;
                    final accent = isFirst ? AppColors.green : AppColors.purpleLight;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: AppDecorations.elevatedCard(),
                      child: Row(children: [
                        // Left colored border indicator
                        Container(
                          width: 4, height: 80,
                          decoration: BoxDecoration(
                            color: accent,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(18),
                              bottomLeft: Radius.circular(18),
                            ),
                            boxShadow: [BoxShadow(color: accent.withValues(alpha: 0.5), blurRadius: 4)],
                          ),
                        ),
                        Expanded(child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(children: [
                            Container(width: 46, height: 46,
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: accent.withValues(alpha: 0.2)),
                              ),
                              child: Center(child: Text('${s.duration}m', style: GoogleFonts.dmSans(
                                  fontSize: 13, fontWeight: FontWeight.w700, color: accent)))),
                            const SizedBox(width: 14),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(DateFormat('MMM d, yyyy').format(s.createdAt),
                                  style: AppText.bodySm),
                              const SizedBox(height: 4),
                              if (s.notes.isNotEmpty) Text(s.notes, style: GoogleFonts.dmSans(
                                  fontSize: 14, color: context.colors.textPrimary, height: 1.4), 
                                  maxLines: 2, overflow: TextOverflow.ellipsis)
                              else Text('No notes provided.', style: GoogleFonts.dmSans(
                                  fontSize: 14, color: context.colors.textHint, fontStyle: FontStyle.italic)),
                            ])),
                          ]),
                        )),
                      ]),
                    );
                  }),
              ]),
            ),
      // FAB: Log Session instead of Start
      floatingActionButton: (ex != null && ex.status == 'active') ? Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.green,
          border: Border.all(color: AppColors.green),
        ),
        child: FloatingActionButton(
          onPressed: _showLogSheet,
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add_rounded, color: Colors.black, size: 28),
        ),
      ) : null,
    );
  }

  Widget _progressCircle(String name, String skill, double prog, Color color) {
    return Column(children: [
      SizedBox(width: 96, height: 96, child: Stack(alignment: Alignment.center, children: [
        // Glow
        Container(
          width: 96, height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: color.withValues(alpha: 0.12), blurRadius: 24, spreadRadius: 0)],
          ),
        ),
        SizedBox(
          width: 96, height: 96,
          child: CircularProgressIndicator(
            value: (prog / 100).clamp(0.0, 1.0),
            strokeWidth: 6,
            strokeCap: StrokeCap.round,
            backgroundColor: context.colors.surface3,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
        Column(mainAxisSize: MainAxisSize.min, children: [
          Text('${prog.toStringAsFixed(0)}%', style: GoogleFonts.syne(
              fontSize: 18, fontWeight: FontWeight.w800, color: context.colors.textPrimary, letterSpacing: -0.5)),
        ]),
      ])),
      const SizedBox(height: 12),
      Text(name.toUpperCase(), style: AppText.labelMuted, maxLines: 1, overflow: TextOverflow.ellipsis),
      const SizedBox(height: 2),
      Text(skill, style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: context.colors.textPrimary), textAlign: TextAlign.center),
    ]);
  }
}

class _PrimaryButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;
  const _PrimaryButton({required this.label, this.icon, required this.onTap});
  @override
  State<_PrimaryButton> createState() => _PBState();
}
class _PBState extends State<_PrimaryButton> {
  bool _p = false;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTapDown: (_) => setState(() => _p = true),
    onTapUp: (_) { setState(() => _p = false); widget.onTap(); },
    onTapCancel: () => setState(() => _p = false),
    child: AnimatedScale(scale: _p ? 0.97 : 1.0, duration: const Duration(milliseconds: 120),
      child: Container(width: double.infinity, height: 52,
        decoration: BoxDecoration(
          color: AppColors.green.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: AppColors.green.withValues(alpha: 0.3)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          if (widget.icon != null) ...[Icon(widget.icon, color: AppColors.green, size: 18), const SizedBox(width: 8)],
          Text(widget.label, style: GoogleFonts.syne(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.green)),
        ]))));
}

class _VideoSessionBtn extends StatefulWidget {
  final dynamic ex;
  const _VideoSessionBtn({required this.ex});
  @override
  State<_VideoSessionBtn> createState() => _VideoBtnState();
}

class _VideoBtnState extends State<_VideoSessionBtn> {
  bool _p = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _p = true),
      onTapUp: (_) async {
        setState(() => _p = false);
        final statuses = await [Permission.camera, Permission.microphone].request();
        final granted = statuses[Permission.camera]!.isGranted &&
            statuses[Permission.microphone]!.isGranted;
        if (!context.mounted) return;
        if (granted) {
          final auth = context.read<AuthProvider>();
          final currentUserId = auth.currentUser?.id ?? '';
          final partner = widget.ex.user1.id == currentUserId ? widget.ex.user2 : widget.ex.user1;
          Navigator.push(context, MaterialPageRoute(
            builder: (_) => VideoCallScreen(
              channelName: widget.ex.id,
              partnerName: partner.name,
              partnerInitial: partner.name.isNotEmpty ? partner.name[0].toUpperCase() : '?',
            ),
          ));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Camera and microphone permission required', style: AppText.bodyMd),
            backgroundColor: context.colors.surface3,
          ));
        }
      },
      onTapCancel: () => setState(() => _p = false),
      child: AnimatedScale(scale: _p ? 0.97 : 1.0, duration: const Duration(milliseconds: 120),
        child: Container(
          width: double.infinity, height: 52,
          decoration: BoxDecoration(
            color: AppColors.purple,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: AppColors.purple),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.videocam_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text('Start Video Call',
                style: GoogleFonts.syne(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: -0.2)),
          ]),
        ),
      ),
    );
  }
}
