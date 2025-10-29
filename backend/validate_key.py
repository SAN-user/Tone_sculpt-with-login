import requests
import json
import os

# 1. PASTE YOUR NEW API KEY DIRECTLY HERE (MUST be in double quotes)
MY_API_KEY = "AIzaSyDQkFvugtQmsCVat9mTnNm_KVc4zWPkKKE" 

# --- CONFIGURATION ---
API_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-preview-09-2025:generateContent"
HEADERS = {'Content-Type': 'application/json'}
PARAMS = {'key': MY_API_KEY}
PAYLOAD = {
    "contents": [{"parts": [{"text": "Say the word 'success'"}]}]
}

def run_validation():
    print("--- Running Key Validation Test ---")
    print("Attempting to connect to Gemini API...")
    
    if len(MY_API_KEY) != 39 or not MY_API_KEY.startswith("AIzaSy"):
        print("ERROR: Key format is wrong. Length: %d" % len(MY_API_KEY))
        return

    try:
        response = requests.post(API_URL, headers=HEADERS, params=PARAMS, json=PAYLOAD, timeout=10, verify=False)
        response.raise_for_status() 
        
        result = response.json()
        generated_text = result['candidates'][0]['content']['parts'][0]['text'].strip()
        
        print("\nSUCCESS: 200 OK")
        print(f"AI Response: {generated_text}")
        print("DIAGNOSIS: The key is VALID and working.")
        
    except requests.exceptions.HTTPError as e:
        print("\nFAILURE: HTTP ERROR")
        print(f"STATUS CODE: {e.response.status_code}")
        print("DIAGNOSIS: The key is VALID but rejected (400 or 403).")
        print("SOLUTION: Generate a new key immediately.")
        
    except Exception as e:
        print("\nFAILURE: CONNECTION ERROR")
        print(f"DIAGNOSIS: Firewall or Network Block: {e}")

if __name__ == "__main__":
    run_validation()
