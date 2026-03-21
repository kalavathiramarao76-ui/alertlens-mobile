import 'package:flutter/material.dart';
import '../models/alert_model.dart';
import '../services/ai_service.dart';

class AppProvider extends ChangeNotifier {
  final AIService _aiService = AIService();
  bool _isLoading = false;
  String? _error;

  // Analysis results
  AlertAnalysis? _lastAnalysis;
  RunbookEntry? _lastRunbook;
  CorrelationResult? _lastCorrelation;
  SeverityClassification? _lastSeverity;

  // History
  final List<AlertAnalysis> _analysisHistory = [];
  final List<RunbookEntry> _runbookHistory = [];
  final List<CorrelationResult> _correlationHistory = [];
  final List<SeverityClassification> _severityHistory = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  AlertAnalysis? get lastAnalysis => _lastAnalysis;
  RunbookEntry? get lastRunbook => _lastRunbook;
  CorrelationResult? get lastCorrelation => _lastCorrelation;
  SeverityClassification? get lastSeverity => _lastSeverity;
  List<AlertAnalysis> get analysisHistory => _analysisHistory;
  List<RunbookEntry> get runbookHistory => _runbookHistory;
  List<CorrelationResult> get correlationHistory => _correlationHistory;
  List<SeverityClassification> get severityHistory => _severityHistory;

  void updateAIConfig({String? endpoint, String? model}) {
    _aiService.updateConfig(endpoint: endpoint, model: model);
  }

  Future<void> analyzeAlert(String alertText) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _lastAnalysis = await _aiService.analyzeAlert(alertText);
      _analysisHistory.insert(0, _lastAnalysis!);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> generateRunbook(String alertType) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _lastRunbook = await _aiService.generateRunbook(alertType);
      _runbookHistory.insert(0, _lastRunbook!);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> correlateAlerts(List<String> alerts) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _lastCorrelation = await _aiService.correlateAlerts(alerts);
      _correlationHistory.insert(0, _lastCorrelation!);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> classifySeverity(String alertText) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _lastSeverity = await _aiService.classifySeverity(alertText);
      _severityHistory.insert(0, _lastSeverity!);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
