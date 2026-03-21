# AlertLens AI

**K8s Alert Intelligence for SRE Teams**

A Flutter mobile application that provides AI-powered Kubernetes alert analysis, runbook generation, alert correlation, and severity classification.

## Features

### Analyze Alert
Paste any Kubernetes alert (JSON or text format) and get:
- AI-powered summary with severity badge (P0-P4 color-coded)
- Category detection (Pod, Node, Network, Storage, CPU, Memory, Deployment)
- Actionable resolution steps
- Confidence scoring

### Runbooks
12 common K8s alert types with auto-generated runbooks:
- CrashLoopBackOff, OOMKilled, NodeNotReady, PodEvicted
- HighCPUUsage, HighMemoryUsage, PVCPending, ImagePullBackOff
- DeploymentReplicasMismatch, EndpointNotReady, CertificateExpiring, DiskPressure

Each runbook includes step-by-step instructions with kubectl commands.

### Correlate Alerts
Paste multiple alerts to find:
- Root cause analysis
- Related services and blast radius
- Impact assessment
- Prioritized recommendations

### Severity Classifier
Classify alert severity with:
- P0 (Critical) through P4 (Info) classification
- AI confidence scoring with visual indicator
- Detailed reasoning and severity indicators

### Favorites
Save any analysis, runbook, correlation, or severity classification for quick reference.

### Settings
- Configure AI endpoint (Ollama or compatible API)
- Select LLM model
- Toggle haptic feedback
- Clear all data

## Tech Stack

- **Flutter** with Material 3 dark theme
- **Provider** for state management
- **HTTP** for AI API communication
- **SharedPreferences** for local persistence
- **Google Fonts** (Inter + JetBrains Mono)
- **Flutter Animate** for animations
- **Share Plus** for sharing results

## Design

- Material 3 dark theme
- K8s blue (#326CE5) accent
- Terminal-inspired monospace for code blocks
- Severity color coding: Red (P0), Orange (P1), Yellow (P2), Blue (P3), Gray (P4)

## Getting Started

```bash
flutter pub get
flutter run
```

## Configuration

The app connects to an Ollama-compatible API endpoint. Configure in Settings:
- Default endpoint: `http://localhost:11434`
- Default model: `llama3`

The app includes intelligent fallback analysis when the AI endpoint is unavailable.

## Project Structure

```
lib/
  main.dart                    # App entry point
  theme/app_theme.dart         # Material 3 dark theme
  models/alert_model.dart      # Data models
  services/ai_service.dart     # AI API service with fallbacks
  providers/
    app_provider.dart          # App state management
    settings_provider.dart     # Settings persistence
    favorites_provider.dart    # Favorites management
  screens/
    splash_screen.dart         # Animated splash
    onboarding_screen.dart     # 3-page SRE onboarding
    home_screen.dart           # Tool cards dashboard
    analyze_screen.dart        # Alert analysis
    runbooks_screen.dart       # Runbook generation
    correlate_screen.dart      # Alert correlation
    severity_screen.dart       # Severity classification
    favorites_screen.dart      # Saved items
    settings_screen.dart       # App settings
  widgets/
    severity_badge.dart        # P0-P4 severity badge
    loading_indicator.dart     # AI processing indicator
    alert_input_field.dart     # Terminal-style input
    result_card.dart           # Result display cards
  utils/
    severity_utils.dart        # Severity helpers
    k8s_alert_types.dart       # 12 K8s alert definitions
```
