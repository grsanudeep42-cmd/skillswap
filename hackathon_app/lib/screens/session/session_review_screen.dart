import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../providers/exchange_provider.dart';
import '../../core/themes.dart';

class SessionReviewScreen extends StatefulWidget {
  final String exchangeId;
  final String partnerName;
  final int durationSeconds;

  const SessionReviewScreen({
    super.key,
    required this.exchangeId,
    required this.partnerName,
    required this.durationSeconds,
  });

  @override
  State<SessionReviewScreen> createState() => _SessionReviewScreenState();
}

class _SessionReviewScreenState extends State<SessionReviewScreen> {
  int _rating = 0;
  bool _saving = false;
  final _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  String _formatDuration(int s) {
    final m = s ~/ 60;
    final sec = s % 60;
    return '${m}m ${sec}s';
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final ep = context.read<ExchangeProvider>();
    // Log the session duration (converted to minutes, minimum 1)
    final minutes = (widget.durationSeconds / 60).ceil().clamp(1, 9999);
    await ep.logSession(widget.exchangeId, minutes, _notesCtrl.text.trim());
    // Rate if user selected stars
    if (_rating > 0) {
      await ep.rate(widget.exchangeId, _rating, _notesCtrl.text.trim());
    }
    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.popUntil(context, (r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent, 
        elevation: 0, 
        scrolledUnderElevation: 0,
        leading: const SizedBox.shrink(), // Cannot go back easily after call ended
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            // ── Animated checkmark ──
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (context, v, child) => Transform.scale(
                scale: v,
                child: Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.green.withValues(alpha: 0.12),
                    border: Border.all(color: AppColors.green.withValues(alpha: 0.5), width: 2),
                    boxShadow: [BoxShadow(color: AppColors.green.withValues(alpha: 0.2), blurRadius: 24)],
                  ),
                  child: const Icon(Icons.check_rounded, color: AppColors.green, size: 40),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Session Complete!', style: AppText.displayLg),
            const SizedBox(height: 8),
            Text('You successfully swapped skills with ${widget.partnerName}.', style: AppText.bodyMd, textAlign: TextAlign.center),
            const SizedBox(height: 32),

            // ── Duration pill ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: AppDecorations.elevatedCard(),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: context.colors.surface3, shape: BoxShape.circle),
                  child: const Icon(Icons.timer_outlined, color: AppColors.green, size: 18),
                ),
                const SizedBox(width: 14),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('DURATION', style: AppText.labelMuted),
                  const SizedBox(height: 2),
                  Text(_formatDuration(widget.durationSeconds), style: GoogleFonts.syne(fontSize: 18, fontWeight: FontWeight.w700, color: context.colors.textPrimary)),
                ]),
              ]),
            ),
            const SizedBox(height: 48),

            // ── Star rating ──
            Align(alignment: Alignment.centerLeft,
                child: Text('RATE YOUR EXPERIENCE', style: AppText.labelMuted)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: AppDecorations.elevatedCard(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) => GestureDetector(
                  onTap: () => setState(() => _rating = i + 1),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 1.0, end: _rating > i ? 1.2 : 1.0),
                    duration: const Duration(milliseconds: 200),
                    builder: (_, scale, child) => Transform.scale(scale: scale, child: child),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        _rating > i ? Icons.star_rounded : Icons.star_border_rounded,
                        color: _rating > i ? const Color(0xFFFFAB40) : context.colors.textHint,
                        size: 36,
                      ),
                    ),
                  ),
                )),
              ),
            ),
            const SizedBox(height: 32),

            // ── Notes ──
            Align(alignment: Alignment.centerLeft,
                child: Text('SESSION NOTES (OPTIONAL)', style: AppText.labelMuted)),
            const SizedBox(height: 16),
            TextField(
              controller: _notesCtrl,
              maxLines: 4,
              style: GoogleFonts.dmSans(color: context.colors.textPrimary, fontSize: 14),
              decoration: AppDecorations.inputDecor(
                hint: 'What did you cover today?',
                icon: Icons.edit_note_rounded,
              ),
            ),
            const SizedBox(height: 48),

            // ── Save button ──
            _saving
                ? const Center(child: CircularProgressIndicator(color: AppColors.green, strokeWidth: 2.5))
                : GestureDetector(
                    onTap: _save,
                    child: Container(
                      width: double.infinity, height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.green,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: AppColors.green.withValues(alpha: 0.25), blurRadius: 20, offset: const Offset(0, 4))],
                      ),
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text('Finish Session',
                            style: GoogleFonts.syne(
                                fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black)),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, color: Colors.black, size: 18),
                      ]),
                    ),
                  ),
            const SizedBox(height: 32),
          ]),
        ),
      ),
    );
  }
}
