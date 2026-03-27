import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../providers/auth_provider.dart';
import '../../core/themes.dart';

const List<String> _kPopularSkills = [
  'Python', 'JavaScript', 'UI Design', 'Music', 'Photography',
  'Cooking', 'Fitness', 'English', 'Drawing', 'Video Editing',
];

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _bioController = TextEditingController();
  final _locationController = TextEditingController();
  final _skillInputOfferedController = TextEditingController();
  final _skillInputWantedController = TextEditingController();
  final List<String> _skillsOffered = [];
  final List<String> _skillsWanted = [];
  bool _obscurePassword = true;
  int _currentStep = 0;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    _skillInputOfferedController.dispose();
    _skillInputWantedController.dispose();
    super.dispose();
  }

  void _addSkill(List<String> list, TextEditingController controller) {
    final skill = controller.text.trim();
    if (skill.isNotEmpty && !list.contains(skill)) {
      setState(() { list.add(skill); controller.clear(); });
    }
  }

  void _removeSkill(List<String> list, String skill) =>
      setState(() => list.remove(skill));

  void _togglePopularSkill(List<String> list, String skill) {
    setState(() {
      if (list.contains(skill)) { list.remove(skill); } else { list.add(skill); }
    });
  }

  void _nextStep() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _currentStep = 1);
  }

  void _prevStep() => setState(() => _currentStep = 0);

  Future<void> _register() async {
    if (_skillsOffered.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one skill you can offer'), backgroundColor: AppColors.red),
      );
      return;
    }
    if (_skillsWanted.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one skill you want to learn'), backgroundColor: AppColors.red),
      );
      return;
    }
    final auth = context.read<AuthProvider>();
    final success = await auth.register(
      _nameController.text.trim(), _emailController.text.trim(),
      _passwordController.text, _skillsOffered, _skillsWanted,
      _bioController.text.trim(), _locationController.text.trim(),
    );
    if (!mounted) return;
    if (success) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error ?? 'Registration failed'), backgroundColor: AppColors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: context.colors.bg,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            // ── Step indicator ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStepCircle(0, Icons.person_outline_rounded, 'Account'),
                  _buildStepConnector(),
                  _buildStepCircle(1, Icons.auto_awesome, 'Skills'),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Create Account', style: AppText.displayMd),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _currentStep == 0 ? 'Tell us about yourself' : 'What do you want to exchange?',
                  style: AppText.bodyMd,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
                child: _currentStep == 0
                    ? SingleChildScrollView(
                        key: const ValueKey(0),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: _buildStep1(auth),
                      )
                    : SingleChildScrollView(
                        key: const ValueKey(1),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: _buildStep2(auth),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCircle(int step, IconData icon, String label) {
    final isActive = _currentStep >= step;
    final isDone = _currentStep > step;
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          width: 42, height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? AppColors.green : context.colors.surface3,
            border: Border.all(
              color: isActive ? AppColors.green.withValues(alpha: 0.3) : context.colors.border,
              width: 1.5,
            ),
            boxShadow: isActive ? [
              BoxShadow(color: AppColors.green.withValues(alpha: 0.2), blurRadius: 16, spreadRadius: 0),
            ] : null,
          ),
          child: Icon(
            isDone ? Icons.check_rounded : icon,
            size: 18, color: isActive ? Colors.black : context.colors.textHint,
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: isActive
            ? GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.green)
            : AppText.bodyXs),
      ],
    );
  }

  Widget _buildStepConnector() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 48, height: 2,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: _currentStep >= 1 ? AppColors.green.withValues(alpha: 0.5) : context.colors.border,
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }

  Widget _buildStep1(AuthProvider auth) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            style: GoogleFonts.dmSans(color: context.colors.textPrimary, fontSize: 14),
            decoration: AppDecorations.inputDecor(hint: 'Full Name', icon: Icons.person_outline_rounded),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: GoogleFonts.dmSans(color: context.colors.textPrimary, fontSize: 14),
            decoration: AppDecorations.inputDecor(hint: 'Email address', icon: Icons.mail_outline_rounded),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Email is required';
              if (!v.contains('@')) return 'Enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: GoogleFonts.dmSans(color: context.colors.textPrimary, fontSize: 14),
            decoration: AppDecorations.inputDecor(
              hint: 'Password (min 6)', icon: Icons.lock_outline_rounded,
              suffix: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: context.colors.textHint, size: 18),
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
          _PrimaryButton(label: 'Continue', onTap: _nextStep),
          const SizedBox(height: 20),
          Center(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pushReplacementNamed('/login'),
              child: RichText(
                text: TextSpan(style: AppText.bodyMd, children: [
                  const TextSpan(text: 'Already have an account?  '),
                  TextSpan(text: 'Sign In', style: AppText.labelGreen),
                ]),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildStep2(AuthProvider auth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('WHAT CAN YOU TEACH?'),
        const SizedBox(height: 10),
        _buildSkillInput(_skillInputOfferedController, _skillsOffered),
        const SizedBox(height: 10),
        _buildSelectedChips(_skillsOffered, isTeach: true),
        const SizedBox(height: 8),
        _buildPopularRow(_skillsOffered),
        const SizedBox(height: 24),
        _sectionLabel('WHAT DO YOU WANT TO LEARN?'),
        const SizedBox(height: 10),
        _buildSkillInput(_skillInputWantedController, _skillsWanted),
        const SizedBox(height: 10),
        _buildSelectedChips(_skillsWanted, isTeach: false),
        const SizedBox(height: 8),
        _buildPopularRow(_skillsWanted),
        const SizedBox(height: 24),
        TextFormField(
          controller: _bioController, maxLines: 3,
          style: GoogleFonts.dmSans(color: context.colors.textPrimary, fontSize: 14),
          decoration: AppDecorations.inputDecor(hint: 'Tell us about yourself...', icon: Icons.info_outline_rounded),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: _locationController,
          style: GoogleFonts.dmSans(color: context.colors.textPrimary, fontSize: 14),
          decoration: AppDecorations.inputDecor(hint: 'City, Country', icon: Icons.location_on_outlined),
        ),
        const SizedBox(height: 28),
        Row(children: [
          _SecondaryButton(label: 'Back', onTap: _prevStep),
          const SizedBox(width: 12),
          Expanded(
            child: _PrimaryButton(
              label: 'Create Account',
              isLoading: auth.isLoading,
              onTap: auth.isLoading ? null : _register,
            ),
          ),
        ]),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _sectionLabel(String text) {
    return Text(text, style: GoogleFonts.dmSans(
      fontSize: 11, fontWeight: FontWeight.w600, color: context.colors.textMuted,
      letterSpacing: 1.2,
    ));
  }

  Widget _buildSkillInput(TextEditingController ctrl, List<String> list) {
    return Row(children: [
      Expanded(
        child: TextFormField(
          controller: ctrl,
          style: GoogleFonts.dmSans(color: context.colors.textPrimary, fontSize: 14),
          decoration: AppDecorations.inputDecor(hint: 'Type a skill...', icon: Icons.add_rounded),
          onFieldSubmitted: (_) => _addSkill(list, ctrl),
        ),
      ),
      const SizedBox(width: 10),
      GestureDetector(
        onTap: () => _addSkill(list, ctrl),
        child: Container(
          width: 50, height: 50,
          decoration: BoxDecoration(
            color: AppColors.green,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: AppColors.green),
          ),
          child: const Icon(Icons.add_rounded, color: Colors.black, size: 22),
        ),
      ),
    ]);
  }

  Widget _buildSelectedChips(List<String> skills, {required bool isTeach}) {
    if (skills.isEmpty) return const SizedBox.shrink();
    final color = isTeach ? AppColors.green : AppColors.purple;
    final textColor = isTeach ? AppColors.green : AppColors.purpleLight;
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: skills.map((s) => GestureDetector(
        onTap: () => _removeSkill(skills, s),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.18)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(s, style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600, color: textColor)),
            const SizedBox(width: 6),
            Icon(Icons.close_rounded, size: 13, color: color.withValues(alpha: 0.5)),
          ]),
        ),
      )).toList(),
    );
  }

  Widget _buildPopularRow(List<String> targetList) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('POPULAR', style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w600,
          color: context.colors.textHint, letterSpacing: 1.0)),
      const SizedBox(height: 8),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: _kPopularSkills.map((skill) {
          final selected = targetList.contains(skill);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => _togglePopularSkill(targetList, skill),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: selected ? AppColors.green.withValues(alpha: 0.08) : context.colors.surface1,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: selected ? AppColors.green.withValues(alpha: 0.25) : context.colors.border),
                ),
                child: Text(skill, style: GoogleFonts.dmSans(fontSize: 12,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    color: selected ? AppColors.green : context.colors.textMuted)),
              ),
            ),
          );
        }).toList()),
      ),
    ]);
  }
}

class _PrimaryButton extends StatefulWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onTap;
  const _PrimaryButton({required this.label, this.isLoading = false, this.onTap});
  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}
class _PrimaryButtonState extends State<_PrimaryButton> {
  bool _p = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _p = true),
      onTapUp: (_) { setState(() => _p = false); widget.onTap?.call(); },
      onTapCancel: () => setState(() => _p = false),
      child: AnimatedScale(
        scale: _p ? 0.97 : 1.0, duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedOpacity(
          opacity: _p ? 0.85 : 1.0,
          duration: const Duration(milliseconds: 120),
          child: Container(
            width: double.infinity, height: 52,
            decoration: BoxDecoration(
              color: widget.onTap != null ? AppColors.green : context.colors.surface3,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: widget.onTap != null ? AppColors.green : context.colors.border),
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

class _SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _SecondaryButton({required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          border: Border.all(color: context.colors.border),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Center(
          child: Text(label, style: GoogleFonts.syne(
              fontSize: 14, fontWeight: FontWeight.w600, color: context.colors.textPrimary)),
        ),
      ),
    );
  }
}
