import os
import time
from flask import Flask
import psycopg2

app = Flask(__name__)

DB_HOST = os.getenv("DB_HOST", "db")
DB_NAME = os.getenv("DB_NAME", "gateway")
DB_USER = os.getenv("DB_USER", "gateway")
DB_PASS = os.getenv("DB_PASS", "gateway")

def get_conn(retries=10, delay=2):
    for attempt in range(1, retries + 1):
        try:
            return psycopg2.connect(host=DB_HOST, dbname=DB_NAME, user=DB_USER, password=DB_PASS)
        except psycopg2.OperationalError:
            print(f"DB not ready yet (attempt {attempt})...")
            time.sleep(delay)
    raise RuntimeError("Could not connect to the database")

@app.route("/")
def index():
    conn = get_conn()
    cur = conn.cursor()
    cur.execute("CREATE TABLE IF NOT EXISTS visits (id SERIAL PRIMARY KEY, visited_at TIMESTAMP DEFAULT NOW())")
    cur.execute("INSERT INTO visits DEFAULT VALUES")
    conn.commit()
    cur.execute("SELECT COUNT(*) FROM visits")
    count = cur.fetchone()[0]
    cur.close()
    conn.close()
    return f"<h1>[*] Flask is talking to PostgreSQL!</h1><p>Visits: <b>{count}</b></p>"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
