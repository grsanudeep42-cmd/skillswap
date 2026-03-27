import 'package:flutter/material.dart';
import '../core/constants.dart';
import 'package:google_fonts/google_fonts.dart';

class GradientButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final bool useGreen;
  final IconData? icon;

  const GradientButton({
    super.key,
    required this.label,
    required this.onTap,
    this.useGreen = false,
    this.icon,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedOpacity(
          opacity: _pressed ? 0.85 : 1.0,
          duration: const Duration(milliseconds: 120),
          child: Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              color: widget.useGreen ? AppColors.green : AppColors.purple,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: widget.useGreen ? AppColors.green : AppColors.purple,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon != null) ...[
                  Icon(
                    widget.icon,
                    color: widget.useGreen ? Colors.black : Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  widget.label,
                  style: GoogleFonts.syne(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: widget.useGreen ? Colors.black : Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}