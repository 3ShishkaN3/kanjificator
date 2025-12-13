import zinnia
import os
from flask import Flask, request, jsonify

app = Flask(__name__)

MODEL_PATH = "/app/models/handwriting-ja.model"
recognizer = None

try:
    recognizer = zinnia.Recognizer()
    if not recognizer.open(MODEL_PATH):
        print(f"ERROR: Could not open model at {MODEL_PATH}")
        exit(1)
    print(f"SUCCESS: Zinnia model loaded from {MODEL_PATH}")
except Exception as e:
    print(f"CRITICAL ERROR loading Zinnia: {e}")
    exit(1)

@app.route('/recognize', methods=['POST'])
def recognize():
    data = request.json
    
    # структура: 
    # { 
    #   "width": 300, 
    #   "height": 300, 
    #   "strokes": [ [[x,y], [x,y]...], [[x,y]...] ] 
    # }
    
    width = data.get('width', 1000)
    height = data.get('height', 1000)
    strokes = data.get('strokes', [])

    if not strokes:
        return jsonify([])

    character = zinnia.Character()
    character.clear()
    character.set_width(width)
    character.set_height(height)

    for stroke_idx, points in enumerate(strokes):
        for point in points:
            character.add(stroke_idx, int(point[0]), int(point[1]))

    result = recognizer.classify(character, 10)
    
    candidates = []
    if result:
        for i in range(result.size()):
            candidates.append({
                "value": result.value(i), # Сам иероглиф
                "score": result.score(i)  # Уверенность
            })
    
    return jsonify(candidates)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)