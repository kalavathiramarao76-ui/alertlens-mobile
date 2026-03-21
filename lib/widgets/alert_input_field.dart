import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class AlertInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLines;
  final String? labelText;

  const AlertInputField({
    super.key,
    required this.controller,
    this.hintText = 'Paste your Kubernetes alert here...',
    this.maxLines = 8,
    this.labelText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null) ...[
          Text(
            labelText!,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 13,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: GoogleFonts.jetBrainsMono(
                fontSize: 13,
                color: AppColors.textMuted,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              suffixIcon: controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      color: AppColors.textMuted,
                      onPressed: () => controller.clear(),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
