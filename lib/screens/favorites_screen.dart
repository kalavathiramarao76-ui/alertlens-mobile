import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/favorites_provider.dart';
import '../utils/severity_utils.dart';
import '../widgets/severity_badge.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Favorites'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppColors.k8sBlue,
          labelColor: AppColors.k8sBlue,
          unselectedLabelColor: AppColors.textMuted,
          labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
          tabs: [
            Tab(text: 'Analyses (${favorites.favoriteAnalyses.length})'),
            Tab(text: 'Runbooks (${favorites.favoriteRunbooks.length})'),
            Tab(text: 'Correlations (${favorites.favoriteCorrelations.length})'),
            Tab(text: 'Severity (${favorites.favoriteSeverities.length})'),
          ],
        ),
      ),
      body: favorites.totalFavorites == 0
          ? _emptyState()
          : TabBarView(
              controller: _tabController,
              children: [
                // Analyses
                _buildList(
                  items: favorites.favoriteAnalyses,
                  itemBuilder: (analysis) => _FavCard(
                    title: analysis.category,
                    subtitle: analysis.summary,
                    severity: analysis.severity,
                    timestamp: analysis.timestamp,
                    onRemove: () => favorites.toggleAnalysisFavorite(analysis),
                  ),
                ),
                // Runbooks
                _buildList(
                  items: favorites.favoriteRunbooks,
                  itemBuilder: (runbook) => _FavCard(
                    title: runbook.title,
                    subtitle: runbook.description,
                    severity: runbook.severity,
                    timestamp: runbook.timestamp,
                    onRemove: () => favorites.toggleRunbookFavorite(runbook),
                  ),
                ),
                // Correlations
                _buildList(
                  items: favorites.favoriteCorrelations,
                  itemBuilder: (corr) => _FavCard(
                    title: 'Correlation (${corr.rawAlerts.length} alerts)',
                    subtitle: corr.correlationSummary,
                    severity: 'P2',
                    timestamp: corr.timestamp,
                    onRemove: () => favorites.toggleCorrelationFavorite(corr),
                  ),
                ),
                // Severities
                _buildList(
                  items: favorites.favoriteSeverities,
                  itemBuilder: (sev) => _FavCard(
                    title: '${sev.severity} Classification',
                    subtitle: sev.reasoning,
                    severity: sev.severity,
                    timestamp: sev.timestamp,
                    onRemove: () => favorites.toggleSeverityFavorite(sev),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star_border,
            size: 64,
            color: AppColors.textMuted.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'No favorites yet',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Save analyses and runbooks for quick access',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList<T>({
    required List<T> items,
    required Widget Function(T) itemBuilder,
  }) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          'No items in this category',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.textMuted,
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (_, i) => itemBuilder(items[i]),
    );
  }
}

class _FavCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String severity;
  final DateTime timestamp;
  final VoidCallback onRemove;

  const _FavCard({
    required this.title,
    required this.subtitle,
    required this.severity,
    required this.timestamp,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              SeverityBadge(severity: severity),
              const SizedBox(width: 8),
              InkWell(
                onTap: onRemove,
                child: const Icon(
                  Icons.star,
                  size: 20,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatTime(timestamp),
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${dt.month}/${dt.day}/${dt.year}';
  }
}
