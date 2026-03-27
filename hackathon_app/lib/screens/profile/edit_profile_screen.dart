import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../providers/auth_provider.dart';
import '../../core/themes.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _locationController;
  final _offeredCtrl = TextEditingController();
  final _wantedCtrl = TextEditingController();
  late List<String> _skillsOffered;
  late List<String> _skillsWanted;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _nameController = TextEditingController(text: user?.name ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
    _locationController = TextEditingController(text: user?.location ?? '');
    _skillsOffered = List<String>.from(user?.skillsOffered ?? []);
    _skillsWanted = List<String>.from(user?.skillsWanted ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    _offeredCtrl.dispose();
    _wantedCtrl.dispose();
    super.dispose();
  }

  void _addSkill(List<String> list, TextEditingController ctrl) {
    final s = ctrl.text.trim();
    if (s.isNotEmpty && !list.contains(s)) setState(() { list.add(s); ctrl.clear(); });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    try {
      await auth.updateProfile({
        'name': _nameController.text.trim(),
        'bio': _bioController.text.trim(),
        'location': _locationController.text.trim(),
        'skillsOffered': _skillsOffered,
        'skillsWanted': _skillsWanted,
      });
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully'), backgroundColor: AppColors.green));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppBar(
        backgroundColor: context.colors.bg, 
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('Edit Profile', style: AppText.displaySm),
        iconTheme: IconThemeData(color: context.colors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('BASIC INFO', style: AppText.labelMuted),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              style: GoogleFonts.dmSans(color: context.colors.textPrimary, fontSize: 15),
              decoration: AppDecorations.inputDecor(hint: 'Your name', icon: Icons.person_outline_rounded),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              style: GoogleFonts.dmSans(color: context.colors.textPrimary, fontSize: 15),
              decoration: AppDecorations.inputDecor(hint: 'City, Country', icon: Icons.location_on_outlined),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _bioController, maxLines: 3,
              style: GoogleFonts.dmSans(color: context.colors.textPrimary, fontSize: 15),
              decoration: AppDecorations.inputDecor(hint: 'Short bio about yourself...', icon: Icons.edit_note_rounded),
            ),
            const SizedBox(height: 32),
            
            _skillSection('SKILLS I TEACH', _skillsOffered, _offeredCtrl, true),
            const SizedBox(height: 32),
            
            _skillSection('SKILLS I\'M LEARNING', _skillsWanted, _wantedCtrl, false),
            const SizedBox(height: 40),
            
            _PrimaryButton(label: 'Save Changes', isLoading: auth.isLoading, onTap: _save),
            const SizedBox(height: 40),
          ]),
        ),
      ),
    );
  }

  Widget _skillSection(String title, List<String> skills, TextEditingController ctrl, bool isTeach) {
    final color = isTeach ? AppColors.green : AppColors.purpleLight;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: AppText.labelMuted),
      const SizedBox(height: 16),
      Row(children: [
        Expanded(child: TextFormField(
          controller: ctrl,
          style: GoogleFonts.dmSans(color: context.colors.textPrimary, fontSize: 15),
          decoration: AppDecorations.inputDecor(hint: 'Add a skill...', icon: Icons.add_rounded),
          onFieldSubmitted: (_) => _addSkill(skills, ctrl),
        )),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () => _addSkill(skills, ctrl),
          child: Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: context.colors.surface1,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: context.colors.border),
            ),
            child: Icon(Icons.check_rounded, color: context.colors.textPrimary, size: 24),
          ),
        ),
      ]),
      if (skills.isNotEmpty) ...[
        const SizedBox(height: 16),
        Wrap(spacing: 8, runSpacing: 8, children: skills.map((s) =>
          GestureDetector(
            onTap: () => setState(() => skills.remove(s)),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withValues(alpha: 0.2)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(s, style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
                const SizedBox(width: 6),
                Icon(Icons.close_rounded, size: 14, color: color.withValues(alpha: 0.7)),
              ]),
            ),
          ),
        ).toList()),
      ],
    ]);
  }
}

class _PrimaryButton extends StatefulWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onTap;
  const _PrimaryButton({required this.label, this.isLoading = false, required this.onTap});
  @override
  State<_PrimaryButton> createState() => _PBState();
}
class _PBState extends State<_PrimaryButton> {
  bool _p = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _p = true),
      onTapUp: (_) { setState(() => _p = false); widget.onTap(); },
      onTapCancel: () => setState(() => _p = false),
      child: AnimatedScale(
        scale: _p ? 0.97 : 1.0, duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity, height: 56,
          decoration: BoxDecoration(
            color: AppColors.green,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: AppColors.green),
          ),
          child: Center(child: widget.isLoading
              ? const SizedBox(width: 24, height: 24,
                  child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.5))
              : Text(widget.label, style: GoogleFonts.syne(
                  fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black))),
        ),
      ),
    );
  }
}
