import 'package:flutter/material.dart';
import '../core/constants.dart';
import 'package:google_fonts/google_fonts.dart';

class AppAvatar extends StatelessWidget {
  final String initial;
  final double size;

  const AppAvatar({super.key, required this.initial, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size + 6,
      height: size + 6,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.green.withValues(alpha: 0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.green.withValues(alpha: 0.08),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Color(0xFF6D28D9), Color(0xFF4F46E5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Text(
              initial.toUpperCase(),
              style: GoogleFonts.syne(
                fontSize: size * 0.36,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}