import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../theme/app_theme.dart';
import '../providers/app_provider.dart';
import '../providers/favorites_provider.dart';
import '../widgets/severity_badge.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/alert_input_field.dart';
import '../widgets/result_card.dart';

class AnalyzeScreen extends StatefulWidget {
  const AnalyzeScreen({super.key});

  @override
  State<AnalyzeScreen> createState() => _AnalyzeScreenState();
}

class _AnalyzeScreenState extends State<AnalyzeScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  final _sampleAlerts = [
    '{"alert":"KubePodCrashLooping","labels":{"pod":"api-gateway-7d9f8c6b5-x2k9p","namespace":"production","severity":"critical"},"annotations":{"summary":"Pod is crash looping","description":"Pod production/api-gateway-7d9f8c6b5-x2k9p is restarting 5 times / 10 minutes"}}',
    'FIRING: [OOMKilled] Container payment-service in pod payment-svc-5c8d7f9b4-m3n7q namespace=production exceeded memory limit 512Mi, killed by OOM killer at 2024-01-15T14:23:00Z',
    'WARNING: Node ip-10-0-1-42.ec2.internal NotReady for 5m. Kubelet stopped posting status. Last heartbeat: 3m ago. Pods affected: 23',
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _analyze() {
    if (_controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please paste an alert first')),
      );
      return;
    }
    FocusScope.of(context).unfocus();
    context.read<AppProvider>().analyzeAlert(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final favorites = context.watch<FavoritesProvider>();
    final analysis = provider.lastAnalysis;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Analyze Alert'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Input
            AlertInputField(
              controller: _controller,
              labelText: 'ALERT INPUT',
              hintText: 'Paste Kubernetes alert (JSON or text)...',
            ),
            const SizedBox(height: 12),

            // Sample alerts
            Text(
              'SAMPLE ALERTS',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _sampleAlerts.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) => ActionChip(
                  label: Text(
                    ['CrashLoop', 'OOMKilled', 'NodeNotReady'][i],
                    style: GoogleFonts.jetBrainsMono(fontSize: 11),
                  ),
                  backgroundColor: AppColors.surfaceLight,
                  side: const BorderSide(color: AppColors.border),
                  onPressed: () {
                    _controller.text = _sampleAlerts[i];
                    setState(() {});
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Analyze button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: provider.isLoading ? null : _analyze,
                icon: const Icon(Icons.analytics, size: 20),
                label: const Text('Analyze Alert'),
              ),
            ),
            const SizedBox(height: 24),

            // Loading
            if (provider.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: LoadingIndicator(message: 'Analyzing alert with AI'),
              ),

            // Error
            if (provider.error != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.error.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.error, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        provider.error!,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Results
            if (analysis != null && !provider.isLoading) ...[
              Text(
                'ANALYSIS RESULT',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),

              // Severity badge
              Center(child: SeverityBadge(severity: analysis.severity, large: true)),
              const SizedBox(height: 16),

              // Summary
              ResultCard(
                title: 'Summary',
                icon: Icons.summarize,
                isFavorite: favorites.isAnalysisFavorite(analysis.id),
                onFavorite: () => favorites.toggleAnalysisFavorite(analysis),
                onCopy: () {
                  Clipboard.setData(ClipboardData(text: analysis.summary));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Copied to clipboard')),
                  );
                },
                onShare: () => Share.share(
                  'AlertLens Analysis:\n\n'
                  'Severity: ${analysis.severity}\n'
                  'Category: ${analysis.category}\n\n'
                  '${analysis.summary}\n\n'
                  'Action Items:\n${analysis.actionItems.map((a) => "- $a").join("\n")}',
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _InfoChip(label: analysis.category, color: AppColors.k8sBlue),
                        const SizedBox(width: 8),
                        _InfoChip(
                          label: 'Confidence: ${(analysis.confidenceScore * 100).toStringAsFixed(0)}%',
                          color: AppColors.success,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      analysis.summary,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),

              // Action items
              ResultCard(
                title: 'Action Items',
                icon: Icons.checklist,
                iconColor: AppColors.warning,
                child: Column(
                  children: analysis.actionItems.asMap().entries.map((e) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: AppColors.k8sBlue.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Center(
                              child: Text(
                                '${e.key + 1}',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.k8sBlue,
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

class _InfoChip extends StatelessWidget {
  final String label;
  final Color color;

  const _InfoChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: GoogleFonts.jetBrainsMono(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
