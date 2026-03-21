import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/severity_utils.dart';

class SeverityBadge extends StatelessWidget {
  final String severity;
  final bool large;

  const SeverityBadge({
    super.key,
    required this.severity,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = SeverityUtils.getColor(severity);
    final label = SeverityUtils.getLabel(severity);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 16 : 10,
        vertical: large ? 8 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(large ? 8 : 6),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            SeverityUtils.getIcon(severity),
            color: color,
            size: large ? 18 : 14,
          ),
          const SizedBox(width: 6),
          Text(
            '${severity.toUpperCase()} $label',
            style: GoogleFonts.jetBrainsMono(
              fontSize: large ? 14 : 11,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
