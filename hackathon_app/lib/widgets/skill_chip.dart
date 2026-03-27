import 'package:flutter/material.dart';
import '../core/constants.dart';
import 'package:google_fonts/google_fonts.dart';

enum ChipType { teach, learn }

class SkillChip extends StatelessWidget {
  final String label;
  final ChipType type;

  const SkillChip({
    super.key,
    required this.label,
    this.type = ChipType.teach,
  });

  @override
  Widget build(BuildContext context) {
    final isTeach = type == ChipType.teach;
    final color = isTeach ? AppColors.green : AppColors.purple;
    final textColor = isTeach ? AppColors.green : AppColors.purpleLight;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5, height: 5,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}