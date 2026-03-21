import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../theme/app_theme.dart';
import '../providers/app_provider.dart';
import '../providers/favorites_provider.dart';
import '../utils/severity_utils.dart';
import '../widgets/severity_badge.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/alert_input_field.dart';
import '../widgets/result_card.dart';

class SeverityScreen extends StatefulWidget {
  const SeverityScreen({super.key});

  @override
  State<SeverityScreen> createState() => _SeverityScreenState();
}

class _SeverityScreenState extends State<SeverityScreen> {
  final _controller = TextEditingController();

  void _classify() {
    if (_controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please paste an alert first')),
      );
      return;
    }
    FocusScope.of(context).unfocus();
    context.read<AppProvider>().classifySeverity(_controller.text.trim());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final favorites = context.watch<FavoritesProvider>();
    final result = provider.lastSeverity;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Severity Classifier'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Severity legend
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SEVERITY LEVELS',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...['P0', 'P1', 'P2', 'P3', 'P4'].map((s) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: SeverityUtils.getColor(s),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '$s - ${SeverityUtils.getLabel(s)}',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Input
            AlertInputField(
              controller: _controller,
              labelText: 'ALERT INPUT',
              hintText: 'Paste alert to classify severity...',
              maxLines: 6,
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: provider.isLoading ? null : _classify,
                icon: const Icon(Icons.speed, size: 20),
                label: const Text('Classify Severity'),
              ),
            ),
            const SizedBox(height: 24),

            // Loading
            if (provider.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: LoadingIndicator(message: 'Classifying severity'),
              ),

            // Result
            if (result != null && !provider.isLoading) ...[
              Text(
                'CLASSIFICATION RESULT',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 16),

              // Big severity display
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: SeverityUtils.getColor(result.severity)
                            .withOpacity(0.15),
                        border: Border.all(
                          color: SeverityUtils.getColor(result.severity)
                              .withOpacity(0.4),
                          width: 3,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          result.severity,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: SeverityUtils.getColor(result.severity),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SeverityBadge(severity: result.severity, large: true),
                    const SizedBox(height: 8),

                    // Confidence bar
                    Container(
                      width: 200,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Confidence',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: result.confidence,
                              backgroundColor: AppColors.surfaceLight,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                SeverityUtils.getColor(result.severity),
                              ),
                              minHeight: 8,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${(result.confidence * 100).toStringAsFixed(1)}%',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Reasoning
              ResultCard(
                title: 'Reasoning',
                icon: Icons.psychology,
                iconColor: AppColors.info,
                isFavorite: favorites.isSeverityFavorite(result.id),
                onFavorite: () => favorites.toggleSeverityFavorite(result),
                onShare: () => Share.share(
                  'Severity Classification:\n\n'
                  '${result.severity} - ${SeverityUtils.getLabel(result.severity)}\n'
                  'Confidence: ${(result.confidence * 100).toStringAsFixed(1)}%\n\n'
                  '${result.reasoning}',
                ),
                child: Text(
                  result.reasoning,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    height: 1.6,
                  ),
                ),
              ),

              // Indicators
              ResultCard(
                title: 'Severity Indicators',
                icon: Icons.flag,
                iconColor: AppColors.warning,
                child: Column(
                  children: result.indicators.map((indicator) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.arrow_right,
                            size: 18,
                            color: SeverityUtils.getColor(result.severity),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              indicator,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
