import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants.dart';
import '../core/themes.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final int maxLines;
  final bool obscureText;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.labelText,
    this.prefixIcon,
    this.maxLines = 1,
    this.obscureText = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null) ...[
          Text(labelText!, style: GoogleFonts.syne(
              fontSize: 14, fontWeight: FontWeight.w700, color: context.colors.textPrimary)),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          obscureText: obscureText,
          style: GoogleFonts.dmSans(color: context.colors.textPrimary, fontSize: 15),
          validator: validator,
          decoration: AppDecorations.inputDecor(
            hint: hintText,
            icon: prefixIcon ?? Icons.edit_outlined,
          ),
        ),
      ],
    );
  }
}
