import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/alert_model.dart';

class AIService {
  String _endpoint;
  String _model;

  AIService({
    String endpoint = 'http://localhost:11434',
    String model = 'llama3',
  })  : _endpoint = endpoint,
        _model = model;

  void updateConfig({String? endpoint, String? model}) {
    if (endpoint != null) _endpoint = endpoint;
    if (model != null) _model = model;
  }

  // ---------- Analyze Alert ----------
  Future<AlertAnalysis> analyzeAlert(String alertText) async {
    try {
      final response = await _callAI(
        'You are an expert SRE AI assistant. Analyze this Kubernetes alert and provide:\n'
        '1. A concise summary (2-3 sentences)\n'
        '2. Severity level (P0=Critical, P1=High, P2=Medium, P3=Low, P4=Info)\n'
        '3. Category (e.g., Pod, Node, Network, Storage, Memory, CPU, Deployment)\n'
        '4. 3-5 specific action items\n\n'
        'Respond in JSON format:\n'
        '{"summary":"...","severity":"P0-P4","category":"...","actionItems":["..."],"confidenceScore":0.0-1.0}\n\n'
        'Alert:\n$alertText',
      );

      final parsed = _parseJsonResponse(response);
      return AlertAnalysis(
        id: _generateId(),
        rawInput: alertText,
        summary: parsed['summary'] ?? _generateFallbackSummary(alertText),
        severity: parsed['severity'] ?? _classifySeverityLocal(alertText),
        severityLevel: _severityToLevel(parsed['severity'] ?? _classifySeverityLocal(alertText)),
        category: parsed['category'] ?? _detectCategory(alertText),
        actionItems: List<String>.from(parsed['actionItems'] ?? _generateFallbackActions(alertText)),
        timestamp: DateTime.now(),
        confidenceScore: (parsed['confidenceScore'] ?? 0.85).toDouble(),
      );
    } catch (e) {
      return _fallbackAnalysis(alertText);
    }
  }

  // ---------- Generate Runbook ----------
  Future<RunbookEntry> generateRunbook(String alertType) async {
    try {
      final response = await _callAI(
        'You are an expert SRE. Generate a detailed runbook for this Kubernetes alert type: "$alertType".\n\n'
        'Provide:\n'
        '1. Title\n'
        '2. Description (1-2 sentences)\n'
        '3. 5-8 resolution steps, each with title, description, and optional kubectl command\n'
        '4. Severity level\n\n'
        'Respond in JSON:\n'
        '{"title":"...","description":"...","severity":"P0-P4","steps":[{"order":1,"title":"...","description":"...","command":"kubectl ..."}]}',
      );

      final parsed = _parseJsonResponse(response);
      return RunbookEntry(
        id: _generateId(),
        alertType: alertType,
        title: parsed['title'] ?? 'Runbook: $alertType',
        description: parsed['description'] ?? 'Resolution steps for $alertType',
        severity: parsed['severity'] ?? 'P2',
        steps: (parsed['steps'] as List?)
                ?.asMap()
                .entries
                .map((e) => RunbookStep(
                      order: e.key + 1,
                      title: e.value['title'] ?? 'Step ${e.key + 1}',
                      description: e.value['description'] ?? '',
                      command: e.value['command'],
                    ))
                .toList() ??
            _fallbackRunbookSteps(alertType),
        timestamp: DateTime.now(),
      );
    } catch (e) {
      return _fallbackRunbook(alertType);
    }
  }

  // ---------- Correlate Alerts ----------
  Future<CorrelationResult> correlateAlerts(List<String> alerts) async {
    final alertsText = alerts.asMap().entries.map((e) => 'Alert ${e.key + 1}: ${e.value}').join('\n\n');
    try {
      final response = await _callAI(
        'You are an expert SRE. Analyze these multiple Kubernetes alerts and find correlations:\n\n'
        '$alertsText\n\n'
        'Provide:\n'
        '1. Correlation summary\n'
        '2. Probable root cause\n'
        '3. Related services/components\n'
        '4. Impact assessment\n'
        '5. Recommendations\n\n'
        'JSON format:\n'
        '{"correlationSummary":"...","rootCause":"...","relatedServices":["..."],"impactAssessment":"...","recommendations":["..."]}',
      );

      final parsed = _parseJsonResponse(response);
      return CorrelationResult(
        id: _generateId(),
        rawAlerts: alerts,
        correlationSummary: parsed['correlationSummary'] ?? 'Multiple related alerts detected',
        rootCause: parsed['rootCause'] ?? 'Analysis requires further investigation',
        relatedServices: List<String>.from(parsed['relatedServices'] ?? ['kubernetes']),
        impactAssessment: parsed['impactAssessment'] ?? 'Potential service degradation',
        recommendations: List<String>.from(parsed['recommendations'] ?? ['Investigate logs', 'Check cluster health']),
        timestamp: DateTime.now(),
      );
    } catch (e) {
      return _fallbackCorrelation(alerts);
    }
  }

