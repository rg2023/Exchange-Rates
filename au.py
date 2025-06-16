import jwt
import time
import requests

APP_ID = "1415548"  # App ID שלך
PRIVATE_KEY_PATH = "private-key.pem"

# טען את המפתח הפרטי
with open(PRIVATE_KEY_PATH, "r") as f:
    private_key = f.read()

# צור JWT חתום
payload = {
    "iat": int(time.time()),
    "exp": int(time.time()) + (10 * 60),
    "iss": APP_ID
}

jwt_token = jwt.encode(payload, private_key, algorithm="RS256")

headers = {
    "Authorization": f"Bearer {jwt_token}",
    "Accept": "application/vnd.github+json"
}

# שלח בקשה לקבלת ההתקנות
response = requests.get("https://api.github.com/app/installations", headers=headers)
response.raise_for_status()

installations = response.json()

if not installations:
    print("❌ לא נמצאו התקנות לאפליקציה.")
else:
    for inst in installations:
        print(f"Installation ID: {inst['id']}")
        print(f"Account: {inst['account']['login']}")
        print(f"Target Type: {inst['target_type']}")
        print("---")
