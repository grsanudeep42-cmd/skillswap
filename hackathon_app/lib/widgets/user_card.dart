import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../widgets/app_avatar.dart';
import '../widgets/skill_chip.dart';
import '../widgets/gradient_button.dart';
import '../core/themes.dart';

class UserCard extends StatelessWidget {
  final dynamic user;
  final VoidCallback? onConnect;

  const UserCard({super.key, required this.user, this.onConnect});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.glassCard,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          AppAvatar(initial: user.name.isNotEmpty ? user.name[0] : '?', size: 48),
          const SizedBox(width: 14),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user.name, style: AppText.displaySm),
              if (user.location != null && user.location.isNotEmpty) ...[
                const SizedBox(height: 2),
                Row(children: [
                  Icon(Icons.location_on_outlined, size: 12, color: context.colors.textHint),
                  const SizedBox(width: 4),
                  Text(user.location, style: AppText.bodySm),
                ]),
              ],
            ],
          )),
        ]),
        if (user.skillsOffered != null && (user.skillsOffered as List).isNotEmpty) ...[
          const SizedBox(height: 14),
          Text('Skills Offered', style: AppText.bodySm),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8,
            children: (user.skillsOffered as List).take(4).map((s) =>
                SkillChip(label: s.toString(), type: ChipType.teach)).toList()),
        ],
        const SizedBox(height: 16),
        if (onConnect != null)
          GradientButton(label: 'Connect', onTap: onConnect!),
      ]),
    );
  }
}
