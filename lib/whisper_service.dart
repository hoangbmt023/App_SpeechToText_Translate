import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:whisper_ggml/whisper_ggml.dart';

class WhisperService {
  /// Copy model từ assets ra file local (chỉ cần làm 1 lần)
  static Future<File> _getLocalModelFile() async {
    final dir = await getApplicationDocumentsDirectory();
    final modelFile = File('${dir.path}/ggml-base.en-q5_1');

    if (!await modelFile.exists() || await modelFile.length() == 0) {
      try {
        final byteData = await rootBundle.load(
          'assets/models/ggml-base.en-q5_1.bin',
        );
        await modelFile.writeAsBytes(byteData.buffer.asUint8List());
        print('Copied model from assets');
      } catch (e) {
        print('Asset model not found, downloading...');
        await WhisperController().downloadModel(WhisperModel.base);
      }
    }

    return modelFile;
  }

  /// Transcribe audio file
  static Future<String?> transcribe(File audioFile) async {
    if (!await audioFile.exists()) {
      print("Audio file không tồn tại: ${audioFile.path}");
      return null;
    }

    final modelFile = await _getLocalModelFile();
    final whisper = Whisper.new(model: WhisperModel.base);

    final response = await whisper.transcribe(
      modelPath: modelFile.path,
      transcribeRequest: TranscribeRequest(audio: audioFile.path),
    );

    return response.text;
  }
}
