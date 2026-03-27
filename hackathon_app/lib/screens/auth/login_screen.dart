import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../providers/auth_provider.dart';
import '../../core/themes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      _emailController.text.trim(),
      _passwordController.text,
    );
    if (!mounted) return;
    if (success) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Login failed'),
          backgroundColor: AppColors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: context.colors.bg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 60),

                        // ── App Icon ──
                        Center(
                          child: Container(
                            width: 80, height: 80,
                            decoration: BoxDecoration(
                              color: context.colors.surface1,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(color: context.colors.border.withValues(alpha: 0.6)),
                              boxShadow: [
                                BoxShadow(color: AppColors.green.withValues(alpha: 0.08), blurRadius: 32, spreadRadius: 0),
                                BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 16, offset: const Offset(0, 6)),
                              ],
                            ),
                            child: const Icon(Icons.swap_horiz_rounded, color: AppColors.green, size: 36),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ── Title ──
                        Center(
                          child: RichText(
                            text: TextSpan(children: [
                              TextSpan(text: 'Skill', style: GoogleFonts.syne(fontSize: 30, fontWeight: FontWeight.w800, color: AppColors.green, letterSpacing: -1.0)),
                              TextSpan(text: 'Swap', style: GoogleFonts.syne(fontSize: 30, fontWeight: FontWeight.w800, color: const Color(0xFFF0F1F6), letterSpacing: -1.0)),
                            ]),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Center(
                          child: Text('Welcome back',
                              style: GoogleFonts.dmSans(fontSize: 14, color: context.colors.textMuted, letterSpacing: 0.2)),
                        ),
                        const SizedBox(height: 40),

                        // ── Email ──
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: GoogleFonts.dmSans(color: context.colors.textPrimary, fontSize: 14),
                          decoration: AppDecorations.inputDecor(
                            hint: 'Email address', icon: Icons.mail_outline_rounded,
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Email is required';
                            if (!v.contains('@')) return 'Enter a valid email';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // ── Password ──
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: GoogleFonts.dmSans(color: context.colors.textPrimary, fontSize: 14),
                          decoration: AppDecorations.inputDecor(
                            hint: 'Password', icon: Icons.lock_outline_rounded,
                            suffix: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: context.colors.textHint, size: 18,
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Password is required';
                            if (v.length < 6) return 'At least 6 characters';
                            return null;
                          },
                        ),
                        const SizedBox(height: 28),

                        // ── Login Button ──
                        _PrimaryButton(
                          label: 'Sign In',
                          isLoading: auth.isLoading,
                          onTap: auth.isLoading ? null : _login,
                        ),
                        const SizedBox(height: 48),

                        // ── Register link ──
                        Center(
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pushReplacementNamed('/register'),
                            child: RichText(
                              text: TextSpan(
                                style: AppText.bodyMd,
                                children: [
                                  const TextSpan(text: "Don't have an account?  "),
                                  TextSpan(
                                    text: 'Create Account',
                                    style: AppText.labelGreen,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Premium Primary Button ──
class _PrimaryButton extends StatefulWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onTap;
  const _PrimaryButton({required this.label, this.isLoading = false, this.onTap});
  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap?.call(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedOpacity(
          opacity: _pressed ? 0.85 : 1.0,
          duration: const Duration(milliseconds: 120),
          child: Container(
            width: double.infinity, height: 52,
            decoration: BoxDecoration(
              color: widget.onTap != null ? AppColors.green : context.colors.surface3,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: widget.onTap != null ? AppColors.green : context.colors.border,
              ),
            ),
            child: Center(
              child: widget.isLoading
                  ? const SizedBox(width: 22, height: 22,
                      child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.5))
                  : Text(widget.label, style: GoogleFonts.syne(
                      fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black, letterSpacing: -0.2)),
            ),
          ),
        ),
      ),
    );
  }
}
