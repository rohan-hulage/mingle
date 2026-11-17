import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/reply.dart';
import '../services/reply_service.dart';

class AppController extends ChangeNotifier {
  AppController({ReplyService? replyService})
    : _replyService = replyService ?? ReplyService();

  static const tones = [
    'Friendly',
    'Funny',
    'Flirty',
    'Romantic',
    'Professional',
    'Casual',
    'Confident',
    'Witty',
    'Polite',
    'Sarcastic',
  ];
  static const languages = ['English', 'Hinglish', 'Hindi', 'Marathi'];
  static const lengths = ['Short', 'Medium', 'Detailed'];

  final ReplyService _replyService;
  late SharedPreferences _preferences;
  List<SavedReply> favorites = [];
  List<SavedReply> history = [];
  List<ReplySuggestion> replies = [];
  bool isGenerating = false;
  bool lastResultIsMock = false;
  bool onboardingComplete = false;
  bool darkMode = false;
  bool saveHistory = false;
  String preferredLanguage = 'English';
  String defaultTone = 'Friendly';
  String replyLength = 'Medium';
  String personality = '';
  String communicationStyle = '';

  Future<void> initialize() async {
    _preferences = await SharedPreferences.getInstance();
    onboardingComplete = _preferences.getBool('onboardingComplete') ?? false;
    darkMode = _preferences.getBool('darkMode') ?? false;
    saveHistory = _preferences.getBool('saveHistory') ?? false;
    preferredLanguage =
        _preferences.getString('preferredLanguage') ?? 'English';
    defaultTone = _preferences.getString('defaultTone') ?? 'Friendly';
    replyLength = _preferences.getString('replyLength') ?? 'Medium';
    personality = _preferences.getString('personality') ?? '';
    communicationStyle = _preferences.getString('communicationStyle') ?? '';
    favorites = _decodeList('favorites');
    history = _decodeList('history');
  }

  List<SavedReply> _decodeList(String key) {
    final raw = _preferences.getString(key);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List<dynamic>)
          .map((item) => SavedReply.fromJson(item as Map<String, dynamic>))
          .toList();
    } on FormatException {
      return [];
    } on TypeError {
      return [];
    }
  }

  Future<void> finishOnboarding() async {
    onboardingComplete = true;
    await _preferences.setBool('onboardingComplete', true);
    notifyListeners();
  }

  Future<void> generate(ReplyRequest request) async {
    isGenerating = true;
    replies = [];
    notifyListeners();
    try {
      final result = await _replyService.generate(request);
      replies = result.replies;
      lastResultIsMock = result.isMock;
      if (saveHistory) {
        history.insertAll(
          0,
          result.replies.map(
            (reply) => SavedReply(
              text: reply.text,
              tone: request.tone,
              createdAt: DateTime.now(),
            ),
          ),
        );
        if (history.length > 50) history = history.take(50).toList();
        await _persist('history', history);
      }
    } finally {
      isGenerating = false;
      notifyListeners();
    }
  }

  bool isFavorite(String text) => favorites.any((reply) => reply.text == text);

  void updateReply(int index, String text) {
    final updated = [...replies];
    updated[index] = ReplySuggestion(
      text: text,
      approach: updated[index].approach,
    );
    replies = updated;
    notifyListeners();
  }

  Future<void> toggleFavorite(String text, String tone) async {
    final existing = favorites.indexWhere((reply) => reply.text == text);
    if (existing >= 0) {
      favorites.removeAt(existing);
    } else {
      favorites.insert(
        0,
        SavedReply(text: text, tone: tone, createdAt: DateTime.now()),
      );
    }
    await _persist('favorites', favorites);
    notifyListeners();
  }

  Future<void> deleteFavorite(SavedReply reply) async {
    favorites.remove(reply);
    await _persist('favorites', favorites);
    notifyListeners();
  }

  Future<void> deleteHistory(SavedReply reply) async {
    history.remove(reply);
    await _persist('history', history);
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    darkMode = value;
    await _preferences.setBool('darkMode', value);
    notifyListeners();
  }

  Future<void> setSaveHistory(bool value) async {
    saveHistory = value;
    if (!value) {
      history.clear();
      await _preferences.remove('history');
    }
    await _preferences.setBool('saveHistory', value);
    notifyListeners();
  }

  Future<void> setLanguage(String value) async {
    preferredLanguage = value;
    await _preferences.setString('preferredLanguage', value);
    notifyListeners();
  }

  Future<void> setTone(String value) async {
    defaultTone = value;
    await _preferences.setString('defaultTone', value);
    notifyListeners();
  }

  Future<void> setLength(String value) async {
    replyLength = value;
    await _preferences.setString('replyLength', value);
    notifyListeners();
  }

  Future<void> setPersonality(String value) async {
    personality = value;
    await _preferences.setString('personality', value);
  }

  Future<void> setCommunicationStyle(String value) async {
    communicationStyle = value;
    await _preferences.setString('communicationStyle', value);
  }

  Future<void> _persist(String key, List<SavedReply> value) => _preferences
      .setString(key, jsonEncode(value.map((item) => item.toJson()).toList()));
}
