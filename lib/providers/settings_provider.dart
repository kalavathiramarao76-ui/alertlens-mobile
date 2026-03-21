import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  String _endpoint = 'http://localhost:11434';
  String _model = 'llama3';
  bool _darkMode = true;
  bool _hapticFeedback = true;

  String get endpoint => _endpoint;
  String get model => _model;
  bool get darkMode => _darkMode;
  bool get hapticFeedback => _hapticFeedback;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _endpoint = prefs.getString('endpoint') ?? 'http://localhost:11434';
    _model = prefs.getString('model') ?? 'llama3';
    _darkMode = prefs.getBool('darkMode') ?? true;
    _hapticFeedback = prefs.getBool('hapticFeedback') ?? true;
    notifyListeners();
  }

  Future<void> setEndpoint(String value) async {
    _endpoint = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('endpoint', value);
    notifyListeners();
  }

  Future<void> setModel(String value) async {
    _model = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('model', value);
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _darkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
    notifyListeners();
  }

  Future<void> setHapticFeedback(bool value) async {
    _hapticFeedback = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hapticFeedback', value);
    notifyListeners();
  }

  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _endpoint = 'http://localhost:11434';
    _model = 'llama3';
    _darkMode = true;
    _hapticFeedback = true;
    notifyListeners();
  }
}
