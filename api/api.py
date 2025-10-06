from flask import Flask, request, jsonify
from flask_cors import CORS
import mysql.connector

app = Flask(__name__)
CORS(app, supports_credentials=True)

try:
    from config import DB_CONFIG
except ImportError:
    DB_CONFIG = {
        'host': '192.168.56.12',
        'user': 'webuser',
        'password': 'insecure_db_pw',
        'database': 'fvision'
    }

# Adds an artifact - was generated with AI as this was just a small function to also display database changes
@app.route('/add_artifact', methods=['POST'])
def add_artifact():
    if request.method == 'OPTIONS':
        return jsonify({'ok': True}), 200
    data = request.get_json()
    code = data.get('code')
    name = data.get('name')
    img = data.get('img')
    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        cursor = conn.cursor()
        cursor.execute(
            "INSERT INTO artifacts (code, name, img) VALUES (%s, %s, %s)",
            (code, name, img)
        )
        conn.commit()
        cursor.close()
        conn.close()
        return jsonify({'success': True})
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)}), 400

# Lists all the artifacts
@app.route('/', methods=['GET'])
def get_artifacts():
    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT code, name, img FROM artifacts")
        results = cursor.fetchall()
        cursor.close()
        conn.close()
        return jsonify(results)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# Matches artifacts
@app.route('/', methods=['POST'])
def check_match():
    data = request.get_json()
    code = data.get('code')
    name = data.get('name')
    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        cursor = conn.cursor(dictionary=True)
        query = "SELECT * FROM artifacts WHERE code = %s AND name = %s"
        cursor.execute(query, (code, name))
        result = cursor.fetchone()
        cursor.close()
        conn.close()
        return jsonify({'correct': result is not None})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8888)