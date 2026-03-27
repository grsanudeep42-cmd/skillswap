import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/constants.dart';
import '../../widgets/app_avatar.dart';
import 'session_review_screen.dart';
import '../../core/themes.dart';

const _kAppId = 'e7e799f30bce469aa1b0f18dfd6d03e0';

class VideoCallScreen extends StatefulWidget {
  final String channelName;
  final String partnerName;
  final String partnerInitial;

  const VideoCallScreen({
    super.key,
    required this.channelName,
    required this.partnerName,
    required this.partnerInitial,
  });

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  int? _remoteUid;
  bool _localUserJoined = false;
  bool _muted = false;
  bool _videoOff = false;
  bool _speakerOn = true;
  int _seconds = 0;
  late RtcEngine _engine;
  Timer? _timer;

  // For local video preview drag
  double _localTop = 100;
  double _localRight = 20;

  @override
  void initState() {
    super.initState();
    _initAgora();
  }

  Future<void> _initAgora() async {
    await [Permission.camera, Permission.microphone].request();
    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(appId: _kAppId));
    _engine.registerEventHandler(RtcEngineEventHandler(
      onJoinChannelSuccess: (conn, elapsed) =>
          setState(() => _localUserJoined = true),
      onUserJoined: (conn, remoteUid, elapsed) =>
          setState(() => _remoteUid = remoteUid),
      onUserOffline: (conn, remoteUid, reason) =>
          setState(() => _remoteUid = null),
    ));
    await _engine.enableVideo();
    await _engine.startPreview();
    await _engine.joinChannel(
      token: '',
      channelId: widget.channelName,
      uid: 0,
      options: const ChannelMediaOptions(
        channelProfile: ChannelProfileType.channelProfileCommunication,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
      ),
    );
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _seconds++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _engine.leaveChannel();
    _engine.release();
    super.dispose();
  }

  String _formatTime(int s) {
    if (s < 3600) {
      return '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';
    }
    return '${s ~/ 3600}:${((s % 3600) ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';
  }

  void _showEndCallDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (_) => AlertDialog(
        backgroundColor: context.colors.surface1,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: context.colors.border)),
        title: Text('End Session?', style: AppText.displaySm),
        content: Text('Are you sure you want to end this connection?', style: AppText.bodyMd),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: AppText.bodyLg),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(context);
              _engine.leaveChannel();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => SessionReviewScreen(
                    exchangeId: widget.channelName,
                    partnerName: widget.partnerName,
                    durationSeconds: _seconds,
                  ),
                ),
              );
            },
            child: Text('End Session', style: GoogleFonts.syne(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black, // true black for video bounds
      body: Stack(children: [
        // ── Remote video (full screen) ──
        _remoteUid != null
            ? AgoraVideoView(
                controller: VideoViewController.remote(
                  rtcEngine: _engine,
                  canvas: VideoCanvas(uid: _remoteUid),
                  connection: RtcConnection(channelId: widget.channelName),
                ),
              )
            : Container(
                color: context.colors.bg,
                child: Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: context.colors.borderStrong)),
                      child: AppAvatar(initial: widget.partnerInitial, size: 84),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Waiting for ${widget.partnerName}',
                      style: AppText.displaySm,
                    ),
                    const SizedBox(height: 8),
                    Text('Connecting...', style: AppText.bodyMd),
                  ]),
                ),
              ),

        // ── Top overlay ──
        Positioned(
          top: 0, left: 0, right: 0,
          child: Container(
            height: 120,
            color: Colors.black.withValues(alpha: 0.28),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(width: 8),
                    Column(mainAxisSize: MainAxisSize.min, children: [
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.green.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.green.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.green, shape: BoxShape.circle)),
                            const SizedBox(width: 6),
                            Text(_formatTime(_seconds), style: GoogleFonts.dmSans(
                                fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.green)),
                          ],
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ── Local video (draggable top-right) ──
        Positioned(
          top: _localTop,
          right: _localRight,
          child: GestureDetector(
            onPanUpdate: (d) => setState(() {
              _localTop = (_localTop + d.delta.dy).clamp(0, size.height - 200);
              _localRight = (_localRight - d.delta.dx).clamp(0, size.width - 130);
            }),
            child: Container(
              width: 110, height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.colors.borderStrong, width: 2),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 16)],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: _localUserJoined && !_videoOff
                    ? AgoraVideoView(
                        controller: VideoViewController(
                          rtcEngine: _engine,
                          canvas: const VideoCanvas(uid: 0),
                        ),
                      )
                    : Container(
                        color: context.colors.surface2,
                        child: Center(
                          child: Icon(Icons.videocam_off_rounded, color: context.colors.textHint, size: 28),
                        ),
                      ),
              ),
            ),
          ),
        ),

        // ── Bottom controls ──
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: Container(
            padding: const EdgeInsets.only(top: 40, bottom: 40),
            color: Colors.black.withValues(alpha: 0.32),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Camera toggle
                  _ControlBtn(
                    size: 52,
                    bg: _videoOff
                        ? AppColors.red.withValues(alpha: 0.2)
                        : Colors.white.withValues(alpha: 0.12),
                    border: _videoOff ? Border.all(color: AppColors.red.withValues(alpha: 0.5)) : null,
                    icon: _videoOff ? Icons.videocam_off_rounded : Icons.videocam_rounded,
                    iconColor: _videoOff ? AppColors.red : Colors.white,
                    onTap: () {
                      _engine.muteLocalVideoStream(!_videoOff);
                      setState(() => _videoOff = !_videoOff);
                    },
                  ),
                  const SizedBox(width: 16),
                  // Mute
                  _ControlBtn(
                    size: 52,
                    bg: _muted
                        ? AppColors.red.withValues(alpha: 0.2)
                        : Colors.white.withValues(alpha: 0.12),
                    border: _muted ? Border.all(color: AppColors.red.withValues(alpha: 0.5)) : null,
                    icon: _muted ? Icons.mic_off_rounded : Icons.mic_rounded,
                    iconColor: _muted ? AppColors.red : Colors.white,
                    onTap: () {
                      _engine.muteLocalAudioStream(!_muted);
                      setState(() => _muted = !_muted);
                    },
                  ),
                  const SizedBox(width: 16),
                  
                  // Speaker
                  _ControlBtn(
                    size: 52,
                    bg: Colors.white.withValues(alpha: 0.12),
                    icon: _speakerOn ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                    iconColor: Colors.white,
                    onTap: () {
                      _engine.setEnableSpeakerphone(!_speakerOn);
                      setState(() => _speakerOn = !_speakerOn);
                    },
                  ),
                  
                  const SizedBox(width: 24),
                  
                  // End Call Pill
                  GestureDetector(
                    onTap: _showEndCallDialog,
                    child: Container(
                      height: 52,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: AppColors.red,
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [BoxShadow(color: AppColors.red.withValues(alpha: 0.3), blurRadius: 16)],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.call_end_rounded, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text('End', style: GoogleFonts.syne(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

class _ControlBtn extends StatelessWidget {
  final double size;
  final Color bg;
  final IconData icon;
  final Color iconColor;
  final BoxBorder? border;
  final VoidCallback onTap;

  const _ControlBtn({
    required this.size,
    required this.bg,
    required this.icon,
    required this.iconColor,
    this.border,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: size, height: size,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: border,
      ),
      child: Center(child: Icon(icon, color: iconColor, size: 22)),
    ),
  );
}
