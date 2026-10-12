import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

import pytest

from app import app


@pytest.fixture
def client():
    app.config["TESTING"] = True
    return app.test_client()


def test_health_returns_ok(client):
    response = client.get("/health")
    assert response.status_code == 200
    assert response.get_json() == {"status": "ok"}


def test_metrics_exposes_request_counter(client):
    client.get("/health")
    response = client.get("/metrics")
    assert response.status_code == 200
    assert b"http_requests_total" in response.data


def test_ready_fails_without_database(client, monkeypatch):
    monkeypatch.setenv("DB_HOST", "127.0.0.1")
    monkeypatch.setenv("DB_PORT", "1")  # nothing listens here
    response = client.get("/ready")
    assert response.status_code == 503


def test_create_order_rejects_bad_input(client):
    response = client.post("/api/orders", json={"item": "", "quantity": 0})
    assert response.status_code == 400