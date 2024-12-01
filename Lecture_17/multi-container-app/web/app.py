from flask import Flask, jsonify
import redis
import psycopg2
import os
import json

app = Flask(__name__)


redis_client = redis.Redis(host='redis', port=6379, password=os.getenv('REDIS_PASSWORD'))

conn = psycopg2.connect(
    dbname=os.getenv('POSTGRES_DB'),
    user=os.getenv('POSTGRES_USER'),
    password=os.getenv('POSTGRES_PASSWORD'),
    host='db'
)

@app.route('/data')
def get_data():
    host_number = f'Hello from Flask running in {os.environ.get("HOSTNAME")}!'
    key = 'my_data_key'
    
    data = redis_client.get(key)
    
    if data:
        data = json.loads(data.decode('utf-8'))
        source = 'redis'
    else:
        with conn.cursor() as cur:
            cur.execute("SELECT * FROM test;")
            result = cur.fetchall()
            if result:

                data_to_store = [dict(zip([col[0] for col in cur.description], row)) for row in result]

                redis_client.set(key, json.dumps(data_to_store)) 
                data = data_to_store
                source = 'db'
            else:
                return jsonify({'error': 'Data not found'}), 404

    response = {
        'data': data,
        'source': source,
        'host_number': host_number
    }

    return jsonify(response)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)