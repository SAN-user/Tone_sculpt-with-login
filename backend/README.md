# ToneSculpt AI - Backend Server

Optimized Flask server for ToneSculpt AI providing fast, reliable AI-powered tone analysis and text enhancement.

## ⚡ Performance Features

- **Connection Pooling**: Uses `requests.Session` for efficient HTTP connections
- **Fast Model**: Gemini 2.0 Flash Experimental for ultra-low latency
- **Optimized Prompts**: Carefully tuned for speed and accuracy
- **Structured Output**: JSON schema enforcement for reliable parsing
- **Health Monitoring**: `/health` endpoint for server status checks

## 🚀 Quick Start

### 1. Install Dependencies

```bash
# Activate virtual environment
venv\Scripts\activate  # Windows
# OR
source venv/bin/activate  # macOS/Linux

# Install packages
pip install -r requirements.txt
```

### 2. Configure API Key

Create a `.env` file in this directory:

```env
GEMINI_API_KEY=your_actual_api_key_here
```

Get your API key from: https://makersuite.google.com/app/apikey

### 3. Run Server

```bash
python server.py
```

The server will start on `http://0.0.0.0:5000` with:
- Full CORS support
- Detailed logging
- Automatic retry on failures

## 📡 API Endpoints

### Health Check
```
GET /health
```
Returns server status and model information.

**Response:**
```json
{
  "status": "healthy",
  "service": "ToneSculpt AI Backend",
  "model": "gemini-2.0-flash-exp"
}
```

### Detect Tone
```
POST /api/detect_tone
Content-Type: application/json

{
  "text": "Your text here"
}
```

**Response:**
```json
{
  "tone_analysis": "{\"detected_tone\":\"...\",\"sentiment\":\"...\",\"analysis_reason\":\"...\"}"
}
```

### Enhance Text
```
POST /api/enhance_text
Content-Type: application/json

{
  "text": "Original text",
  "current_tone": "Current tone name",
  "target_tone": "Target tone name"
}
```

**Response:**
```json
{
  "enhanced_text": "Enhanced text output"
}
```

## 🎯 Configuration

The server uses these optimized settings:

- **Model**: `gemini-2.0-flash-exp` - Fastest available Gemini model
- **Detection Temperature**: 0.3 (consistent results)
- **Enhancement Temperature**: 0.7 (creative rewrites)
- **Max Output Tokens**: 200 (detection), 500 (enhancement)
- **Timeout**: 30 seconds per API call
- **Retries**: 3 attempts with exponential backoff

## 📊 Logging

Server logs are written to both:
- Console (stdout)
- File: `server.log`

Logs include:
- API call attempts and response times
- Error details with full stack traces
- Health check requests

## 🛠️ Troubleshooting

### Server won't start
```bash
# Check if port 5000 is in use
netstat -an | findstr :5000  # Windows
lsof -i :5000                 # macOS/Linux

# Use a different port by editing server.py
app.run(host='0.0.0.0', port=8000)
```

### API key issues
```bash
# Verify .env file exists
cat .env  # macOS/Linux
type .env # Windows

# Test API key manually
python -c "from dotenv import load_dotenv; import os; load_dotenv(); print(os.getenv('GEMINI_API_KEY'))"
```

### Connection errors
- Ensure firewall allows port 5000
- For emulator access: use `http://10.0.2.2:5000`
- For physical device: use your PC's local IP

## 🔧 Advanced Configuration

### Change Model
Edit `server.py`:
```python
API_URL = "https://generativelanguage.googleapis.com/v1beta/models/YOUR_MODEL:generateContent"
MODEL = "YOUR_MODEL"
```

### Adjust Timeout
```python
def call_gemini_api(payload, timeout=60):  # Increase as needed
```

### Enable Debug Mode
```python
app.run(host='0.0.0.0', port=5000, debug=True, threaded=True)
```

## 📦 Dependencies

- **flask** (3.0.3): Web framework
- **flask-cors** (4.0.1): CORS support
- **requests** (2.31.0): HTTP client with connection pooling
- **python-dotenv** (1.0.1): Environment variable management
- **google-generativeai** (0.8.2): Gemini API client

## ⚙️ Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `GEMINI_API_KEY` | Your Gemini API key | Yes |
| `FLASK_ENV` | Set to `development` for debug mode | No |
| `PORT` | Server port (default: 5000) | No |

## 🔍 Health Monitoring

Check server health:
```bash
curl http://localhost:5000/health
```

For production deployment, consider adding:
- Process manager (PM2, systemd)
- Health check monitoring
- Log rotation
- Rate limiting

## 📝 License

MIT License - Free to use and modify.


