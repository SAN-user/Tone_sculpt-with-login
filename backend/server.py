import os
import json
import logging
import requests
import time
import sqlite3
import datetime
import jwt
from flask import Flask, request, jsonify

# ----------------- CONFIG -----------------
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

GEMINI_API_KEY = "AIzaSyBw4tfk0izfiVz0S5fFyyz3m-iRGaVnRw8"
MODEL_NAME = "gemini-2.5-flash"
API_URL = f"https://generativelanguage.googleapis.com/v1/models/{MODEL_NAME}:generateContent"
SERVER_TIMEOUT = 30

app = Flask(__name__)
app.config["SECRET_KEY"] = os.getenv("AUTH_SECRET", "change-this-secret-in-prod")
DB_PATH = os.path.join(os.path.dirname(__file__), "users.db")

if not GEMINI_API_KEY:
    raise ValueError("❌ GEMINI_API_KEY missing. Add your key.")
else:
    logger.info(f"✅ API Key loaded. Length: {len(GEMINI_API_KEY)}")


# ----------------- AUTH / USER STORAGE (SQLite) -----------------
def get_db_connection():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn


def init_db():
    conn = get_db_connection()
    try:
        conn.execute(
            """
            CREATE TABLE IF NOT EXISTS users (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                email TEXT UNIQUE NOT NULL,
                password_hash TEXT NOT NULL,
                created_at TEXT NOT NULL
            )
            """
        )
        conn.commit()
    finally:
        conn.close()


def hash_password(plain: str) -> str:
    # Minimal portable hashing using sha256 + salt (for demo). For production, use argon2/bcrypt.
    import hashlib, secrets
    salt = secrets.token_hex(16)
    digest = hashlib.sha256((salt + plain).encode("utf-8")).hexdigest()
    return f"sha256${salt}${digest}"


def verify_password(plain: str, stored: str) -> bool:
    try:
        scheme, salt, digest = stored.split("$")
        if scheme != "sha256":
            return False
        import hashlib
        return hashlib.sha256((salt + plain).encode("utf-8")).hexdigest() == digest
    except Exception:
        return False


def create_token(payload: dict, expires_minutes: int = 60) -> str:
    exp = datetime.datetime.utcnow() + datetime.timedelta(minutes=expires_minutes)
    to_encode = {**payload, "exp": exp}
    return jwt.encode(to_encode, app.config["SECRET_KEY"], algorithm="HS256")


def decode_token(token: str):
    try:
        return jwt.decode(token, app.config["SECRET_KEY"], algorithms=["HS256"]) 
    except jwt.PyJWTError as e:
        return {"error": str(e)}


@app.post("/auth/register")
def register():
    data = request.get_json(silent=True) or {}
    email = (data.get("email") or "").strip().lower()
    password = data.get("password") or ""
    if not email or not password:
        return jsonify({"error": "email and password required"}), 400

    conn = get_db_connection()
    try:
        password_hash = hash_password(password)
        conn.execute(
            "INSERT INTO users (email, password_hash, created_at) VALUES (?, ?, ?)",
            (email, password_hash, datetime.datetime.utcnow().isoformat()),
        )
        conn.commit()
        return jsonify({"message": "registered"}), 201
    except sqlite3.IntegrityError:
        return jsonify({"error": "email already registered"}), 409
    finally:
        conn.close()


@app.post("/auth/login")
def login():
    data = request.get_json(silent=True) or {}
    email = (data.get("email") or "").strip().lower()
    password = data.get("password") or ""
    if not email or not password:
        return jsonify({"error": "email and password required"}), 400

    conn = get_db_connection()
    try:
        row = conn.execute("SELECT id, email, password_hash FROM users WHERE email = ?", (email,)).fetchone()
        if not row or not verify_password(password, row["password_hash"]):
            return jsonify({"error": "invalid credentials"}), 401
        token = create_token({"sub": row["id"], "email": row["email"]}, expires_minutes=120)
        return jsonify({"token": token})
    finally:
        conn.close()


@app.get("/auth/me")
def me():
    auth_header = request.headers.get("Authorization", "")
    if not auth_header.startswith("Bearer "):
        return jsonify({"error": "missing bearer token"}), 401
    token = auth_header.split(" ", 1)[1]
    decoded = decode_token(token)
    if isinstance(decoded, dict) and decoded.get("error"):
        return jsonify({"error": decoded["error"]}), 401
    return jsonify({"user": {"id": decoded.get("sub"), "email": decoded.get("email")}})


