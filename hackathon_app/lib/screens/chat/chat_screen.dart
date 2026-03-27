import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../core/constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../models/user_model.dart';
import '../../widgets/app_avatar.dart';
import '../../core/themes.dart';

class ChatScreen extends StatefulWidget {
  final String matchId;
  final UserModel otherUser;
  const ChatScreen({super.key, required this.matchId, required this.otherUser});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    final chat = context.read<ChatProvider>();
    final currentUserId = context.read<AuthProvider>().currentUser?.id ?? '';
    chat.setCurrentUser(currentUserId);
    chat.loadHistory(widget.matchId);
    chat.joinChat(widget.matchId);
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    // Use an isolated approach or schedule microtask if this throws in dispose, but
    // usually leaving chat here is fine if provider is still accessible.
    // Given the constraints to not change logic, we will keep it as is.
    super.dispose();
  }
  
  // Note: Since we can't reliably read provider in dispose without context errors in some setups,
  // we follow the original logic exactly. We must override deactivate or keep it in dispose.
  @override
  void deactivate() {
    context.read<ChatProvider>().leaveChat();
    super.deactivate();
  }

  void _scrollToBottom() {
    if (!_scrollCtrl.hasClients) return;
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  void _send() {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    context.read<ChatProvider>().sendMessage(widget.matchId, widget.otherUser.id, text);
    _msgCtrl.clear();
    context.read<ChatProvider>().setTyping(widget.matchId, false);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final chat = context.watch<ChatProvider>();
    final myId = auth.currentUser?.id ?? '';
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(
        backgroundColor: context.colors.bg, 
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: context.colors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(children: [
          AppAvatar(initial: widget.otherUser.name.isNotEmpty ? widget.otherUser.name[0] : '?', size: 36),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.otherUser.name, style: GoogleFonts.syne(
                fontSize: 16, fontWeight: FontWeight.w700, color: context.colors.textPrimary, letterSpacing: -0.2)),
            Row(children: [
              _OnlineDot(isOnline: widget.otherUser.isOnline),
              const SizedBox(width: 6),
              Text(widget.otherUser.isOnline ? 'Online' : 'Offline',
                  style: GoogleFonts.dmSans(
                      fontSize: 12, fontWeight: FontWeight.w600,
                      color: widget.otherUser.isOnline ? AppColors.green : context.colors.textHint)),
            ]),
          ]),
        ]),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: context.colors.borderStrong)),
      ),
      body: Column(children: [
        Expanded(
          child: chat.isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.green, strokeWidth: 2.5))
              : chat.messages.isEmpty
                  ? _emptyChat()
                  : ListView.builder(
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.all(20),
                      itemCount: chat.messages.length,
                      itemBuilder: (ctx, i) => _bubble(chat.messages[i], myId),
                    ),
        ),
        if (chat.isTyping) _typingRow(),
        _inputBar(auth),
      ]),
    );
  }

  Widget _emptyChat() => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    Container(
      width: 64, height: 64,
      decoration: BoxDecoration(color: context.colors.surface2, shape: BoxShape.circle),
      child: Icon(Icons.chat_bubble_outline_rounded, size: 28, color: context.colors.textHint),
    ),
    const SizedBox(height: 16),
    Text('Your conversation starts here', style: AppText.displaySm),
    const SizedBox(height: 4),
    Text('Say hello and start skill swapping!', style: AppText.bodyMd),
  ]));

  Widget _bubble(dynamic msg, String myId) {
    final isMine = msg.sender.id == myId || msg.sender.id == 'me';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isMine ? AppColors.green : context.colors.surface1,
              border: Border.all(color: isMine ? AppColors.green : context.colors.border),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isMine ? 16 : 4),
                bottomRight: Radius.circular(isMine ? 4 : 16),
              ),
              boxShadow: isMine ? [BoxShadow(color: AppColors.green.withValues(alpha: 0.15), blurRadius: 10, offset: const Offset(0, 4))] : null,
            ),
            child: Text(msg.content, style: GoogleFonts.dmSans(
                fontSize: 15, color: isMine ? Colors.black : context.colors.textPrimary, height: 1.4)),
          ),
          const SizedBox(height: 6),
          Text(timeago.format(msg.createdAt),
              style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w500, color: context.colors.textMuted)),
        ],
      ),
    );
  }

  Widget _typingRow() => Padding(
    padding: const EdgeInsets.only(left: 20, bottom: 12),
    child: Row(children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: context.colors.surface1, 
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
          ),
          border: Border.all(color: context.colors.border),
        ),
        child: const Row(mainAxisSize: MainAxisSize.min, children: [
          _StaticTypingDot(), _StaticTypingDot(), _StaticTypingDot(),
        ]),
      ),
    ]),
  );

  Widget _inputBar(AuthProvider auth) => Container(
    decoration: BoxDecoration(
      color: context.colors.bg,
      border: Border(top: BorderSide(color: context.colors.borderStrong)),
    ),
    padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
    child: Row(children: [
      AppAvatar(initial: auth.currentUser?.name.isNotEmpty == true ? auth.currentUser!.name[0] : '?', size: 36),
      const SizedBox(width: 12),
      Expanded(child: Container(
        decoration: BoxDecoration(color: context.colors.surface1, borderRadius: BorderRadius.circular(24),
            border: Border.all(color: context.colors.border)),
        child: TextField(
          controller: _msgCtrl,
          style: GoogleFonts.dmSans(fontSize: 14, color: context.colors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Message...', 
            hintStyle: AppText.bodyMd,
            border: InputBorder.none, 
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          ),
          onChanged: (v) => context.read<ChatProvider>().setTyping(widget.matchId, v.isNotEmpty),
          onSubmitted: (_) => _send(),
        ),
      )),
      const SizedBox(width: 12),
      _SendBtn(onTap: _send),
    ]),
  );
}

class _SendBtn extends StatefulWidget {
  final VoidCallback onTap;
  const _SendBtn({required this.onTap});
  @override
  State<_SendBtn> createState() => _SendBtnState();
}
class _SendBtnState extends State<_SendBtn> {
  bool _p = false;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTapDown: (_) => setState(() => _p = true),
    onTapUp: (_) { setState(() => _p = false); widget.onTap(); },
    onTapCancel: () => setState(() => _p = false),
    child: AnimatedScale(scale: _p ? 0.92 : 1.0, duration: const Duration(milliseconds: 100),
      child: Container(width: 44, height: 44,
        decoration: BoxDecoration(
          color: AppColors.green,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: AppColors.green.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 4))],
        ),
        child: const Icon(Icons.arrow_upward_rounded, color: Colors.black, size: 20))),
  );
}

class _OnlineDot extends StatefulWidget {
  final bool isOnline;
  const _OnlineDot({required this.isOnline});
  @override
  State<_OnlineDot> createState() => _OnlineDotState();
}
class _OnlineDotState extends State<_OnlineDot> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    if (!widget.isOnline) return Container(width: 7, height: 7,
        decoration: BoxDecoration(shape: BoxShape.circle, color: context.colors.textHint));
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Container(
        width: 7, height: 7,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.green,
          boxShadow: [
            BoxShadow(
              color: AppColors.green.withValues(alpha: 0.2 + 0.3 * _c.value),
              blurRadius: 4 + 6 * _c.value,
              spreadRadius: 2 * _c.value,
            ),
          ],
        ),
      ),
    );
  }
}

class _StaticTypingDot extends StatelessWidget {
  const _StaticTypingDot();
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 2), width: 6, height: 6,
    decoration: BoxDecoration(color: context.colors.textHint, shape: BoxShape.circle));
}
