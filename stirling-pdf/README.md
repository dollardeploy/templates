# Stirling PDF

A locally-hosted web app to perform 50+ operations on PDFs — merge, split, convert, rotate, compress, OCR, and more.

> **Experimental template.** Verify the deployment on your own server before relying on it.

## What you get

- [Stirling PDF](https://www.stirlingpdf.com) (`stirlingtools/stirling-pdf`)
- All processing happens locally — files never leave your server
- Configs, logs, and OCR training data persisted to local volumes

## Configuration

| Env | Default | Description |
| --- | --- | --- |
| `PORT` | `8080` | Host port the app is exposed on (bound to `127.0.0.1`) |

## First run

Deploy and open the app URL — the full toolkit is available immediately, no
setup required. To enable login/authentication and additional features, see the
[Stirling PDF docs](https://docs.stirlingpdf.com).
