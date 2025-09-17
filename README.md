# 🎤 SpeechToText Translate - Nhóm 6

## 📱 Giới thiệu
Đây là ứng dụng Flutter được phát triển bởi **Nhom6**.  
Ứng dụng có mục tiêu:
- Chuyển đổi **video thành văn bản**
- Hỗ trợ dịch thuật (Translate)
- Đem lại trải nghiệm mượt mà trên **Android**

---

## ⚙️ Yêu cầu hệ thống
- **Flutter SDK**: >= 3.x
- **Dart**: >= 3.x
- **Android Studio** hoặc **Visual Studio Code**
- Thiết bị / Giả lập Android (API 33+)

---

## 📥 Cài đặt

### 1. Clone dự án
```bash
git clone https://github.com/hoangbmt023/App_SpeechToText_Translate.git
cd App_SpeechToText_Translate
```

### 2. Cài đặt dependencies
```bash
flutter pub get
```

### 3. Chạy ứng dụng
Chạy trên thiết bị / emulator:
```bash
flutter run
```

Build APK:
```bash
flutter build apk --release
```

---

## 📂 Cấu trúc thư mục
```
App_SpeechToText_Translate/
│── android/         # Code Android gốc
│── lib/             # Source code Flutter (Dart)
│   │── main.dart    # Điểm vào ứng dụng
│   └── audio_converter.dart     #  chuyển mp4 sang âm thanh
│   └── translate_service.dart     # dịch thuâ
│   └── whisper_service.dart     # dịch văn bản từ âm thanh
│── assets/
│    └── models/
│         └── ggml-base.en-q5_1.bin   # Model Whisper (mặc định ~320MB)
│── pubspec.yaml     # File cấu hình dependencies
│── README.md        # Hướng dẫn sử dụng
```

---

## 🔄 Sử dụng model Whisper khác
Hiện tại dự án sử dụng **ggml-base.en-q5_1.bin** (~320MB).  
Nếu bạn muốn sử dụng model mạnh hơn (hoặc nhẹ hơn), hãy làm theo:

1. Truy cập: [HuggingFace Whisper.cpp models](https://huggingface.co/ggerganov/whisper.cpp)
2. Tải model mong muốn (ví dụ: `ggml-small.en.bin`, `ggml-medium.en.bin`, ...)
3. Đặt file vào thư mục:
   ```
   assets/models/
   ```
4. Cập nhật lại đường dẫn trong:
    - `pubspec.yaml`
    - `whisper_service.dart`

Ví dụ trong `pubspec.yaml`:
```yaml
assets:
  - assets/models/ggml-small.en.bin
```

---

## 📄 Ghi chú
- Model càng lớn → độ chính xác cao hơn nhưng cần nhiều RAM và tốc độ xử lý chậm hơn.
- Với thiết bị Android RAM thấp, khuyến nghị dùng **base** hoặc **small**.  
