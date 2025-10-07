#!/bin/bash

exec > /var/log/user-data.log 2>&1

# Update Ubuntu software packages.
apt-get update

# Install Python and pip
apt-get install -y python3 python3-venv python3-full python3-flask python3-flask-cors 

apt-get install -y python3-mysql.connector

apt-get install -y mysql-client-core-8.0 || apt-get install -y mysql-client || apt-get install -y default-mysql-client

mkdir -p /home/ubuntu/api
chown ubuntu:ubuntu /home/ubuntu/api
chmod 755 /home/ubuntu/api

cd /home/ubuntu/api

cat > /home/ubuntu/api/setup.sql << 'SQLEOF'
CREATE TABLE IF NOT EXISTS artifacts (
    code VARCHAR(20),
    name VARCHAR(50) NOT NULL,
    img VARCHAR(500) NOT NULL,
    PRIMARY KEY (code)

);

CREATE TABLE IF NOT EXISTS matched (
    code VARCHAR(20),
    name VARCHAR(50) NOT NULL,
    img VARCHAR(500) NOT NULL,
    PRIMARY KEY (code)
);

INSERT INTO artifacts VALUES ('shell1','Angel Wings', 'https://upload.wikimedia.org/wikipedia/commons/0/07/Cyrtopleura_costata_13a.jpg');
INSERT INTO artifacts VALUES ('shell2','Scallops', 'https://www.shells-of-aquarius.com/images/irish-flat-scallops.jpg');
INSERT INTO artifacts VALUES ('shell3','Rose Petal Tellin', 'https://www.shells-of-aquarius.com/images/sunrise_tellina.jpg');
INSERT INTO artifacts VALUES ('shell4','Pear Whelk', 'https://upload.wikimedia.org/wikipedia/commons/7/7b/Fulguropsis_spirata_pahayokee_01.JPG');
INSERT INTO artifacts VALUES ('shell5','Nutmeg', 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2c/Cancellaria_reticulata_01.JPG/1200px-Cancellaria_reticulata_01.JPG');
SQLEOF

chown ubuntu:ubuntu /home/ubuntu/api/setup.sql
chmod 644 /home/ubuntu/api/setup.sql

DB_HOST=$(echo "${mysql_server_endpoint}" | cut -d: -f1)

until mysql -h $DB_HOST -P 3306 -u webuser -p'insecure_db_pw' -e "SELECT 1" >/dev/null 2>&1; do
    sleep 10
done

mysql -h $DB_HOST -P 3306 -u webuser -p'insecure_db_pw' fvision < /home/ubuntu/api/setup.sql

#Change VM's apiserver's cofiguration to use shared folder.
cat > /home/ubuntu/api/api.py << 'PYEOF'
#!/usr/bin/env python3
from flask import Flask, request, jsonify
from flask_cors import CORS
import mysql.connector
from mysql.connector import Error
import sys
import traceback

app = Flask(__name__)
CORS(app, supports_credentials=True)


DB_ENDPOINT="${mysql_server_endpoint}"
DB_HOST = DB_ENDPOINT.split(':')[0] if ':' in DB_ENDPOINT else DB_ENDPOINT

DB_CONFIG = {
    'host': DB_HOST,
    'port': 3306,
    'user': 'webuser',
    'password': 'insecure_db_pw',
    'database': 'fvision',
    'ssl_disabled': True
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
PYEOF

python3 -m py_compile /home/ubuntu/api/api.py
if [ $? -eq 0 ]; then
    echo "Python syntax: OK"
else
    echo "Python syntax: ERROR"
fi

chown ubuntu:ubuntu /home/ubuntu/api/api.py
chmod 755 /home/ubuntu/api/api.py

#Run api script in the background 
nohup python3 /home/ubuntu/api/api.py > /home/ubuntu/api/log.txt 2>&1 &

