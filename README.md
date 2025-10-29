# ToneSculpt AI: Professional Communication Enhancer

<div align="center">

**Version 2.0** - Fast, Modern, Production-Ready

A sophisticated cross-platform mobile application that uses cutting-edge AI to detect nuanced tones in text and enhance them to match your desired professional communication style.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue)](https://flutter.dev)
[![Python](https://img.shields.io/badge/Python-3.12-green)](https://python.org)
[![Gemini AI](https://img.shields.io/badge/Gemini-2.0_Flash-FF6B6B)](https://ai.google.dev)

</div>

---

## 🎯 Features

### Core Capabilities
- **🔄 Advanced Tone Detection**: Accurately identifies complex tones including Passive-Aggressive, Sarcastic/Ironic, Overly Cautious, Direct & Professional, Warm & Encouraging, Empathetic/Sympathetic, Informal & Casual
- **✨ Smart Text Enhancement**: Transforms your text to any desired professional tone while preserving original intent and meaning
- **📊 Sentiment Analysis**: Provides additional context with sentiment classification (Positive, Negative, Neutral)
- **🎨 Modern Material 3 Design**: Beautiful, responsive UI with color-coded feedback and animated loading states
- **📱 Cross-Platform**: Works on Android, iOS, Web, Windows, macOS, and Linux

### Performance Features ✨
- **⚡ Lightning Fast**: Connection pooling, optimized prompts, and efficient API calls for minimal latency
- **🛡️ Robust Error Handling**: Extended 60-second timeouts with graceful error messages
- **📊 Real-time Monitoring**: Health check endpoints and detailed logging
- **🎭 Enhanced UX**: Animated loading overlays, copy-to-clipboard functionality, and visual feedback

---

## 📁 Project Structure

```
tone-sculpt-ai/
├── backend/
│   ├── server.py          # Optimized Flask backend with Gemini API
│   ├── requirements.txt   # Python dependencies
│   ├── .env              # API key configuration (create this)
│   └── venv/             # Python virtual environment
│
└── frontend/
    ├── lib/
    │   └── main.dart     # Complete Flutter app with Material 3 design
    ├── pubspec.yaml      # Flutter dependencies
    └── README.md         # Flutter-specific docs
```

---

## 🚀 Quick Start Guide

### Prerequisites
- **Python 3.12+** - [Download](https://www.python.org/downloads/)
- **Flutter 3.x+** - [Install Guide](https://docs.flutter.dev/get-started/install)
- **Gemini API Key** - [Get Free Key](https://makersuite.google.com/app/apikey)

### Step 1: Backend Setup

1. **Navigate to backend directory:**
   ```bash
   cd backend
   ```

2. **Create and activate virtual environment:**
   ```bash
   python -m venv venv
   
   # On Windows:
   venv\Scripts\activate
   
   # On macOS/Linux:
   source venv/bin/activate
   ```

3. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

4. **Configure Gemini API Key:**
   
   Create a `.env` file in the `backend` directory:
   ```bash
   # On Windows:
   echo GEMINI_API_KEY=your_key_here > .env
   
   # On macOS/Linux:
   echo "GEMINI_API_KEY=your_key_here" > .env
   ```
   
   Or manually create `.env` and add:
   ```
   GEMINI_API_KEY=your_actual_api_key_here
   ```
   
   Get your free API key from: https://makersuite.google.com/app/apikey

5. **Start the backend server:**
   ```bash
   python server.py
   ```
   
   You should see:
   ```
   🚀 Starting ToneSculpt AI Backend Server...
   📍 Server accessible at http://0.0.0.0:5000
   💡 For Android Emulator: http://10.0.2.2:5000
   ```

### Step 2: Frontend Setup

1. **Navigate to frontend directory:**
   ```bash
   cd frontend
   ```

2. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the application:**
   ```bash
   flutter run
   ```
   
   Or build for a specific platform:
   - Android: `flutter run -d android`
   - iOS: `flutter run -d ios`
   - Web: `flutter run -d chrome`

### Step 3: Configure Network Access

#### For Android Emulator (Default)
The app is pre-configured for emulator access via `10.0.2.2:5000`. No changes needed!

#### For Physical Devices
If running on a physical phone, you need to:

1. Find your computer's local IP address:
   ```bash
   # On Windows:
   ipconfig
   
   # On macOS/Linux:
   ifconfig
   ```
   Look for IPv4 address (e.g., `192.168.1.50`)

2. Update the IP in `frontend/lib/main.dart`:
   ```dart
   static const String PHYSICAL_IP_ADDRESS = 'YOUR_PC_IP_HERE';
   ```
   Replace with your actual IP (e.g., `192.168.1.50`)

3. Ensure your device and computer are on the same WiFi network

---

## 📱 How to Use

1. **Enter Text**: Type or paste your message, email, or document
2. **Analyze Tone**: Tap the "Analyze Tone" button
3. **Review Analysis**: See detected tone, sentiment, and reasoning
4. **Select Target Tone**: Choose from dropdown (Direct & Professional, Warm & Encouraging, etc.)
5. **Enhance Text**: Tap "Enhance" to transform your text
6. **Copy & Use**: Tap the copy button to use your enhanced text

---

## 🔧 Technical Specifications

### Backend (Flask)
- **Framework**: Flask 3.0.3 with CORS support
- **AI Model**: Gemini 2.0 Flash Experimental (`gemini-2.0-flash-exp`)
- **Performance**: Connection pooling with `requests.Session`
- **Timeout**: 30 seconds per API call
- **Endpoints**:
  - `POST /api/detect_tone` - Tone analysis with structured output
  - `POST /api/enhance_text` - Text transformation
  - `GET /health` - Health check

### Frontend (Flutter)
- **Framework**: Flutter 3.x with Material 3 design
- **Timeout**: 60 seconds client-side timeout
- **Features**:
  - Animated loading overlays
  - Selectable text output
  - Copy-to-clipboard functionality
  - Color-coded sentiment indicators
  - Responsive card-based UI

### AI Model Configuration
- **Temperature**: 0.3 for detection (consistent), 0.7 for enhancement (creative)
- **Output Tokens**: 200 for detection, 500 for enhancement
- **Structured Output**: JSON schema enforced for reliable parsing

---

## 🎨 UI Features

### Material 3 Design System
- **Color Scheme**: Indigo theme with semantic color coding
- **Sentiment Colors**: Green (positive), Red (negative), Orange (neutral)
- **Elevation**: Multi-level card hierarchy for visual depth
- **Typography**: Clear hierarchy with bold headings

### User Experience Enhancements
- **🔄 Animated Loading**: Card-based overlay prevents UI feeling broken
- **📋 Smart Copying**: One-tap clipboard with visual confirmation
- **📝 Selectable Text**: Long-press to select and copy enhanced output
- **🎯 Visual Feedback**: Color-coded analysis results
- **⚠️ Helpful Errors**: Clear, actionable error messages

---

## 🛠️ Troubleshooting

### Server Won't Start
- ✅ Check `.env` file exists and contains valid API key
- ✅ Verify virtual environment is activated
- ✅ Ensure port 5000 is not in use

### Connection Errors on Physical Device
- ✅ Update `PHYSICAL_IP_ADDRESS` in `main.dart`
- ✅ Verify device and PC are on same WiFi
- ✅ Check Windows Firewall allows connections on port 5000

### Timeout Errors
- ✅ Text may be too long (try shorter segments)
- ✅ Check backend server is running and responsive
- ✅ Verify network connection is stable

### AI Not Responding
- ✅ Verify Gemini API key is valid at https://makersuite.google.com/app/apikey
- ✅ Check API quota hasn't been exceeded
- ✅ Review server logs for detailed error messages

---

## 📊 Performance Metrics

### Backend Optimizations
- **Connection Pooling**: Reuses connections for faster API calls
- **Structured Output**: JSON schema enforcement for reliable parsing
- **Token Limits**: Optimized max tokens for speed
- **Logging**: Detailed performance tracking with response times

### Frontend Optimizations
- **Extended Timeouts**: 60 seconds prevents premature failures
- **Efficient Widgets**: Stateless where possible for better performance
- **Connection Management**: Proper HTTP client lifecycle management

---

## 🔑 Get Your Free Gemini API Key

1. Visit: https://makersuite.google.com/app/apikey
2. Sign in with your Google account
3. Click "Create API Key"
4. Copy the key to your `.env` file

**Note**: Free tier includes generous quotas for development and testing.

---

## 📝 License

This project is licensed under the MIT License - feel free to use it for your own projects!

---

## 🙏 Acknowledgments

- Built with [Flutter](https://flutter.dev) and [Flask](https://flask.palletsprojects.com/)
- Powered by [Google Gemini AI](https://ai.google.dev)
- Material 3 Design System by Google

---

## 🎯 Version History

### v2.0 (Current) - Performance & UX Enhancement
- ⚡ Added connection pooling for faster API calls
- 🎨 Upgraded to Material 3 design system
- 📊 Added real-time performance monitoring
- 🛡️ Extended timeouts with robust error handling
- ✨ Enhanced loading animations and visual feedback
- 📱 Improved cross-platform compatibility

### v1.0 - Initial Release
- Basic tone detection and enhancement
- Material Design UI
- Two-stage LLM pipeline

---

**Built with ❤️ for professional communication enhancement**
