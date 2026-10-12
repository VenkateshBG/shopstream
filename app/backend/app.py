import os
import time
from contextlib import closing

import psycopg2
from flask import Flask, g, jsonify, request
from prometheus_client import (
    CONTENT_TYPE_LATEST,
    Counter,
    Histogram,
    generate_latest,
)

app = Flask(__name__)

# ---------- Metrics (Prometheus will scrape these) ----------
REQUEST_COUNT = Counter(
    "http_requests_total",
    "Total HTTP requests",
    ["method", "endpoint", "status"],
)
REQUEST_LATENCY = Histogram(
    "http_request_duration_seconds",
    "HTTP request latency in seconds",
    ["endpoint"],
)


@app.before_request
def start_timer():
    g.start = time.perf_counter()


@app.after_request
def record_metrics(response):
    if request.path != "/metrics":
        # Use the route pattern, not the raw URL, to keep label values bounded
        endpoint = request.url_rule.rule if request.url_rule else "unmatched"
        REQUEST_COUNT.labels(request.method, endpoint, response.status_code).inc()
        REQUEST_LATENCY.labels(endpoint).observe(time.perf_counter() - g.start)
    return response


# ---------- Database ----------
def db():
    return psycopg2.connect(
        host=os.environ.get("DB_HOST", "localhost"),
        port=int(os.environ.get("DB_PORT", "5432")),
        dbname=os.environ.get("DB_NAME", "shopstream"),
        user=os.environ.get("DB_USER", "shop"),
        password=os.environ.get("DB_PASSWORD", ""),
        connect_timeout=3,
    )


def run_query(sql, params=None, fetch=False):
    with closing(db()) as conn:
        with conn:  # commits on success, rolls back on error
            with conn.cursor() as cur:
                cur.execute(sql, params)
                return cur.fetchall() if fetch else None


_schema_ready = False


def ensure_schema():
    global _schema_ready
    if not _schema_ready:
        run_query(
            """
            CREATE TABLE IF NOT EXISTS orders (
                id SERIAL PRIMARY KEY,
                item TEXT NOT NULL,
                quantity INTEGER NOT NULL CHECK (quantity > 0),
                created_at TIMESTAMPTZ NOT NULL DEFAULT now()
            )
            """
        )
        _schema_ready = True


# ---------- Routes ----------
@app.get("/health")
def health():
    # Liveness: the process is up. Deliberately does NOT touch the database.
    return jsonify(status="ok")


@app.get("/ready")
def ready():
    # Readiness: can we actually serve requests (is the database reachable)?
    try:
        ensure_schema()
        run_query("SELECT 1")
        return jsonify(status="ready")
    except psycopg2.Error:
        return jsonify(status="database unavailable"), 503


@app.get("/api/orders")
def list_orders():
    try:
        ensure_schema()
        rows = run_query(
            "SELECT id, item, quantity, created_at FROM orders ORDER BY id DESC LIMIT 50",
            fetch=True,
        )
    except psycopg2.Error:
        return jsonify(error="database unavailable"), 503
    return jsonify(
        [
            {"id": r[0], "item": r[1], "quantity": r[2], "created_at": r[3].isoformat()}
            for r in rows
        ]
    )


@app.post("/api/orders")
def create_order():
    data = request.get_json(silent=True) or {}
    item = str(data.get("item", "")).strip()
    quantity = data.get("quantity")
    if not item or not isinstance(quantity, int) or quantity < 1:
        return jsonify(error="item (text) and quantity (positive integer) are required"), 400
    try:
        ensure_schema()
        run_query("INSERT INTO orders (item, quantity) VALUES (%s, %s)", (item, quantity))
    except psycopg2.Error:
        return jsonify(error="database unavailable"), 503
    return jsonify(status="created"), 201


@app.get("/metrics")
def metrics():
    return generate_latest(), 200, {"Content-Type": CONTENT_TYPE_LATEST}


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)