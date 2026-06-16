# Gotenberg Load Test

Load test for the Gotenberg Lambda API using [Locust](https://locust.io/).

## Endpoint Under Test

```
POST /forms/libreoffice/convert
```

Converts a Word/LibreOffice document (`.docx`, `.odt`, `.pptx`, etc.) to PDF.

---

## Prerequisites

```bash
pip install locust
```

---

## Quick Start

### 1. Set your API Gateway URL

Replace `<your-api-gateway-id>` with the actual ID from your Terraform output, or set the environment variable:

```bash
# Windows (PowerShell)
$env:GOTENBERG_HOST = "https://<your-api-gateway-id>.execute-api.us-east-1.amazonaws.com"
$env:GOTENBERG_USERNAME = "admin"
$env:GOTENBERG_PASSWORD = "changeme"

# Linux / macOS
export GOTENBERG_HOST="https://<your-api-gateway-id>.execute-api.us-east-1.amazonaws.com"
export GOTENBERG_USERNAME="admin"
export GOTENBERG_PASSWORD="changeme"
```

### 2. Run with browser UI

```bash
cd load-test
locust -f load_test.py
```

Open http://localhost:8089 in your browser, enter the number of users and spawn rate, then click **Start**.

### 3. Run headless (CI / automated)

```bash
# 50 concurrent users, ramp up 5/s, run for 3 minutes
locust -f load_test.py --headless -u 50 -r 5 -t 3m \
  --host $GOTENBERG_HOST \
  --html report.html
```

---

## Environment Variables

| Variable           | Default                                                    | Description                              |
|--------------------|------------------------------------------------------------|------------------------------------------|
| `GOTENBERG_HOST`   | `https://<your-api-gateway-id>.execute-api.us-east-1.amazonaws.com` | Base URL (no trailing slash) |
| `GOTENBERG_USERNAME` | `admin`                                                  | Basic-auth username                      |
| `GOTENBERG_PASSWORD` | `changeme`                                               | Basic-auth password                      |
| `TEST_FILE_PATH`   | `../document.docx`                                         | Path to the document file to convert     |

---

## Task Weights

| Task                          | Weight | Description                              |
|-------------------------------|--------|------------------------------------------|
| `convert_libreoffice`         | 10     | POST to `/forms/libreoffice/convert`     |
| `health_check`                | 1      | GET `/health`                            |

The conversion task runs ~10× more often than the health check, simulating realistic traffic.

---

## Supported File Types

The script auto-detects the MIME type for:

- `.docx`, `.doc` — Microsoft Word
- `.odt` — OpenDocument Text
- `.pptx`, `.ppt` — PowerPoint
- `.odp` — OpenDocument Presentation
- `.xlsx`, `.xls` — Excel
- `.ods` — OpenDocument Spreadsheet
- `.html`, `.txt` — Web / plain text

---

## Tips

- **Cold starts**: Lambda container images have cold-start latency. Run a warm-up pass with 1–2 users before ramping up.
- **Concurrency limit**: AWS Lambda default concurrency is 1,000 per region. Adjust `reserved_concurrent_executions` in `modules/lambda/main.tf` if needed.
- **Timeout**: The `gotenberg-lambda` function has a 900 s timeout. If you see 504s, the document may be too large or LibreOffice is taking too long.
- **Results**: Use `--html report.html` to generate an HTML report, or `--csv results` to export CSV metrics.
