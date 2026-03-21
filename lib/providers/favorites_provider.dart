import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/alert_model.dart';

class FavoritesProvider extends ChangeNotifier {
  List<AlertAnalysis> _favoriteAnalyses = [];
  List<RunbookEntry> _favoriteRunbooks = [];
  List<CorrelationResult> _favoriteCorrelations = [];
  List<SeverityClassification> _favoriteSeverities = [];

  List<AlertAnalysis> get favoriteAnalyses => _favoriteAnalyses;
  List<RunbookEntry> get favoriteRunbooks => _favoriteRunbooks;
  List<CorrelationResult> get favoriteCorrelations => _favoriteCorrelations;
  List<SeverityClassification> get favoriteSeverities => _favoriteSeverities;

  int get totalFavorites =>
      _favoriteAnalyses.length +
      _favoriteRunbooks.length +
      _favoriteCorrelations.length +
      _favoriteSeverities.length;

  Future<void> init() async {
    await _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();

    final analysesJson = prefs.getStringList('fav_analyses') ?? [];
    _favoriteAnalyses = analysesJson
        .map((j) => AlertAnalysis.fromJson(jsonDecode(j)))
        .toList();

    final runbooksJson = prefs.getStringList('fav_runbooks') ?? [];
    _favoriteRunbooks = runbooksJson
        .map((j) => RunbookEntry.fromJson(jsonDecode(j)))
        .toList();

    final correlationsJson = prefs.getStringList('fav_correlations') ?? [];
    _favoriteCorrelations = correlationsJson
        .map((j) => CorrelationResult.fromJson(jsonDecode(j)))
        .toList();

    final severitiesJson = prefs.getStringList('fav_severities') ?? [];
    _favoriteSeverities = severitiesJson
        .map((j) => SeverityClassification.fromJson(jsonDecode(j)))
        .toList();

    notifyListeners();
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('fav_analyses',
        _favoriteAnalyses.map((a) => jsonEncode(a.toJson())).toList());
    await prefs.setStringList('fav_runbooks',
        _favoriteRunbooks.map((r) => jsonEncode(r.toJson())).toList());
    await prefs.setStringList('fav_correlations',
        _favoriteCorrelations.map((c) => jsonEncode(c.toJson())).toList());
    await prefs.setStringList('fav_severities',
        _favoriteSeverities.map((s) => jsonEncode(s.toJson())).toList());
  }

  Future<void> toggleAnalysisFavorite(AlertAnalysis analysis) async {
    final idx = _favoriteAnalyses.indexWhere((a) => a.id == analysis.id);
    if (idx >= 0) {
      _favoriteAnalyses.removeAt(idx);
    } else {
      analysis.isFavorite = true;
      _favoriteAnalyses.insert(0, analysis);
    }
    await _saveFavorites();
    notifyListeners();
  }

  Future<void> toggleRunbookFavorite(RunbookEntry runbook) async {
    final idx = _favoriteRunbooks.indexWhere((r) => r.id == runbook.id);
    if (idx >= 0) {
      _favoriteRunbooks.removeAt(idx);
    } else {
      runbook.isFavorite = true;
      _favoriteRunbooks.insert(0, runbook);
    }
    await _saveFavorites();
    notifyListeners();
  }

  Future<void> toggleCorrelationFavorite(CorrelationResult correlation) async {
    final idx = _favoriteCorrelations.indexWhere((c) => c.id == correlation.id);
    if (idx >= 0) {
      _favoriteCorrelations.removeAt(idx);
    } else {
      correlation.isFavorite = true;
      _favoriteCorrelations.insert(0, correlation);
    }
    await _saveFavorites();
    notifyListeners();
  }

  Future<void> toggleSeverityFavorite(SeverityClassification severity) async {
    final idx = _favoriteSeverities.indexWhere((s) => s.id == severity.id);
    if (idx >= 0) {
      _favoriteSeverities.removeAt(idx);
    } else {
      severity.isFavorite = true;
      _favoriteSeverities.insert(0, severity);
    }
    await _saveFavorites();
    notifyListeners();
  }

  bool isAnalysisFavorite(String id) =>
      _favoriteAnalyses.any((a) => a.id == id);

  bool isRunbookFavorite(String id) =>
      _favoriteRunbooks.any((r) => r.id == id);

  bool isCorrelationFavorite(String id) =>
      _favoriteCorrelations.any((c) => c.id == id);

  bool isSeverityFavorite(String id) =>
      _favoriteSeverities.any((s) => s.id == id);

  Future<void> clearAll() async {
    _favoriteAnalyses.clear();
    _favoriteRunbooks.clear();
    _favoriteCorrelations.clear();
    _favoriteSeverities.clear();
    await _saveFavorites();
    notifyListeners();
  }
}
