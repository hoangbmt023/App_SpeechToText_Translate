import 'dart:io';
import 'package:ffmpeg_kit_flutter_new_min/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new_min/return_code.dart';
import 'package:path_provider/path_provider.dart';

class AudioConverter {
  /// Convert MP4 → WAV PCM16 16kHz mono (tối ưu cho Whisper)
  static Future<File?> convertMp4ToAudio(File mp4File) async {
    if (!await mp4File.exists()) {
      print('MP4 file does not exist: ${mp4File.path}');
      return null;
    }

    final dir = await getApplicationDocumentsDirectory();
    final audioPath =
        '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.wav';

    final session = await FFmpegKit.execute(
      '-i "${mp4File.path}" -vn -ar 16000 -ac 1 -c:a pcm_s16le "$audioPath"',
    );

    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      print('Conversion successful: $audioPath');
      return File(audioPath);
    } else {
      print('FFmpeg failed: $returnCode');
      final logs = await session.getAllLogs();
      logs.forEach((log) => print(log.getMessage()));
      return null;
    }
  }
}
