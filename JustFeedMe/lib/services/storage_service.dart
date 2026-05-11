import 'dart:convert';
import 'package:forkit_mobile/models/place.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _blacklistKey = 'food_radar_blacklist';
  static const String _historyKey = 'food_radar_history';
  static const int _maxHistorySize = 30;

  static Future<List<String>> getBlacklist() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_blacklistKey) ?? [];
  }

  static Future<void> addToBlacklist(String placeId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getBlacklist();
    if (!list.contains(placeId)) {
      list.add(placeId);
      await prefs.setStringList(_blacklistKey, list);
    }
  }

  static Future<void> removeFromBlacklist(String placeId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getBlacklist();
    list.remove(placeId);
    await prefs.setStringList(_blacklistKey, list);
  }

  static Future<void> clearBlacklist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_blacklistKey);
  }

  // History Methods
  static Future<List<Place>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_historyKey) ?? [];
    
    return jsonList
        .map((jsonStr) => Place.fromJson(jsonDecode(jsonStr)))
        .toList();
  }

  static Future<void> addToHistory(Place place) async {
    final prefs = await SharedPreferences.getInstance();
    List<Place> currentHistory = await getHistory();

    // Remove if exists (to move to top)
    currentHistory.removeWhere((p) => p.id == place.id);

    // Add to front
    currentHistory.insert(0, place);

    // Trim to max size
    if (currentHistory.length > _maxHistorySize) {
      currentHistory = currentHistory.sublist(0, _maxHistorySize);
    }

    // Save
    final jsonList = currentHistory
        .map((p) => jsonEncode(p.toJson()))
        .toList();
    
    await prefs.setStringList(_historyKey, jsonList);
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }
}
