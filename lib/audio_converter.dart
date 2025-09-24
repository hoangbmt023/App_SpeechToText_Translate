import 'dart:convert';
import 'dart:io';
import 'package:ffmpeg_kit_flutter_new_min/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new_min/return_code.dart';
import 'package:ffmpeg_kit_flutter_new_min/ffprobe_kit.dart';
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

  /// Lấy duration (giây) của audio bằng ffprobe
  static Future<double> _getAudioDuration(File wavFile) async {
    final session = await FFprobeKit.getMediaInformation(wavFile.path);
    final info = await session.getMediaInformation();
    final durationStr = info?.getDuration();
    return double.tryParse(durationStr ?? '0') ?? 0;
  }

  /// Cắt file WAV thành nhiều chunk `seconds` giây
  static Future<List<File>> splitAudioToChunks(
    File wavFile, {
    int seconds = 2,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final chunkDir = Directory("${dir.path}/chunks");
    if (chunkDir.existsSync()) {
      chunkDir.deleteSync(recursive: true);
    }
    chunkDir.createSync(recursive: true);

    final List<File> chunks = [];

    final duration = await _getAudioDuration(wavFile);
    print("📂 Duration file gốc: ${duration.toStringAsFixed(2)} giây");

    int index = 0;
    int start = 0;

    while (start < duration) {
      final chunkPath = "${chunkDir.path}/chunk_$index.wav";
      print("🎵 Đang cắt chunk $index (start=$start)");

      final session = await FFmpegKit.execute(
        '-y -i "${wavFile.path}" -ss $start -t $seconds -ar 16000 -ac 1 -c:a pcm_s16le "$chunkPath"',
      );

      final returnCode = await session.getReturnCode();
      if (!ReturnCode.isSuccess(returnCode)) {
        print("❌ Lỗi khi cắt chunk $index");
        break;
      }

      final f = File(chunkPath);
      if (await f.exists() && await f.length() > 0) {
        print("✅ Chunk $index tạo thành công");
        chunks.add(f);
      }

      index++;
      start += seconds;
    }

    print("🎯 Tổng số chunk tạo: ${chunks.length}");
    return chunks;
  }
}
