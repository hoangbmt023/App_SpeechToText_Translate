import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:speechtotext_translate_nhom6/audio_converter.dart';
import 'package:speechtotext_translate_nhom6/whisper_service.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: SpeechToTextPage(),
  ));
}

class SpeechToTextPage extends StatefulWidget {
  @override
  _SpeechToTextPageState createState() => _SpeechToTextPageState();
}

class _SpeechToTextPageState extends State<SpeechToTextPage> {
  String? _transcribedText;
  String? _translatedText;
  bool _isLoading = false;
  String _selectedLang = 'vi';
  OnDeviceTranslator? _translator;

  final Map<String, String> _languages = {
    'vi': 'Tiếng Việt',
    'en': 'English',
    'fr': 'Français',
    'ja': '日本語',
    'zh': '中文',
  };

  Future<void> _pickAndProcessVideo() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result == null) return;
    final mp4File = File(result.files.single.path!);

    setState(() {
      _isLoading = true;
      _transcribedText = null;
      _translatedText = null;
    });

    final wavFile = await AudioConverter.convertMp4ToAudio(mp4File);
    if (wavFile == null) {
      setState(() => _isLoading = false);
      return;
    }

    final text = await WhisperService.transcribe(wavFile);
    setState(() {
      _transcribedText = text;
      _isLoading = false;
    });
  }

  Future<void> _translateText() async {
    if (_transcribedText == null || _transcribedText!.isEmpty) return;

    setState(() => _isLoading = true);

    _translator?.close();
    _translator = OnDeviceTranslator(
      sourceLanguage: TranslateLanguage.english,
      targetLanguage: TranslateLanguage.values
          .firstWhere((lang) => lang.bcpCode == _selectedLang),
    );

    try {
      final result = await _translator!.translateText(_transcribedText!);
      setState(() => _translatedText = result);
    } catch (e) {
      print("Translate error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickAndTranslateVideo() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result == null) return;
    final mp4File = File(result.files.single.path!);

    setState(() {
      _isLoading = true;
      _transcribedText = null;
      _translatedText = null;
    });

    final wavFile = await AudioConverter.convertMp4ToAudio(mp4File);
    if (wavFile == null) {
      setState(() => _isLoading = false);
      return;
    }

    final text = await WhisperService.transcribe(wavFile);
    if (text == null || text.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }

    _translator?.close();
    _translator = OnDeviceTranslator(
      sourceLanguage: TranslateLanguage.english,
      targetLanguage: TranslateLanguage.values
          .firstWhere((lang) => lang.bcpCode == _selectedLang),
    );

    try {
      final result = await _translator!.translateText(text);
      setState(() {
        _translatedText = result;
        _isLoading = false;
      });
    } catch (e) {
      print("Translate error: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _translator?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Center(
          child: Text(
            "Speech to Text - Translate",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Card chọn video MP4 (Whisper)
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: Icon(Icons.video_library, color: Colors.blue, size: 40),
                title: Text("Chọn video MP4",
                    style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                subtitle: Text("Nhận diện giọng nói bằng Whisper"),
                trailing: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _pickAndProcessVideo,
                  icon: Icon(Icons.play_arrow),
                  label: Text("Chọn"),
                ),
              ),
            ),
            SizedBox(height: 12),

            // Card chọn video & dịch luôn
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.translate, color: Colors.green, size: 40),
                        SizedBox(width: 12),
                        Expanded(
                          child: DropdownButton<String>(
                            value: _selectedLang,
                            isExpanded: true,
                            items: _languages.entries.map((e) {
                              return DropdownMenuItem(
                                value: e.key,
                                child: Text(e.value),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedLang = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _pickAndTranslateVideo,
                      icon: Icon(Icons.play_circle_fill),
                      label: Text("Chọn video & dịch"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Hiển thị kết quả
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _translatedText != null || _transcribedText != null
                  ? Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_transcribedText != null && _translatedText == null) ...[
                          Row(
                            children: [
                              Icon(Icons.text_snippet, color: Colors.blue),
                              SizedBox(width: 6),
                              Text("Kết quả Whisper",
                                  style: TextStyle(
                                      fontSize: 20, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                              _transcribedText ?? "",
                            style: TextStyle(
                              fontSize: 19,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 18),

                          // ✅ Chọn ngôn ngữ + nút Translate
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButton<String>(
                                  value: _selectedLang,
                                  isExpanded: true,
                                  items: _languages.entries.map((e) {
                                    return DropdownMenuItem(
                                      value: e.key,
                                      child: Text(e.value),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedLang = value!;
                                    });
                                  },
                                ),
                              ),
                              SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: _translateText,
                                icon: Icon(Icons.g_translate),
                                label: Text("Translate"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (_translatedText != null) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.language, color: Colors.green),
                                  SizedBox(width: 6),
                                  Text(
                                    "Kết quả dịch",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),

                              // ✅ Nút quay về kết quả ban đầu
                              TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _translatedText = null; // chỉ xóa dịch, giữ nguyên _transcribedText
                                  });
                                },
                                icon: Icon(Icons.refresh, color: Colors.blue),
                                label: Text(
                                  "Trở về",
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            _translatedText ?? "",
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 19,   // tăng size chữ dịch
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              )
                  : Center(
                child: Text("Chưa có dữ liệu",
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 19
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
