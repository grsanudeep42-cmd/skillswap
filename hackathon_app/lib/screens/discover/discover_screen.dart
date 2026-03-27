import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/match_provider.dart';
import '../../models/user_model.dart';
import '../../widgets/app_avatar.dart';
import '../../widgets/skill_chip.dart';
import '../../widgets/gradient_button.dart';
import '../../core/themes.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});
  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = context.read<MatchProvider>();
      prov.fetchSuggestionsWithFallback().then((_) {
        if (!mounted) return;
        if (prov.error != null) {
          debugPrint('Discover error: ${prov.error}');
        }
        debugPrint('Suggestions count: ${prov.suggestions.length}');
        if (prov.suggestions.isNotEmpty) {
          debugPrint('First suggestion keys: ${prov.suggestions.first.keys}');
          debugPrint('First suggestion: ${prov.suggestions.first}');
        }
      });
    });
  }

  @override
  void dispose() { _searchController.dispose(); super.dispose(); }

  void _showConnectSheet(BuildContext context, dynamic user) {
    final auth = context.read<AuthProvider>();
    final matchProv = context.read<MatchProvider>();
    String? selectedOffered;
    String? selectedWanted;

    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: context.colors.surface1,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border(top: BorderSide(color: context.colors.border.withValues(alpha: 0.5))),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 36, height: 4, decoration: BoxDecoration(
                color: context.colors.borderStrong, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Text('Connect with ${user.name}', style: AppText.displaySm),
            const SizedBox(height: 20),
            Align(alignment: Alignment.centerLeft,
                child: Text('I CAN TEACH', style: AppText.labelMuted)),
            const SizedBox(height: 10),
            Wrap(spacing: 8, runSpacing: 8,
              children: (auth.currentUser?.skillsOffered ?? []).map((s) =>
                GestureDetector(
                  onTap: () => setSheetState(() => selectedOffered = s),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: selectedOffered == s
                          ? AppColors.green.withValues(alpha: 0.10)
                          : context.colors.surface3,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: selectedOffered == s
                          ? AppColors.green.withValues(alpha: 0.3) : context.colors.border),
                    ),
                    child: Text(s, style: GoogleFonts.inter(fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: selectedOffered == s ? AppColors.green : context.colors.textMuted)),
                  ),
                ),
              ).toList(),
            ),
            const SizedBox(height: 18),
            Align(alignment: Alignment.centerLeft,
                child: Text('I WANT TO LEARN', style: AppText.labelMuted)),
            const SizedBox(height: 10),
            Wrap(spacing: 8, runSpacing: 8,
              children: (user.skillsOffered as List<dynamic>).map((s) =>
                GestureDetector(
                  onTap: () => setSheetState(() => selectedWanted = s),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: selectedWanted == s
                          ? AppColors.purple.withValues(alpha: 0.10)
                          : context.colors.surface3,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: selectedWanted == s
                          ? AppColors.purple.withValues(alpha: 0.3) : context.colors.border),
                    ),
                    child: Text(s as String, style: GoogleFonts.inter(fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: selectedWanted == s ? AppColors.purpleLight : context.colors.textMuted)),
                  ),
                ),
              ).toList(),
            ),
            const SizedBox(height: 24),
            GradientButton(
              label: 'Send Request',
              onTap: () async {
                if (selectedOffered == null || selectedWanted == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Select one skill from each'), backgroundColor: AppColors.red),
                  );
                  return;
                }
                final nav = Navigator.of(context);
                await matchProv.sendRequest(user.id, selectedOffered!, selectedWanted!, 'Hi, I would like to exchange skills!');
                nav.pop();
              },
            ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final matchProv = context.watch<MatchProvider>();
    final allUsers = matchProv.suggestions
        .map((m) {
          // Handle nested user object
          final userData = (m['user'] is Map<String, dynamic>)
              ? m['user'] as Map<String, dynamic>
              : m;
          try {
            return UserModel.fromJson(userData);
          } catch (e) {
            debugPrint('Failed to parse user: $e — data: $m');
            return null;
          }
        })
        .whereType<UserModel>()
        .where((u) => u.id != auth.currentUser?.id)
        .toList();
    final categories = ['All', ...kSkillCategories];

    var filtered = allUsers;
    if (_selectedCategory != 'All') {
      filtered = filtered.where((u) =>
          u.skillsOffered.any((s) => s.toLowerCase().contains(_selectedCategory.toLowerCase()))).toList();
    }
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((u) =>
          u.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          u.skillsOffered.any((s) => s.toLowerCase().contains(_searchQuery.toLowerCase()))).toList();
    }

    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
        child: Row(children: [
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: context.colors.surface1, borderRadius: BorderRadius.circular(14),
                border: Border.all(color: context.colors.border.withValues(alpha: 0.5)),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
                style: GoogleFonts.inter(fontSize: 14, color: context.colors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Search skills or people...',
                  hintStyle: GoogleFonts.inter(fontSize: 13, color: context.colors.textHint),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 14, right: 10),
                    child: Icon(Icons.search_rounded, color: context.colors.textHint, size: 18),
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.close_rounded, color: context.colors.textHint, size: 16),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Consumer<ThemeProvider>(
            builder: (context, theme, _) => GestureDetector(
              onTap: () => theme.toggle(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 52, height: 28,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: theme.isDark
                    ? AppColors.green.withValues(alpha: 0.15)
                    : AppColors.green,
                  border: Border.all(
                    color: AppColors.green.withValues(alpha: 0.5), width: 1)),
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  alignment: theme.isDark
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.all(3),
                    width: 20, height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.isDark
                        ? AppColors.green
                        : Colors.white),
                    child: Icon(
                      theme.isDark
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                      size: 11,
                      color: theme.isDark
                        ? context.colors.bg
                        : AppColors.green),
                  ),
                ),
              ),
            ),
          ),
        ]),
      ),
      const SizedBox(height: 12),
      // Category chips
      SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final cat = categories[i];
            final isActive = _selectedCategory == cat;
            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.green : context.colors.surface1,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isActive ? AppColors.green : context.colors.border),
                ),
                child: Text(cat, style: GoogleFonts.inter(fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isActive ? Colors.black : context.colors.textMuted)),
              ),
            );
          },
        ),
      ),
      const SizedBox(height: 16),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Align(alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Text('People near you', style: GoogleFonts.inter(
                    fontSize: 15, fontWeight: FontWeight.w700, color: context.colors.textPrimary, letterSpacing: -0.3)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.green.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('${filtered.length}', style: GoogleFonts.inter(
                      fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.green)),
                ),
              ],
            )),
      ),
      const SizedBox(height: 12),
      Expanded(
        child: matchProv.isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.green, strokeWidth: 2.5))
            : (matchProv.error != null && filtered.isEmpty)
                ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(
                        color: context.colors.surface1,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: context.colors.border),
                      ),
                      child: Icon(Icons.wifi_off_rounded, size: 24, color: context.colors.textHint),
                    ),
                    const SizedBox(height: 16),
                    Text('Could not load users', style: AppText.displaySm),
                    const SizedBox(height: 4),
                    Text(matchProv.error ?? '', style: AppText.bodyMd),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () => context.read<MatchProvider>().fetchSuggestionsWithFallback(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.green,
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(color: AppColors.green),
                        ),
                        child: Text('Retry', style: GoogleFonts.inter(
                            fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black)),
                      ),
                    ),
                  ]))
                : filtered.isEmpty
                    ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Container(
                          width: 56, height: 56,
                          decoration: BoxDecoration(
                            color: context.colors.surface1,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: context.colors.border),
                          ),
                          child: Icon(Icons.search_off_rounded, size: 24, color: context.colors.textHint),
                        ),
                        const SizedBox(height: 16),
                        Text('No users found', style: AppText.displaySm),
                        const SizedBox(height: 4),
                        Text('Try a different search or category', style: AppText.bodyMd),
                      ]))
                    : RefreshIndicator(
                        color: AppColors.green, backgroundColor: context.colors.surface2,
                        onRefresh: () => matchProv.fetchSuggestionsWithFallback(),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: filtered.length,
                      itemBuilder: (ctx, i) {
                        final user = filtered[i];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: context.colors.border),
                            color: context.colors.surface1,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Row(children: [
                                AppAvatar(initial: user.name.isNotEmpty ? user.name[0] : '?', size: 44),
                                const SizedBox(width: 14),
                                Expanded(child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(user.name, style: AppText.displaySm),
                                    const SizedBox(height: 2),
                                    if (user.location.isNotEmpty)
                                      Row(children: [
                                        Icon(Icons.location_on_outlined, size: 11, color: context.colors.textHint),
                                        const SizedBox(width: 4),
                                        Text(user.location, style: AppText.bodyXs),
                                      ]),
                                  ],
                                )),
                              ]),
                              if (user.skillsOffered.isNotEmpty) ...[
                                const SizedBox(height: 14),
                                Text('TEACHES', style: AppText.labelMuted),
                                const SizedBox(height: 8),
                                Wrap(spacing: 8, runSpacing: 8,
                                  children: user.skillsOffered.take(4).map((s) =>
                                      SkillChip(label: s, type: ChipType.teach)).toList()),
                              ],
                              if (user.skillsWanted.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Text('WANTS TO LEARN', style: AppText.labelMuted),
                                const SizedBox(height: 8),
                                Wrap(spacing: 8, runSpacing: 8,
                                  children: user.skillsWanted.take(4).map((s) =>
                                      SkillChip(label: s, type: ChipType.learn)).toList()),
                              ],
                              const SizedBox(height: 16),
                              GradientButton(
                                label: 'Connect',
                                useGreen: true,
                                onTap: () => _showConnectSheet(context, user),
                              ),
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
