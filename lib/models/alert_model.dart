class AlertAnalysis {
  final String id;
  final String rawInput;
  final String summary;
  final String severity;
  final int severityLevel; // 0-4 for P0-P4
  final String category;
  final List<String> actionItems;
  final DateTime timestamp;
  final double confidenceScore;
  bool isFavorite;

  AlertAnalysis({
    required this.id,
    required this.rawInput,
    required this.summary,
    required this.severity,
    required this.severityLevel,
    required this.category,
    required this.actionItems,
    required this.timestamp,
    this.confidenceScore = 0.0,
    this.isFavorite = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'rawInput': rawInput,
        'summary': summary,
        'severity': severity,
        'severityLevel': severityLevel,
        'category': category,
        'actionItems': actionItems,
        'timestamp': timestamp.toIso8601String(),
        'confidenceScore': confidenceScore,
        'isFavorite': isFavorite,
      };

  factory AlertAnalysis.fromJson(Map<String, dynamic> json) => AlertAnalysis(
        id: json['id'] ?? '',
        rawInput: json['rawInput'] ?? '',
        summary: json['summary'] ?? '',
        severity: json['severity'] ?? 'P4',
        severityLevel: json['severityLevel'] ?? 4,
        category: json['category'] ?? 'Unknown',
        actionItems: List<String>.from(json['actionItems'] ?? []),
        timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
        confidenceScore: (json['confidenceScore'] ?? 0.0).toDouble(),
        isFavorite: json['isFavorite'] ?? false,
      );
}

class RunbookEntry {
  final String id;
  final String alertType;
  final String title;
  final String description;
  final List<RunbookStep> steps;
  final String severity;
  final DateTime timestamp;
  bool isFavorite;

  RunbookEntry({
    required this.id,
    required this.alertType,
    required this.title,
    required this.description,
    required this.steps,
    required this.severity,
    required this.timestamp,
    this.isFavorite = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'alertType': alertType,
        'title': title,
        'description': description,
        'steps': steps.map((s) => s.toJson()).toList(),
        'severity': severity,
        'timestamp': timestamp.toIso8601String(),
        'isFavorite': isFavorite,
      };

  factory RunbookEntry.fromJson(Map<String, dynamic> json) => RunbookEntry(
        id: json['id'] ?? '',
        alertType: json['alertType'] ?? '',
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        steps: (json['steps'] as List?)
                ?.map((s) => RunbookStep.fromJson(s))
                .toList() ??
            [],
        severity: json['severity'] ?? 'P3',
        timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
        isFavorite: json['isFavorite'] ?? false,
      );
}

class RunbookStep {
  final int order;
  final String title;
  final String description;
  final String? command;

  RunbookStep({
    required this.order,
    required this.title,
    required this.description,
    this.command,
  });

  Map<String, dynamic> toJson() => {
        'order': order,
        'title': title,
        'description': description,
        'command': command,
      };

  factory RunbookStep.fromJson(Map<String, dynamic> json) => RunbookStep(
        order: json['order'] ?? 0,
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        command: json['command'],
      );
}

class CorrelationResult {
  final String id;
  final List<String> rawAlerts;
  final String correlationSummary;
  final String rootCause;
  final List<String> relatedServices;
  final String impactAssessment;
  final List<String> recommendations;
  final DateTime timestamp;
  bool isFavorite;

  CorrelationResult({
    required this.id,
    required this.rawAlerts,
    required this.correlationSummary,
    required this.rootCause,
    required this.relatedServices,
    required this.impactAssessment,
    required this.recommendations,
    required this.timestamp,
    this.isFavorite = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'rawAlerts': rawAlerts,
        'correlationSummary': correlationSummary,
        'rootCause': rootCause,
        'relatedServices': relatedServices,
        'impactAssessment': impactAssessment,
        'recommendations': recommendations,
        'timestamp': timestamp.toIso8601String(),
        'isFavorite': isFavorite,
      };

  factory CorrelationResult.fromJson(Map<String, dynamic> json) =>
      CorrelationResult(
        id: json['id'] ?? '',
        rawAlerts: List<String>.from(json['rawAlerts'] ?? []),
        correlationSummary: json['correlationSummary'] ?? '',
        rootCause: json['rootCause'] ?? '',
        relatedServices: List<String>.from(json['relatedServices'] ?? []),
        impactAssessment: json['impactAssessment'] ?? '',
        recommendations: List<String>.from(json['recommendations'] ?? []),
        timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
        isFavorite: json['isFavorite'] ?? false,
      );
}

class SeverityClassification {
  final String id;
  final String rawInput;
  final String severity;
  final int severityLevel;
  final double confidence;
  final String reasoning;
  final List<String> indicators;
  final DateTime timestamp;
  bool isFavorite;

  SeverityClassification({
    required this.id,
    required this.rawInput,
    required this.severity,
    required this.severityLevel,
    required this.confidence,
    required this.reasoning,
    required this.indicators,
    required this.timestamp,
    this.isFavorite = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'rawInput': rawInput,
        'severity': severity,
        'severityLevel': severityLevel,
        'confidence': confidence,
        'reasoning': reasoning,
        'indicators': indicators,
        'timestamp': timestamp.toIso8601String(),
        'isFavorite': isFavorite,
      };

  factory SeverityClassification.fromJson(Map<String, dynamic> json) =>
      SeverityClassification(
        id: json['id'] ?? '',
        rawInput: json['rawInput'] ?? '',
        severity: json['severity'] ?? 'P4',
        severityLevel: json['severityLevel'] ?? 4,
        confidence: (json['confidence'] ?? 0.0).toDouble(),
        reasoning: json['reasoning'] ?? '',
        indicators: List<String>.from(json['indicators'] ?? []),
        timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
        isFavorite: json['isFavorite'] ?? false,
      );
}
