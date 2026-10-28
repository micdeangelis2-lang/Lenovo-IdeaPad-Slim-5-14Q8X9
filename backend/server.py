import json
import mimetypes
import os
import sys
import threading
import webbrowser
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import urlparse

# Ensure project root is in sys.path
ROOT_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if ROOT_DIR not in sys.path:
    sys.path.insert(0, ROOT_DIR)

from backend.diagnostics import collect_full_diagnostics, collect_live_telemetry

FRONTEND_DIR = os.path.join(ROOT_DIR, "frontend")
PORT = int(os.environ.get("CHECKUP_PORT", "8765"))

_CACHED_DIAGNOSTICS = None
_CACHE_LOCK = threading.Lock()


class CheckupRequestHandler(BaseHTTPRequestHandler):
    def log_message(self, format: str, *args) -> None:
        # Quiet standard logs
        pass

    def _send_json(self, payload: dict, status: int = 200) -> None:
        body = json.dumps(payload, ensure_ascii=False).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Cache-Control", "no-store")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self) -> None:
        global _CACHED_DIAGNOSTICS
        parsed = urlparse(self.path)
        path = parsed.path

        if path == "/api/diagnostics":
            refresh = "refresh=1" in (parsed.query or "")
            with _CACHE_LOCK:
                if _CACHED_DIAGNOSTICS is None or refresh:
                    _CACHED_DIAGNOSTICS = collect_full_diagnostics()
                data = _CACHED_DIAGNOSTICS
            self._send_json(data)
            return

        if path == "/api/live":
            self._send_json(collect_live_telemetry())
            return

        # Serve static files from frontend/
        if path == "/" or path == "":
            rel_path = "index.html"
        else:
            rel_path = path.lstrip("/")

        target_file = os.path.normpath(os.path.join(FRONTEND_DIR, rel_path))
        if not target_file.startswith(os.path.normpath(FRONTEND_DIR)) or not os.path.isfile(target_file):
            self._send_json({"error": "Not found"}, status=404)
            return

        mime, _ = mimetypes.guess_type(target_file)
        mime = mime or "application/octet-stream"
        try:
            with open(target_file, "rb") as f:
                content = f.read()
            self.send_response(200)
            self.send_header("Content-Type", f"{mime}; charset=utf-8" if mime.startswith("text/") or mime == "application/javascript" else mime)
            self.send_header("Cache-Control", "no-cache")
            self.send_header("Content-Length", str(len(content)))
            self.end_headers()
            self.wfile.write(content)
        except Exception as exc:
            self._send_json({"error": str(exc)}, status=500)


def main() -> None:
    no_browser = "--no-browser" in sys.argv
    url = f"http://127.0.0.1:{PORT}"
    print("============================================================")
    print(" LENOVO IDEAPAD SLIM 5 14Q8X9 - HARDWARE CHECKUP SUITE")
    print("============================================================")
    print(f"[*] Avvio scansione preliminare WMI / SMART / Batteria...")
    with _CACHE_LOCK:
        global _CACHED_DIAGNOSTICS
        _CACHED_DIAGNOSTICS = collect_full_diagnostics()
    print(f"[*] Scansione completata! Server attivo su: {url}")
    print("[*] Premi CTRL+C nel terminale per chiudere il programma.")

    server = ThreadingHTTPServer(("127.0.0.1", PORT), CheckupRequestHandler)
    if not no_browser:
        threading.Timer(0.6, lambda: webbrowser.open(url)).start()
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\n[*] Chiusura Checkup Suite.")
        server.server_close()


if __name__ == "__main__":
    main()
