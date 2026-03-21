import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SeverityUtils {
  static Color getColor(String severity) {
    switch (severity.toUpperCase()) {
      case 'P0':
        return AppColors.p0Critical;
      case 'P1':
        return AppColors.p1High;
      case 'P2':
        return AppColors.p2Medium;
      case 'P3':
        return AppColors.p3Low;
      case 'P4':
        return AppColors.p4Info;
      default:
        return AppColors.p4Info;
    }
  }

  static String getLabel(String severity) {
    switch (severity.toUpperCase()) {
      case 'P0':
        return 'CRITICAL';
      case 'P1':
        return 'HIGH';
      case 'P2':
        return 'MEDIUM';
      case 'P3':
        return 'LOW';
      case 'P4':
        return 'INFO';
      default:
        return 'UNKNOWN';
    }
  }

  static IconData getIcon(String severity) {
    switch (severity.toUpperCase()) {
      case 'P0':
        return Icons.error;
      case 'P1':
        return Icons.warning_amber;
      case 'P2':
        return Icons.info;
      case 'P3':
        return Icons.check_circle_outline;
      case 'P4':
        return Icons.info_outline;
      default:
        return Icons.help_outline;
    }
  }

  static String getEmoji(String severity) {
    switch (severity.toUpperCase()) {
      case 'P0':
        return '!!!';
      case 'P1':
        return '!! ';
      case 'P2':
        return '!  ';
      case 'P3':
        return '-  ';
      case 'P4':
        return '.  ';
      default:
        return '?  ';
    }
  }
}
