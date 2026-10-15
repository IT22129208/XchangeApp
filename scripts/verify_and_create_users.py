#!/usr/bin/env python3
import json
import urllib.request
import urllib.error

API_KEY = "AIzaSyAoMJTOPNtDB1qw8HOoUU0TY1fBCYxp6jI"
URL = f"https://identitytoolkit.googleapis.com/v1/accounts:signUp?key={API_KEY}"

users = [
    {
        "email": "testuser1@xchange.lk",
        "password": "Pass1234!",
        "displayName": "Kasun Perera"
    },
    {
        "email": "testuser2@xchange.lk",
        "password": "Pass1234!",
        "displayName": "Dilini Fernando"
    }
]

def create_user(user):
    payload = {
        "email": user["email"],
        "password": user["password"],
        "returnSecureToken": True
    }
    req = urllib.request.Request(
        URL,
        data=json.dumps(payload).encode("utf-8"),
        headers={"Content-Type": "application/json"}
    )
    try:
        with urllib.request.urlopen(req) as resp:
            data = json.loads(resp.read().decode("utf-8"))
            print(f"SUCCESS: Created {user['email']} (UID: {data.get('localId')})")
            return True, data
    except urllib.error.HTTPError as e:
        err_body = e.read().decode("utf-8")
        try:
            err_json = json.loads(err_body)
            msg = err_json.get("error", {}).get("message", err_body)
        except Exception:
            msg = err_body
        
        if "EMAIL_EXISTS" in msg:
            print(f"INFO: {user['email']} already exists in Firebase Console.")
            return True, {"status": "exists"}
        elif "CONFIGURATION_NOT_FOUND" in msg:
            print(f"ACTION REQUIRED: Firebase Authentication 'Email/Password' provider is not enabled yet in Firebase Console.")
            return False, {"error": "CONFIGURATION_NOT_FOUND"}
        else:
            print(f"ERROR for {user['email']}: {msg}")
            return False, {"error": msg}

if __name__ == "__main__":
    print("Testing Firebase project: xchange-52865...")
    for u in users:
        create_user(u)