  // ---------- Classify Severity ----------
  Future<SeverityClassification> classifySeverity(String alertText) async {
    try {
      final response = await _callAI(
        'You are an expert SRE. Classify the severity of this Kubernetes alert.\n\n'
        'Severity levels:\n'
        '- P0 (Critical): Complete outage, data loss, security breach\n'
        '- P1 (High): Major feature broken, significant degradation\n'
        '- P2 (Medium): Partial impact, workaround available\n'
        '- P3 (Low): Minor issue, no immediate impact\n'
        '- P4 (Info): Informational, no action needed\n\n'
        'Alert: $alertText\n\n'
        'JSON format:\n'
        '{"severity":"P0-P4","confidence":0.0-1.0,"reasoning":"...","indicators":["..."]}',
      );

      final parsed = _parseJsonResponse(response);
      final severity = parsed['severity'] ?? _classifySeverityLocal(alertText);
      return SeverityClassification(
        id: _generateId(),
        rawInput: alertText,
        severity: severity,
        severityLevel: _severityToLevel(severity),
        confidence: (parsed['confidence'] ?? 0.82).toDouble(),
        reasoning: parsed['reasoning'] ?? 'Classification based on alert keywords and context',
        indicators: List<String>.from(parsed['indicators'] ?? _extractIndicators(alertText)),
        timestamp: DateTime.now(),
      );
    } catch (e) {
      return _fallbackSeverity(alertText);
    }
  }

