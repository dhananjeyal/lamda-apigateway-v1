"""
Gotenberg Load Test Script
==========================
Endpoint : POST /forms/libreoffice/convert
Tool     : Locust (pip install locust)

Usage
-----
# Run interactively (opens browser UI at http://localhost:8089)
locust -f load_test.py

# Run headless (100 users, spawn rate 10/s, run for 2 minutes)
locust -f load_test.py --headless -u 100 -r 10 -t 2m \
       --host https://<your-api-gateway-id>.execute-api.us-east-1.amazonaws.com

Environment variables (override defaults)
------------------------------------------
GOTENBERG_HOST      - Base URL of the API Gateway (no trailing slash)
GOTENBERG_USERNAME  - Basic-auth username  (default: admin)
GOTENBERG_PASSWORD  - Basic-auth password  (default: changeme)
TEST_FILE_PATH      - Path to the .docx/.odt/.pptx file to convert (default: ../document.docx)
"""

import os
import base64
from locust import HttpUser, task, between, events

# ---------------------------------------------------------------------------
# Configuration – override via environment variables or edit directly below
# ---------------------------------------------------------------------------
GOTENBERG_HOST     = os.getenv("GOTENBERG_HOST",     "https://<your-api-gateway-id>.execute-api.us-east-1.amazonaws.com")
GOTENBERG_USERNAME = os.getenv("GOTENBERG_USERNAME", "admin")
GOTENBERG_PASSWORD = os.getenv("GOTENBERG_PASSWORD", "changeme")
TEST_FILE_PATH     = os.getenv("TEST_FILE_PATH",     os.path.join(os.path.dirname(__file__), "..", "document.docx"))

# Pre-compute the Basic-Auth header once
_credentials = base64.b64encode(f"{GOTENBERG_USERNAME}:{GOTENBERG_PASSWORD}".encode()).decode()
AUTH_HEADER = {"Authorization": f"Basic {_credentials}"}

# ---------------------------------------------------------------------------
# Load the test document once at startup (fail fast if it is missing)
# ---------------------------------------------------------------------------
_test_file_bytes: bytes = b""
_test_file_name:  str   = "document.docx"

@events.init.add_listener
def on_locust_init(environment, **kwargs):
    global _test_file_bytes, _test_file_name
    path = os.path.abspath(TEST_FILE_PATH)
    if not os.path.isfile(path):
        raise FileNotFoundError(
            f"Test document not found: {path}\n"
            "Set the TEST_FILE_PATH environment variable to a valid .docx/.odt/.pptx file."
        )
    with open(path, "rb") as fh:
        _test_file_bytes = fh.read()
    _test_file_name = os.path.basename(path)
    print(f"[load_test] Using test file: {path} ({len(_test_file_bytes):,} bytes)")


# ---------------------------------------------------------------------------
# Locust user
# ---------------------------------------------------------------------------
class GotenbergUser(HttpUser):
    """
    Simulates a user repeatedly converting a document via Gotenberg's
    LibreOffice route.  Wait 1–3 seconds between requests to avoid
    hammering the endpoint with zero think-time.
    """
    host = GOTENBERG_HOST
    wait_time = between(1, 3)

    # ------------------------------------------------------------------
    # Primary task – LibreOffice conversion
    # ------------------------------------------------------------------
    @task(10)
    def convert_libreoffice(self):
        """POST a document to /forms/libreoffice/convert and expect a PDF back."""
        files = {
            "files": (_test_file_name, _test_file_bytes, _get_mime_type(_test_file_name)),
        }
        with self.client.post(
            "/forms/libreoffice/convert",
            headers=AUTH_HEADER,
            files=files,
            catch_response=True,
            name="/forms/libreoffice/convert",
        ) as response:
            if response.status_code == 200:
                content_type = response.headers.get("Content-Type", "")
                if "pdf" in content_type or len(response.content) > 0:
                    response.success()
                else:
                    response.failure(f"Unexpected Content-Type: {content_type}")
            elif response.status_code == 429:
                response.failure("Rate limited (429)")
            elif response.status_code == 504:
                response.failure("Gateway timeout (504) – Lambda may have timed out")
            else:
                response.failure(
                    f"HTTP {response.status_code}: {response.text[:200]}"
                )

    # ------------------------------------------------------------------
    # Health-check task (lower weight – runs less often)
    # ------------------------------------------------------------------
    @task(1)
    def health_check(self):
        """GET /health to verify the service is alive."""
        with self.client.get(
            "/health",
            headers=AUTH_HEADER,
            catch_response=True,
            name="/health",
        ) as response:
            if response.status_code == 200:
                response.success()
            else:
                response.failure(f"Health check failed: HTTP {response.status_code}")


# ---------------------------------------------------------------------------
# Helper
# ---------------------------------------------------------------------------
def _get_mime_type(filename: str) -> str:
    ext = os.path.splitext(filename)[1].lower()
    mime_map = {
        ".docx": "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
        ".doc":  "application/msword",
        ".odt":  "application/vnd.oasis.opendocument.text",
        ".pptx": "application/vnd.openxmlformats-officedocument.presentationml.presentation",
        ".ppt":  "application/vnd.ms-powerpoint",
        ".odp":  "application/vnd.oasis.opendocument.presentation",
        ".xlsx": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        ".xls":  "application/vnd.ms-excel",
        ".ods":  "application/vnd.oasis.opendocument.spreadsheet",
        ".html": "text/html",
        ".txt":  "text/plain",
    }
    return mime_map.get(ext, "application/octet-stream")
