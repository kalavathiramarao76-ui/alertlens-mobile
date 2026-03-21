import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../theme/app_theme.dart';
import '../providers/app_provider.dart';
import '../providers/favorites_provider.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/result_card.dart';

class CorrelateScreen extends StatefulWidget {
  const CorrelateScreen({super.key});

  @override
  State<CorrelateScreen> createState() => _CorrelateScreenState();
}

class _CorrelateScreenState extends State<CorrelateScreen> {
  final List<TextEditingController> _controllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  void _addAlert() {
    setState(() {
      _controllers.add(TextEditingController());
    });
  }

  void _removeAlert(int index) {
    if (_controllers.length > 2) {
      setState(() {
        _controllers[index].dispose();
        _controllers.removeAt(index);
      });
    }
  }

  void _correlate() {
    final alerts = _controllers
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    if (alerts.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter at least 2 alerts')),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    context.read<AppProvider>().correlateAlerts(alerts);
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final favorites = context.watch<FavoritesProvider>();
    final result = provider.lastCorrelation;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Correlate Alerts'),
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
            Text(
              'Paste multiple alerts to find correlations and root causes',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),

            // Alert inputs
            ...List.generate(_controllers.length, (i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'ALERT ${i + 1}',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const Spacer(),
                        if (_controllers.length > 2)
                          InkWell(
                            onTap: () => _removeAlert(i),
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: AppColors.textMuted,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: TextField(
                        controller: _controllers[i],
                        maxLines: 4,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 12,
                          color: AppColors.textPrimary,
                          height: 1.5,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Paste alert ${i + 1}...',
                          hintStyle: GoogleFonts.jetBrainsMono(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(14),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),

            // Add alert button
            OutlinedButton.icon(
              onPressed: _addAlert,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Another Alert'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 44),
              ),
            ),
            const SizedBox(height: 16),

            // Correlate button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: provider.isLoading ? null : _correlate,
                icon: const Icon(Icons.hub, size: 20),
                label: const Text('Correlate Alerts'),
              ),
            ),
            const SizedBox(height: 24),

            // Loading
            if (provider.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: LoadingIndicator(message: 'Correlating alerts with AI'),
              ),

            // Results
            if (result != null && !provider.isLoading) ...[
              Text(
                'CORRELATION ANALYSIS',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),

              // Root cause
              ResultCard(
                title: 'Root Cause Analysis',
                icon: Icons.search,
                iconColor: AppColors.error,
                isFavorite: favorites.isCorrelationFavorite(result.id),
                onFavorite: () => favorites.toggleCorrelationFavorite(result),
                onShare: () {
                  Share.share(
                    'Alert Correlation Analysis:\n\n'
                    'Root Cause: ${result.rootCause}\n\n'
                    'Summary: ${result.correlationSummary}\n\n'
                    'Impact: ${result.impactAssessment}',
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.error.withOpacity(0.2)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.gps_fixed, color: AppColors.error, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              result.rootCause,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: AppColors.textPrimary,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Summary
              ResultCard(
                title: 'Correlation Summary',
                icon: Icons.hub,
                iconColor: AppColors.warning,
                child: Text(
                  result.correlationSummary,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    height: 1.6,
                  ),
                ),
              ),

              // Related services
              ResultCard(
                title: 'Related Services',
                icon: Icons.account_tree,
                iconColor: AppColors.k8sBlue,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: result.relatedServices.map((s) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.k8sBlue.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.k8sBlue.withOpacity(0.3)),
                      ),
                      child: Text(
                        s,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 12,
                          color: AppColors.k8sBlue,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Impact
              ResultCard(
                title: 'Impact Assessment',
                icon: Icons.warning_amber,
                iconColor: AppColors.warning,
                child: Text(
                  result.impactAssessment,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    height: 1.6,
                  ),
                ),
              ),

              // Recommendations
              ResultCard(
                title: 'Recommendations',
                icon: Icons.lightbulb_outline,
                iconColor: AppColors.success,
                child: Column(
                  children: result.recommendations.asMap().entries.map((e) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Center(
                              child: Text(
                                '${e.key + 1}',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.success,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              e.value,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppColors.textPrimary,
                                height: 1.4,
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
