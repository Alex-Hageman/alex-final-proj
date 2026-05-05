import os
import http.server
import socketserver

PORT = 5000

SUPABASE_URL     = os.environ.get('SUPABASE_URL', '')
SUPABASE_ANON_KEY = os.environ.get('SUPABASE_ANON_KEY', '')

CONFIG_JS = (
    "window.MACROLOG_CONFIG = {{\n"
    "  supabaseUrl: \"{}\",\n"
    "  supabaseKey: \"{}\"\n"
    "}};\n"
).format(SUPABASE_URL, SUPABASE_ANON_KEY)

CONFIG_JS_BYTES = CONFIG_JS.encode('utf-8')


class MacroLogHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        path = self.path.split('?')[0]
        if path == '/config.js':
            self.send_response(200)
            self.send_header('Content-Type', 'application/javascript; charset=utf-8')
            self.send_header('Content-Length', str(len(CONFIG_JS_BYTES)))
            self.send_header('Cache-Control', 'no-store')
            self.end_headers()
            self.wfile.write(CONFIG_JS_BYTES)
        else:
            super().do_GET()

    def log_message(self, fmt, *args):
        pass  # suppress request noise


socketserver.TCPServer.allow_reuse_address = True
with socketserver.TCPServer(('0.0.0.0', PORT), MacroLogHandler) as httpd:
    print(f'MacroLog running on port {PORT}', flush=True)
    httpd.serve_forever()
