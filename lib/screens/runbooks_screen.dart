import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../theme/app_theme.dart';
import '../providers/app_provider.dart';
import '../providers/favorites_provider.dart';
import '../utils/k8s_alert_types.dart';
import '../utils/severity_utils.dart';
import '../widgets/severity_badge.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/result_card.dart';

class RunbooksScreen extends StatefulWidget {
  const RunbooksScreen({super.key});

  @override
  State<RunbooksScreen> createState() => _RunbooksScreenState();
}

class _RunbooksScreenState extends State<RunbooksScreen> {
  String? _selectedType;

  void _generate(String alertType) {
    setState(() => _selectedType = alertType);
    context.read<AppProvider>().generateRunbook(alertType);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final favorites = context.watch<FavoritesProvider>();
    final runbook = provider.lastRunbook;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Runbooks'),
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
              'Select an alert type to generate a runbook',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),

            // Alert type grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: K8sAlertTypes.all.length,
              itemBuilder: (context, i) {
                final type = K8sAlertTypes.all[i];
                final isSelected = _selectedType == type.name;
                final color = SeverityUtils.getColor(type.defaultSeverity);

                return Material(
                  color: isSelected
                      ? AppColors.k8sBlue.withOpacity(0.15)
                      : AppColors.cardBg,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: provider.isLoading ? null : () => _generate(type.name),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? AppColors.k8sBlue : AppColors.border,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _getIconForType(type.icon),
                                size: 18,
                                color: color,
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  type.defaultSeverity,
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            type.name,
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            type.description,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: AppColors.textMuted,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Loading
            if (provider.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: LoadingIndicator(message: 'Generating runbook'),
              ),

            // Runbook result
            if (runbook != null && !provider.isLoading) ...[
              Text(
                'GENERATED RUNBOOK',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),

              ResultCard(
                title: runbook.title,
                icon: Icons.menu_book,
                iconColor: AppColors.success,
                isFavorite: favorites.isRunbookFavorite(runbook.id),
                onFavorite: () => favorites.toggleRunbookFavorite(runbook),
                onShare: () {
                  final text = 'Runbook: ${runbook.title}\n\n'
                      '${runbook.description}\n\n'
                      'Steps:\n${runbook.steps.map((s) => "${s.order}. ${s.title}\n   ${s.description}${s.command != null ? "\n   \$ ${s.command}" : ""}").join("\n\n")}';
                  Share.share(text);
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SeverityBadge(severity: runbook.severity),
                    const SizedBox(height: 12),
                    Text(
                      runbook.description,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              // Steps
              ...runbook.steps.map((step) => _StepCard(step: step)),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(String iconName) {
    final map = {
      'loop': Icons.loop,
      'memory': Icons.memory,
      'dns': Icons.dns,
      'eject': Icons.eject,
      'speed': Icons.speed,
      'data_usage': Icons.data_usage,
      'storage': Icons.storage,
      'cloud_download': Icons.cloud_download,
      'content_copy': Icons.content_copy,
      'link_off': Icons.link_off,
      'lock_clock': Icons.lock_clock,
      'disc_full': Icons.disc_full,
    };
    return map[iconName] ?? Icons.info;
  }
}

class _StepCard extends StatelessWidget {
  final dynamic step;

  const _StepCard({required this.step});

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
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.k8sBlue.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${step.order}',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.k8sBlue,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  step.title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            step.description,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          if (step.command != null && step.command!.isNotEmpty) ...[
            const SizedBox(height: 10),
            CodeBlock(code: step.command!),
          ],
        ],
      ),
    );
  }
}
