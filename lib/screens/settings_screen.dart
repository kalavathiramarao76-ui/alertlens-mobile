import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/settings_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/app_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _endpointController;
  late TextEditingController _modelController;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>();
    _endpointController = TextEditingController(text: settings.endpoint);
    _modelController = TextEditingController(text: settings.model);
  }

  @override
  void dispose() {
    _endpointController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  void _saveEndpoint() {
    final settings = context.read<SettingsProvider>();
    settings.setEndpoint(_endpointController.text.trim());
    context.read<AppProvider>().updateAIConfig(
          endpoint: _endpointController.text.trim(),
        );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Endpoint saved')),
    );
  }

  void _saveModel() {
    final settings = context.read<SettingsProvider>();
    settings.setModel(_modelController.text.trim());
    context.read<AppProvider>().updateAIConfig(
          model: _modelController.text.trim(),
        );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Model saved')),
    );
  }

  void _clearAllData() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Clear All Data',
          style: GoogleFonts.inter(color: AppColors.textPrimary),
        ),
        content: Text(
          'This will clear all favorites, settings, and cached data. This action cannot be undone.',
          style: GoogleFonts.inter(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<SettingsProvider>().clearAllData();
              context.read<FavoritesProvider>().clearAll();
              _endpointController.text = 'http://localhost:11434';
              _modelController.text = 'llama3';
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All data cleared')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings'),
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
            // AI Configuration
            _SectionHeader(title: 'AI CONFIGURATION'),
            const SizedBox(height: 12),

            _SettingCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'API Endpoint',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ollama or compatible API endpoint URL',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _endpointController,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                          ),
                          decoration: InputDecoration(
                            hintText: 'http://localhost:11434',
                            hintStyle: GoogleFonts.jetBrainsMono(
                              fontSize: 13,
                              color: AppColors.textMuted,
                            ),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _saveEndpoint,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            _SettingCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Model',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'LLM model name (e.g., llama3, mistral, gemma)',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _modelController,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                          ),
                          decoration: InputDecoration(
                            hintText: 'llama3',
                            hintStyle: GoogleFonts.jetBrainsMono(
                              fontSize: 13,
                              color: AppColors.textMuted,
                            ),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _saveModel,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),
            _SectionHeader(title: 'PREFERENCES'),
            const SizedBox(height: 12),

            _SettingCard(
              child: SwitchListTile(
                title: Text(
                  'Haptic Feedback',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  'Vibrate on interactions',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
                value: settings.hapticFeedback,
                onChanged: (v) => settings.setHapticFeedback(v),
                activeColor: AppColors.k8sBlue,
                contentPadding: EdgeInsets.zero,
              ),
            ),

            const SizedBox(height: 28),
            _SectionHeader(title: 'DATA'),
            const SizedBox(height: 12),

            _SettingCard(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.delete_outline, color: AppColors.error, size: 22),
                ),
                title: Text(
                  'Clear All Data',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.error,
                  ),
                ),
                subtitle: Text(
                  'Remove all saved data and reset settings',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
                onTap: _clearAllData,
              ),
            ),

            const SizedBox(height: 32),

            // About
            Center(
              child: Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [AppColors.k8sBlue, AppColors.k8sBlueDark],
                      ),
                    ),
                    child: const Icon(Icons.shield, size: 24, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'AlertLens AI',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'v1.0.0',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'K8s Alert Intelligence for SRE Teams',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.jetBrainsMono(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.textMuted,
        letterSpacing: 2,
      ),
    );
  }
}

class _SettingCard extends StatelessWidget {
  final Widget child;

  const _SettingCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}