# ----------------- GEMINI API CALL -----------------
def call_gemini_api(prompt):
    headers = {"Content-Type": "application/json"}
    params = {"key": GEMINI_API_KEY}
    payload = {
        "contents": [
            {
                "role": "user",
                "parts": [{"text": prompt}]
            }
        ],
        "generationConfig": {
            "temperature": 0.7,
            "maxOutputTokens": 512
        }
    }

    try:
        response = requests.post(API_URL, headers=headers, params=params, json=payload, timeout=SERVER_TIMEOUT)
        response.raise_for_status()
        data = response.json()

        print("🧠 RAW GEMINI RESPONSE ↓↓↓")
        print(json.dumps(data, indent=2))

        return data

    except requests.exceptions.RequestException as e:
        logger.error(f"❌ Gemini API request failed: {e}")
        if hasattr(e, "response") and e.response is not None:
            return {"error": f"Gemini API error ({e.response.status_code}): {e.response.text}"}
        return {"error": str(e)}


# ----------------- ENDPOINT: TONE DETECTION -----------------
@app.route("/api/detect_tone", methods=["POST"])
def detect_tone():
    data = request.json
    text = data.get("text", "")
    if not text:
        return jsonify({"error": "No text provided"}), 400

    prompt = f"""
    You are a professional tone analyzer.
    Analyze the following text and respond strictly in JSON format with:
    {{
      "detected_tone": "one of Passive-Aggressive, Sarcastic/Ironic, Overly Cautious, Direct & Professional, Warm & Encouraging, Empathetic/Sympathetic, Informal & Casual",
      "sentiment": "Positive, Negative, or Neutral",
      "analysis_reason": "Brief reason why you chose that tone"
    }}
    Text: "{text}"
    """

    resp = call_gemini_api(prompt)
    if "error" in resp:
        return jsonify(resp), 500

    try:
        result = (
            resp.get("candidates", [{}])[0]
            .get("content", {})
            .get("parts", [{}])[0]
            .get("text", "")
        )

        # ✅ Check for Gemini safety block before parsing
        if "promptFeedback" in resp and resp["promptFeedback"].get("blockReason"):
            reason = resp["promptFeedback"]["blockReason"]
            return jsonify({"error": f"Gemini safety block triggered: {reason}"}), 400

        if not result.strip():
            return jsonify({"error": "Empty response from model"}), 500

        # 🧹 Clean markdown-style JSON (```json ... ```)
        if result.startswith("```"):
            result = result.strip().strip("`")
            if result.lower().startswith("json"):
                result = result[4:].strip()

        # Try to parse valid JSON
        try:
            parsed = json.loads(result)
            return jsonify({"tone_analysis": parsed})
        except json.JSONDecodeError:
            # If not valid JSON, return raw text
            return jsonify({"tone_analysis": result})

    except Exception as e:
        logger.error(f"Parse error: {e}")
        return jsonify({"error": f"Internal server error: {e}"}), 500

# ----------------- ENDPOINT: TEXT ENHANCEMENT -----------------
@app.route("/api/enhance_text", methods=["POST"])
def enhance_text():
    data = request.json
    text = data.get("text", "")
    target_tone = data.get("target_tone", "Direct & Professional")

    if not text:
        return jsonify({"error": "No text provided"}), 400

    prompt = f"""
    Rewrite the following text to sound {target_tone}, keeping the meaning intact.
    Do not add explanations or formatting. Just return the rewritten text.

    Text: "{text}"
    """

    resp = call_gemini_api(prompt)
    if "error" in resp:
        return jsonify(resp), 500

    try:
        rewritten = (
            resp.get("candidates", [{}])[0]
            .get("content", {})
            .get("parts", [{}])[0]
            .get("text", "")
        )

        if not rewritten.strip():
            return jsonify({"error": "Empty response from model"}), 500

        return jsonify({"enhanced_text": rewritten})
    except Exception as e:
        logger.error(f"Parse error: {e}")
        return jsonify({"error": f"Internal server error: {e}"}), 500


# ----------------- HEALTH CHECK -----------------
@app.route("/health", methods=["GET"])
def health():
    return jsonify({"status": "ok", "message": "ToneSculpt AI Backend running"})


# ----------------- MAIN -----------------
if __name__ == "__main__":
    logger.info("🚀 Starting ToneSculpt AI Backend Server...")
    init_db()
app.run(host='0.0.0.0', port=5000, debug=True)

