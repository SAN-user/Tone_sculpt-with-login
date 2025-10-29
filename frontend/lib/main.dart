import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'auth.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

// --- CONFIGURATION CLASS ---
class Config {
  // 💡 IMPORTANT: Replace 'YOUR.PC.LOCAL.IP.HERE' with your PC's actual IPv4 address 
  // if testing on a PHYSICAL device (e.g., '192.168.1.50').
  // NOTE: If running on an emulator, the app automatically uses 10.0.2.2.
  static const String PHYSICAL_IP_ADDRESS = '10.93.25.124'; 
  
  static const String androidEmulatorUrl = 'http://10.0.2.2:5000';
  static const String localhostUrl = 'http://127.0.0.1:5000';
  
  /// Returns the appropriate server URL based on the runtime environment
  static String get serverUrl {
    if (kIsWeb) {
      return 'http://${Uri.base.host.isEmpty ? 'localhost' : Uri.base.host}:5000';
    }

    if (PHYSICAL_IP_ADDRESS != 'YOUR.PC.LOCAL.IP.HERE' && !Platform.isIOS) {
      debugPrint('Using Physical Device IP: $PHYSICAL_IP_ADDRESS');
      return 'http://$PHYSICAL_IP_ADDRESS:5000';
    }
    
    if (Platform.isAndroid) {
      debugPrint('Using Android Emulator IP: 10.0.2.2');
      return androidEmulatorUrl;
    }

    debugPrint('Using Localhost IP: 127.0.0.1');
    return localhostUrl;
  }
}

// --- DATA MODEL ---
class ToneAnalysis {
  final String detectedTone;
  final String sentiment;
  final String analysisReason;

  ToneAnalysis({
    required this.detectedTone,
    required this.sentiment,
    required this.analysisReason,
  });

  factory ToneAnalysis.fromJson(Map<String, dynamic> json) {
    return ToneAnalysis(
      detectedTone: json['detected_tone'] as String,
      sentiment: json['sentiment'] as String,
      analysisReason: json['analysis_reason'] as String,
    );
  }
}

// --- API SERVICE ---
class ApiService {
  final String baseUrl = Config.serverUrl;
  static const Duration requestTimeout = Duration(seconds: 60);
  final http.Client _client = http.Client();

  Future<ToneAnalysis> detectTone(String text) async {
    final url = Uri.parse('$baseUrl/api/detect_tone');
    
    try {
      final response = await _client
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'text': text}),
          )
          .timeout(requestTimeout);

      _validateResponse(response);
      final responseData = json.decode(response.body) as Map<String, dynamic>;
      
      if (responseData.containsKey('error')) {
        throw Exception('Backend Error: ${responseData['error']}');
      }

      // Fix for nested JSON string from tone_analysis field
      final toneAnalysisJson = json.decode(responseData['tone_analysis'] as String);
      return ToneAnalysis.fromJson(toneAnalysisJson);
      
    } on TimeoutException {
      throw Exception('Request timed out after 60 seconds. Please try with a shorter text.');
    } on SocketException {
      throw Exception('Connection failed. Ensure the Python server is running at $baseUrl');
    } catch (e) {
      throw Exception('Failed to detect tone: ${e.toString()}');
    }
  }

  Future<String> enhanceText(String text, String currentTone, String targetTone) async {
    final url = Uri.parse('$baseUrl/api/enhance_text');
    
    try {
      final response = await _client
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'text': text,
              'current_tone': currentTone,
              'target_tone': targetTone,
            }),
          )
          .timeout(requestTimeout);

      _validateResponse(response);
      final responseData = json.decode(response.body) as Map<String, dynamic>;
      
      if (responseData.containsKey('error')) {
        throw Exception('Backend Error: ${responseData['error']}');
      }
      
      return responseData['enhanced_text'] as String;
      
    } on TimeoutException {
      throw Exception('Request timed out after 60 seconds. Please try with a shorter text.');
    } on SocketException {
      throw Exception('Connection failed. Ensure the Python server is running at $baseUrl');
    } catch (e) {
      throw Exception('Failed to enhance text: ${e.toString()}');
    }
  }

  void _validateResponse(http.Response response) {
    if (response.statusCode != 200) {
      throw Exception('Server error: HTTP ${response.statusCode}');
    }
  }

  void dispose() {
    _client.close();
  }
}

void main() {
  runApp(const ToneSculptApp());
}

// --- MAIN APP WIDGET ---
class ToneSculptApp extends StatelessWidget {
  const ToneSculptApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ToneSculpt AI',
      debugShowCheckedModeBanner: false,
      
      theme: ThemeData(
        // THEME FIX: Minimal ThemeData to prevent version compatibility issues
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
        // useMaterial3 is compatible with your SDK version
        useMaterial3: true,
        
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      home: const AuthGate(child: ToneSculptHome()),
    );
  }
}

// --- HOME SCREEN STATEFUL WIDGET ---
class ToneSculptHome extends StatefulWidget {
  const ToneSculptHome({super.key});

