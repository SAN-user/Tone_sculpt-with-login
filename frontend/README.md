# ToneSculpt AI - Mobile Frontend

Modern Flutter application with Material 3 design for AI-powered tone analysis and text enhancement.

## 🎨 Features

- **Material 3 Design**: Modern, clean UI with Indigo color scheme
- **Animated Loading States**: Beautiful overlays during AI processing
- **Selectable Text**: Easy copy-to-clipboard functionality
- **Extended Timeouts**: 60-second timeout for reliable API calls
- **Smart Error Handling**: Clear, actionable error messages
- **Responsive Cards**: Visual hierarchy with elevated card design

## 📱 Supported Platforms

- ✅ Android (Primary)
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

## 🚀 Quick Start

### Install Dependencies
```bash
flutter pub get
```

### Run on Device
```bash
# Android Emulator (default)
flutter run

# Physical device
flutter run -d <device-id>

# Web
flutter run -d chrome

# Desktop
flutter run -d windows  # or macos, linux
```

### Build Production APK
```bash
flutter build apk --release
```

## 🎯 Configuration

### Server URL Setup

The app auto-configures based on deployment:

#### Android Emulator (Default)
Automatically uses `http://10.0.2.2:5000`

#### Physical Device
Update `lib/main.dart`:
```dart
static const String PHYSICAL_IP_ADDRESS = 'YOUR_PC_IP_HERE';
```

Replace with your computer's local IP (e.g., `192.168.1.50`)

Find your IP:
- **Windows**: Run `ipconfig` in terminal
- **macOS/Linux**: Run `ifconfig` in terminal

### Timeout Configuration

Change in `ApiService` class:
```dart
static const Duration requestTimeout = Duration(seconds: 60);
```

## 📦 Dependencies

- **flutter**: SDK
- **http**: ^1.2.0 - HTTP client for API calls
- **cupertino_icons**: ^1.0.6 - iOS-style icons

## 🏗️ Project Structure

```
lib/
└── main.dart          # Complete app (single-file architecture)

test/
└── widget_test.dart   # Test file
```

## 🎨 UI Components

### Input Section
- Multi-line text input
- Character limit indicator
- Modern bordered design

### Tone Selector
- Dropdown with target tones:
  - Direct & Professional
  - Warm & Encouraging
  - Empathetic/Sympathetic
  - Concise & Neutral
  - Formal & Academic
  - Casual & Friendly

### Analysis Display
- Color-coded sentiment indicators
- Structured tone analysis
- Reasoning explanations

### Enhanced Output
- Selectable text with copy button
- Elevated card design
- Clipboard integration

### Loading Overlay
- Animated progress indicator
- Modal overlay
- Status messages

## 🔍 Widget Breakdown

### ApiService
- Manages all backend communication
- Handles timeouts and errors
- Connection pooling
- Proper cleanup

### Config
- Platform-aware URL selection
- Easy IP configuration
- Automatic fallback logic

### ToneAnalysis
- Data model for analysis results
- JSON parsing
- Type-safe properties

## 🎯 Usage Flow

1. User enters text
2. Tap "Analyze Tone"
3. View analysis card
4. Select target tone
5. Tap "Enhance"
6. Copy enhanced text

## 🐛 Debugging

### Enable Debug Logging
```dart
// Add to main.dart
void main() {
  debugPrint('Starting ToneSculpt AI');
  runApp(const ToneSculptApp());
}
```

### Common Issues

**Connection Refused**
- Ensure backend is running
- Check server URL configuration
- Verify firewall settings

**Timeout Errors**
- Text may be too long
- Check network stability
- Verify backend is responsive

**Platform-Specific Issues**
- Android: Check `android/app/build.gradle`
- iOS: Run `pod install` in ios directory
- Web: Ensure CORS is enabled on backend

## 🔧 Building for Production

### Android APK
```bash
flutter build apk --release
```

### Android App Bundle
```bash
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## 📊 Performance Optimizations

- **Extended Timeouts**: Prevents premature failures
- **Connection Reuse**: Efficient HTTP client
- **Stateless Widgets**: Better rendering performance
- **Lazy Loading**: Cards only render when needed
- **Memory Management**: Proper disposal of controllers

## 🧪 Testing

Run tests:
```bash
flutter test
```

Widget test included for main app structure.

## 📝 Code Style

Follows Flutter best practices:
- Single-file architecture for simplicity
- Clear widget separation
- Proper async/await usage
- Comprehensive error handling
- Material 3 design guidelines

## 🚀 Deployment

### Android
1. Generate keystore
2. Configure signing in `android/app/build.gradle`
3. Build release APK

### iOS
1. Configure Apple Developer account
2. Update bundle identifier
3. Build via Xcode

### Web
1. Build web assets
2. Deploy to hosting service
3. Configure CORS if needed

## 📄 License

MIT License - Free to use and modify.

## 🙏 Acknowledgments

Built with Flutter and Material 3 design system.
