import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/favorites_provider.dart';
import 'analyze_screen.dart';
import 'runbooks_screen.dart';
import 'correlate_screen.dart';
import 'severity_screen.dart';
import 'favorites_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.k8sBlue, AppColors.k8sBlueDark],
                ),
              ),
              child: const Icon(Icons.shield, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Text(
              'AlertLens AI',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'K8s Alert Intelligence',
              style: GoogleFonts.inter(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'AI-powered tools for Kubernetes alert management',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 28),

            // Quick stats
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  _StatItem(
                    label: 'Saved',
                    value: '${favorites.totalFavorites}',
                    icon: Icons.star,
                    color: AppColors.warning,
                  ),
                  _divider(),
                  _StatItem(
                    label: 'Tools',
                    value: '5',
                    icon: Icons.build,
                    color: AppColors.k8sBlue,
                  ),
                  _divider(),
                  _StatItem(
                    label: 'Alerts',
                    value: '12',
                    icon: Icons.notifications,
                    color: AppColors.success,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Tools section
            Text(
              'TOOLS',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 14),

            // Tool cards
            _ToolCard(
              icon: Icons.analytics,
              title: 'Analyze Alert',
              description: 'Paste any K8s alert for AI-powered analysis with severity classification',
              color: AppColors.k8sBlue,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AnalyzeScreen()),
              ),
            ),
            _ToolCard(
              icon: Icons.menu_book,
              title: 'Runbooks',
              description: '12 common K8s alert types with step-by-step resolution guides',
              color: AppColors.success,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RunbooksScreen()),
              ),
            ),
            _ToolCard(
              icon: Icons.hub,
              title: 'Correlate Alerts',
              description: 'Paste multiple alerts to find root causes and blast radius',
              color: AppColors.warning,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CorrelateScreen()),
              ),
            ),
            _ToolCard(
              icon: Icons.speed,
              title: 'Severity Classifier',
              description: 'Classify alert severity with AI confidence scoring',
              color: AppColors.error,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SeverityScreen()),
              ),
            ),
            _ToolCard(
              icon: Icons.star,
              title: 'Favorites',
              description: 'Saved analyses, runbooks, and correlations for quick access',
              color: AppColors.warning,
              badge: favorites.totalFavorites > 0
                  ? '${favorites.totalFavorites}'
                  : null,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoritesScreen()),
              ),
            ),

            const SizedBox(height: 24),

            // Version footer
            Center(
              child: Text(
                'AlertLens AI v1.0.0',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 36,
        color: AppColors.border,
        margin: const EdgeInsets.symmetric(horizontal: 4),
      );
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final String? badge;
  final VoidCallback onTap;

  const _ToolCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (badge != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                badge!,
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: color,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.textMuted,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
