import 'package:shared_preferences/shared_preferences.dart';

enum AiTone {
  playful, // 調皮
  gentle,  // 溫柔/輕
  strict   // 毒舌/重
}

class SettingsService {
  static const String _toneKey = 'ai_tone_preference';

  static Future<void> saveTone(AiTone tone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_toneKey, tone.index);
  }

  static Future<AiTone> getTone() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_toneKey) ?? 2; // Default to Strict (2)
    return AiTone.values[index];
  }

  static String getToneLabel(AiTone tone) {
    switch (tone) {
      case AiTone.playful: return '調皮';
      case AiTone.gentle: return '溫柔';
      case AiTone.strict: return '嘴臭';
    }
  }
}