  @override
  State<ToneSculptHome> createState() => _ToneSculptHomeState();
}

class _ToneSculptHomeState extends State<ToneSculptHome> with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ApiService _apiService = ApiService();
  final ScrollController _scrollController = ScrollController();
  
  ToneAnalysis? _analysisResult;
  String? _enhancedText;
  String? _errorMessage;
  bool _isLoading = false;
  String _selectedTargetTone = 'Direct & Professional';
  
  final List<String> targetTones = [
    'Direct & Professional',
    'Warm & Encouraging',
    'Empathetic/Sympathetic',
    'Concise & Neutral',
    'Formal & Academic',
    'Casual & Friendly',
  ];

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _apiService.dispose();
    super.dispose();
  }

  void _resetState() {
    setState(() {
      _analysisResult = null;
      _enhancedText = null;
      _errorMessage = null;
      _isLoading = false;
      _textController.clear();
      _selectedTargetTone = targetTones[0];
    });
  }

  Future<void> _handlePrimaryAction() async {
    if (_textController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = "Please enter text to analyze or enhance.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      if (_analysisResult == null) {
        _enhancedText = null;
      }
    });

    try {
      if (_analysisResult == null) {
        // Step 1: Tone Detection
        final result = await _apiService.detectTone(_textController.text);
        setState(() {
          _analysisResult = result;
        });
      } else {
        // Step 2: Text Enhancement
        final result = await _apiService.enhanceText(
          _textController.text,
          _analysisResult!.detectedTone,
          _selectedTargetTone,
        );
        setState(() {
          _enhancedText = result;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Text copied to clipboard'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDetectionMode = _analysisResult == null;
    final primaryButtonText = isDetectionMode
        ? 'Analyze Tone'
        : 'Enhance to "$_selectedTargetTone"';

    return Scaffold(
      appBar: AppBar(
        title: const Text('ToneSculpt AI'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _resetState,
            tooltip: 'Reset',
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Input Section
                _buildInputSection(),
                const SizedBox(height: 20),

                // Tone Selector (visible after detection)
                if (!isDetectionMode) ...[
                  _buildToneSelector(),
                  const SizedBox(height: 20),
                ],

                // Primary Action Button
                _buildPrimaryButton(primaryButtonText, isDetectionMode),
                const SizedBox(height: 24),

                // Error Display
                if (_errorMessage != null) ...[
                  _buildErrorCard(),
                  const SizedBox(height: 20),
                ],

                // Analysis Result
                if (_analysisResult != null) ...[
                  _buildAnalysisCard(),
                  const SizedBox(height: 20),
                ],

                // Enhanced Text Output
                if (_enhancedText != null) ...[
                  _buildEnhancedOutputCard(),
                  const SizedBox(height: 20),
                ],
              ],
            ),
          ),
          
          // Animated Loading Overlay
          if (_isLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.edit_note, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Enter Your Text',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _textController,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: 'Type or paste your message, email, or document here...',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.1),
              ),
              enabled: !_isLoading,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToneSelector() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.tune, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Target Tone',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.1),
              ),
              value: _selectedTargetTone,
              items: targetTones.map((String tone) {
                return DropdownMenuItem<String>(
                  value: tone,
                  child: Text(tone),
                );
              }).toList(),
              onChanged: _isLoading
                  ? null
                  : (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedTargetTone = newValue;
                        });
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryButton(String text, bool isDetectionMode) {
    return ElevatedButton.icon(
      onPressed: _isLoading ? null : _handlePrimaryAction,
      icon: _isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Icon(isDetectionMode ? Icons.psychology : Icons.auto_awesome),
      label: Text(_isLoading ? 'Processing...' : text),
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Card(
      color: Colors.red.shade50,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade700),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red.shade900, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisCard() {
    Color getSentimentColor(String sentiment) {
      if (sentiment == 'Positive') return Colors.green.shade700;
      if (sentiment == 'Negative') return Colors.red.shade700;
      return Colors.orange.shade700;
    }

    return Card(
      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.insights,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Tone Analysis',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildAnalysisRow('Detected Tone:', _analysisResult!.detectedTone, Colors.black87),
            const SizedBox(height: 8),
            _buildAnalysisRow(
              'Sentiment:', 
              _analysisResult!.sentiment, 
              getSentimentColor(_analysisResult!.sentiment),
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Analysis:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(_analysisResult!.analysisReason),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedOutputCard() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.stars,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Enhanced Text',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _copyToClipboard(_enhancedText!),
                  icon: const Icon(Icons.copy, size: 18),
                  label: const Text('Copy'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: SelectableText(
                _enhancedText!,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // FINAL FIX: This function now removes the 'const' from widgets it generates 
  // to avoid compilation errors on older Flutter SDKs.
  Widget _buildAnalysisRow(String title, String value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox( 
          width: 120,
          child: Text(
            title, 
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.3),
      child: Center(
        child: Card(
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'AI is processing...\nPlease wait',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}