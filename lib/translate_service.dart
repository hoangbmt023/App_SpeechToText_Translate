import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class TranslateService {
  static final translator = OnDeviceTranslator(
    sourceLanguage: TranslateLanguage.english,
    targetLanguage: TranslateLanguage.vietnamese,
  );

  static Future<String> translateText(String text) async {
    if (text.isEmpty) return '';
    try {
      final translated = await translator.translateText(text);
      return translated;
    } catch (e) {
      print("Translate error: $e");
      return text; // fallback: trả về text gốc
    }
  }

  static void close() {
    translator.close();
  }
}
