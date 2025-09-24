import 'dart:io';
import 'package:ffmpeg_kit_flutter_new_min/ffmpeg_kit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:speechtotext_translate_nhom6/audio_converter.dart';
import 'package:speechtotext_translate_nhom6/whisper_service.dart';

class RealtimeProcessor {
  static Future<void> processVideoRealtime({
    required File mp4File,
    required String targetLang,
    required void Function(String original, String translated) onChunkDone,
  }) async {
    // 1. Convert video sang WAV
    final wavFile = await AudioConverter.convertMp4ToAudio(mp4File);
    if (wavFile == null) {
      print("Convert audio thất bại");
      return;
    }

    // 2. Lấy thư mục temp để lưu chunk
    final dir = await getApplicationDocumentsDirectory();

    // 3. Giả sử video dài tối đa 5 phút, cắt chunk 2s liên tục
    //    bạn có thể dùng ffprobe để lấy chính xác duration
    final maxDuration = 300; // giây

    // 4. Chuẩn bị translator
    final translator = OnDeviceTranslator(
      sourceLanguage: TranslateLanguage.english,
      targetLanguage: TranslateLanguage.values
          .firstWhere((lang) => lang.bcpCode == targetLang),
    );

    for (int start = 0; start < maxDuration; start += 2) {
      final chunkPath = "${dir.path}/chunk_$start.wav";

      // 4.1 Cắt 2s audio
      await FFmpegKit.execute(
          '-i "${wavFile.path}" -ss $start -t 2 -acodec copy "$chunkPath"');

      final chunkFile = File(chunkPath);
      if (!await chunkFile.exists()) continue;

      // 4.2 Whisper transcribe
      final text = await WhisperService.transcribe(chunkFile);
      if (text == null || text.isEmpty) continue;

      // 4.3 Dịch text
      final translated = await translator.translateText(text);

      // 4.4 Callback ra UI
      onChunkDone(text, translated);

      // 4.5 Delay 2s để giả realtime
      await Future.delayed(const Duration(seconds: 2));
    }

    translator.close();
  }
}
