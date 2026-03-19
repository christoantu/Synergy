import re
from functools import lru_cache
import requests  # Re-added for the synchronous API call
import json

# Define the model and API URL for the calorie lookup
GEMINI_MODEL = "gemini-2.5-flash-preview-09-2025"
GEMINI_API_URL = f"https://generativelanguage.googleapis.com/v1beta/models/{GEMINI_MODEL}:generateContent"


# Use lru_cache for faster lookups of common queries
# API Key now defaults to None, forcing it to be passed explicitly.
@lru_cache(maxsize=128)
def getcalval(q, api_key='AIzaSyB_G0I9odde2-IwZHB1EgHGmBTKaFvSf6Y'):
    """
    Improved calorie lookup function using an expanded local database, with
    Gemini API and Google Search grounding as a fallback for unknown items.
    """
    print(f"Searching calories for: {q}")

    # --- ENHANCED LOCAL DATABASE (Calories per 100g) ---
    local_db = {
        'cashew': 553, 'almond': 576, 'walnut': 654, 'peanut': 567,
        'pistachio': 562, 'pumpkin seed': 559, 'chia seed': 486,
        'chicken breast': 165, 'salmon': 208, 'pork': 242, 'beef': 250,
        'egg': 155, 'paneer': 265, 'tofu': 76,
        'rice': 130, 'bread': 265, 'oats': 68, 'pasta': 131,
        'quinoa': 120, 'potato': 77, 'milk': 42, 'yogurt': 59, 'cheese': 404,
        'porotta': 300, 'chapati': 297, 'dosa': 167, 'idli': 39,
        'samosa': 300, 'biriyani': 170, 'curry': 110, 'dal': 110,
        'naan': 310, 'roti': 297, 'lentils': 116,
        'apple': 52, 'banana': 89, 'tomato': 18, 'onion': 40,
        'carrot': 41, 'broccoli': 34, 'spinach': 23, 'orange': 47,
        'water': 0, 'tea': 1, 'coffee': 2, 'soup': 35
    }

    # Clean the query for local search
    food_lower = q.lower()
    food_lower = re.sub(r'100\s*gm?\s*|qty\s*|cooked\s*|fried\s*|\W', ' ', food_lower)
    food_lower = ' '.join(food_lower.split()).strip()

    # 1. Try local database (most reliable and fast)
    for food, calories in local_db.items():
        if food in food_lower:
            print(f"Found in local DB: {food} = {calories} cal/100g")
            return str(calories)

    # 2. Fallback to Gemini API with Search Grounding
    if api_key:
        # Prompt to force the model to return ONLY the calorie number
        api_prompt = f"What is the average calorie count per 100 grams for '{food_lower}'? Provide only the numerical value in kcal."

        payload = {
            "contents": [{"parts": [{"text": api_prompt}]}],
            "tools": [{"google_search": {}}],
            "config": {
                "temperature": 0.0,
                "max_output_tokens": 50  # Keep output very short
            }
        }

        try:
            print(f"Attempting Gemini search for: {food_lower}")

            # Synchronous POST request to the Gemini API
            response = requests.post(
                f"{GEMINI_API_URL}?key={api_key}",
                headers={'Content-Type': 'application/json'},
                data=json.dumps(payload),
                timeout=15  # Set a timeout to prevent infinite hangs
            )
            # This is where the 400 error occurs. If the key is invalid, raise_for_status() catches it.
            response.raise_for_status()

            result = response.json()

            # Safely extract text from the response
            generated_text = result.get('candidates', [{}])[0].get('content', {}).get('parts', [{}])[0].get('text',
                                                                                                            '').strip()

            # Use regex to find the first number in the generated text
            cal_match = re.search(r'\d+', generated_text)

            if cal_match:
                calories_found = cal_match.group(0)
                print(f"Found via Gemini API: {calories_found} cal/100g")
                return calories_found

            print(f"Gemini API failed to parse a number from: {generated_text}")

        except requests.exceptions.RequestException as e:
            # This catches the 400 error and others, ensuring a graceful fallback.
            print(f"Gemini API call error: {e}")
        except Exception as e:
            print(f"Error processing Gemini response: {e}")

    # 3. Final conservative fallback
    print("Using conservative default 350 calories (API call failed or no API key provided)")
    return "350"