
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:forkit_mobile/models/place.dart';
import 'package:forkit_mobile/services/settings_service.dart';

class AiService {
  // TODO: Replace with actual key or use --dart-define
  static const String _apiKey = 'AIzaSyDdLJpYqoXA1GtUEdgRCiFVH56QD1VoL34';

  static Future<String> generateCommentary(Place place, AiTone tone) async {
    print('🤖 AiService: Generating commentary for ${place.name} (Tone: $tone)');

    if (_apiKey.isEmpty) {
      print('⚠️ No API Key found.');
      return "這家看起來真的很不錯，試試看吧！(請設定 API KEY)";
    }

    try {
      final model = GenerativeModel(model: 'gemini-2.5-flash-lite', apiKey: _apiKey);
      
      String prompt = '';
      switch (tone) {
        case AiTone.playful:
          prompt = '你是一個幽默風趣、喜歡開玩笑的美食家。請用輕鬆好玩的語氣推薦這家餐廳：「${place.name}」（類型：${place.categories.join(', ')}）。字數在 40 字以內，要讓用戶會心一笑。';
          break;
        case AiTone.gentle:
          prompt = '你是一個超級溫柔、充滿鼓勵與正能量的療癒系美食家。請用最暖心的語氣推薦這家餐廳：「${place.name}」（類型：${place.categories.join(', ')}）。字數在 40 字以內，讓用戶感到被照顧。';
          break;
        case AiTone.strict:
        default:
          prompt = '你是一個非常毒舌且沒耐心的美食評論家。用戶已經挑剔了好幾次，請用強硬且幽默的語氣命令他去吃這家餐廳：「${place.name}」（類型：${place.categories.join(', ')}）。字數嚴格限制在 50 個字以內，要帶點火藥味。';
          break;
      }

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      return response.text ?? "這家不錯！";
    } catch (e) {
      print('❌ Gemini AI Error: $e');
      return "雖然連線失敗，但這家還是很推薦！";
    }
  }
}