  // ---------- API Call ----------
  Future<String> _callAI(String prompt) async {
    final uri = Uri.parse('$_endpoint/api/generate');
    final response = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'model': _model,
            'prompt': prompt,
            'stream': false,
            'options': {'temperature': 0.3},
          }),
        )
        .timeout(const Duration(seconds: 60));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['response'] ?? '';
    }
    throw Exception('API error: ${response.statusCode}');
  }

  Map<String, dynamic> _parseJsonResponse(String response) {
    try {
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(response);
      if (jsonMatch != null) {
        return jsonDecode(jsonMatch.group(0)!);
      }
    } catch (_) {}
    return {};
  }

  // ---------- Fallback / Local Analysis ----------
  String _generateId() {
    final r = Random();
    return '${DateTime.now().millisecondsSinceEpoch}_${r.nextInt(9999)}';
  }

  int _severityToLevel(String severity) {
    switch (severity.toUpperCase()) {
      case 'P0':
        return 0;
      case 'P1':
        return 1;
      case 'P2':
        return 2;
      case 'P3':
        return 3;
      default:
        return 4;
    }
  }

  String _classifySeverityLocal(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('oomkilled') ||
        lower.contains('crashloopbackoff') ||
        lower.contains('critical') ||
        lower.contains('outage') ||
        lower.contains('down') ||
        lower.contains('unreachable')) return 'P0';
    if (lower.contains('high') ||
        lower.contains('error') ||
        lower.contains('failed') ||
        lower.contains('not ready') ||
        lower.contains('evicted')) return 'P1';
    if (lower.contains('warning') ||
        lower.contains('degraded') ||
        lower.contains('high cpu') ||
        lower.contains('high memory') ||
        lower.contains('pending')) return 'P2';
    if (lower.contains('info') ||
        lower.contains('scaling') ||
        lower.contains('scheduled')) return 'P3';
    return 'P4';
  }

  String _detectCategory(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('pod') || lower.contains('container') || lower.contains('crashloop')) return 'Pod';
    if (lower.contains('node') || lower.contains('kubelet')) return 'Node';
    if (lower.contains('network') || lower.contains('dns') || lower.contains('ingress')) return 'Network';
    if (lower.contains('pvc') || lower.contains('storage') || lower.contains('volume')) return 'Storage';
    if (lower.contains('memory') || lower.contains('oom')) return 'Memory';
    if (lower.contains('cpu') || lower.contains('throttl')) return 'CPU';
    if (lower.contains('deploy') || lower.contains('replica')) return 'Deployment';
    return 'General';
  }

  String _generateFallbackSummary(String text) {
    final category = _detectCategory(text);
    final severity = _classifySeverityLocal(text);
    return 'A $severity $category alert has been detected in the Kubernetes cluster. '
        'The alert indicates a potential issue that requires investigation. '
        'Review the alert details and follow the recommended action items.';
  }

  List<String> _generateFallbackActions(String text) {
    final category = _detectCategory(text);
    return [
      'Check the affected ${category.toLowerCase()} status with kubectl',
      'Review recent events: kubectl get events --sort-by=.lastTimestamp',
      'Examine logs for the affected component',
      'Verify cluster resource utilization',
      'Escalate if issue persists after initial investigation',
    ];
  }

  List<String> _extractIndicators(String text) {
    final indicators = <String>[];
    final keywords = ['error', 'critical', 'warning', 'failed', 'oom', 'crash', 'timeout', 'unavailable', 'pending', 'high'];
    for (final kw in keywords) {
      if (text.toLowerCase().contains(kw)) indicators.add('Contains "$kw" keyword');
    }
    if (indicators.isEmpty) indicators.add('No critical keywords detected');
    return indicators;
  }

  AlertAnalysis _fallbackAnalysis(String alertText) {
    final severity = _classifySeverityLocal(alertText);
    return AlertAnalysis(
      id: _generateId(),
      rawInput: alertText,
      summary: _generateFallbackSummary(alertText),
      severity: severity,
      severityLevel: _severityToLevel(severity),
      category: _detectCategory(alertText),
      actionItems: _generateFallbackActions(alertText),
      timestamp: DateTime.now(),
      confidenceScore: 0.7,
    );
  }

  RunbookEntry _fallbackRunbook(String alertType) {
    return RunbookEntry(
      id: _generateId(),
      alertType: alertType,
      title: 'Runbook: $alertType',
      description: 'Standard operating procedure for resolving $alertType alerts in Kubernetes.',
      severity: 'P2',
      steps: _fallbackRunbookSteps(alertType),
      timestamp: DateTime.now(),
    );
  }

  List<RunbookStep> _fallbackRunbookSteps(String alertType) {
    return [
      RunbookStep(order: 1, title: 'Identify Affected Resources', description: 'List all resources related to the alert.', command: 'kubectl get pods -A | grep -i error'),
      RunbookStep(order: 2, title: 'Check Events', description: 'Review recent cluster events for context.', command: 'kubectl get events --sort-by=.lastTimestamp -A'),
      RunbookStep(order: 3, title: 'Examine Logs', description: 'Pull logs from the affected component.', command: 'kubectl logs <pod-name> -n <namespace> --tail=100'),
      RunbookStep(order: 4, title: 'Describe Resource', description: 'Get detailed resource info including conditions.', command: 'kubectl describe pod <pod-name> -n <namespace>'),
      RunbookStep(order: 5, title: 'Check Resource Utilization', description: 'Verify CPU/memory usage across nodes.', command: 'kubectl top nodes && kubectl top pods -A'),
      RunbookStep(order: 6, title: 'Apply Fix', description: 'Based on findings, apply the appropriate remediation (restart, scale, patch).', command: 'kubectl rollout restart deployment/<name> -n <namespace>'),
      RunbookStep(order: 7, title: 'Verify Resolution', description: 'Confirm the issue is resolved and services are healthy.', command: 'kubectl get pods -A -o wide | grep -v Running'),
    ];
  }

  CorrelationResult _fallbackCorrelation(List<String> alerts) {
    return CorrelationResult(
      id: _generateId(),
      rawAlerts: alerts,
      correlationSummary: 'Multiple alerts detected across the cluster. These alerts may share a common root cause such as resource exhaustion, network issues, or a cascading failure.',
      rootCause: 'Potential cascading failure detected. The alerts suggest resource contention or a failing upstream dependency.',
      relatedServices: ['kubernetes-apiserver', 'kubelet', 'kube-proxy'],
      impactAssessment: 'Service degradation likely. ${alerts.length} related alerts suggest a systemic issue requiring immediate attention.',
      recommendations: [
        'Check cluster-wide resource utilization',
        'Review recent deployments or configuration changes',
        'Examine network connectivity between nodes',
        'Verify control plane health',
        'Consider rolling back recent changes if applicable',
      ],
      timestamp: DateTime.now(),
    );
  }

  SeverityClassification _fallbackSeverity(String alertText) {
    final severity = _classifySeverityLocal(alertText);
    return SeverityClassification(
      id: _generateId(),
      rawInput: alertText,
      severity: severity,
      severityLevel: _severityToLevel(severity),
      confidence: 0.75,
      reasoning: 'Classification based on keyword analysis of the alert text. Key indicators were matched against known severity patterns.',
      indicators: _extractIndicators(alertText),
      timestamp: DateTime.now(),
    );
  }
}
