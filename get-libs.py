#!/usr/bin/env python3
"""شغّله مرة واحدة بجانب index.html (يحتاج إنترنت):  python3 get-libs.py
ينزّل المكتبات والخطوط إلى lib/ و fonts/ ليعمل التطبيق دون إنترنت من أول تشغيل."""
import os, re, hashlib, urllib.request

UA = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0 Safari/537.36"
def get(url):
    req = urllib.request.Request(url, headers={"User-Agent": UA})
    with urllib.request.urlopen(req, timeout=60) as r:
        return r.read()

os.makedirs("lib", exist_ok=True)
os.makedirs("fonts", exist_ok=True)

LIBS = {
    "lib/mp4-muxer.js": "https://cdn.jsdelivr.net/npm/mp4-muxer@5.1.3/build/mp4-muxer.js",
    "lib/pdf.min.js": "https://cdnjs.cloudflare.com/ajax/libs/pdf.js/3.11.174/pdf.min.js",
    "lib/pdf.worker.min.js": "https://cdnjs.cloudflare.com/ajax/libs/pdf.js/3.11.174/pdf.worker.min.js",
}
for path, url in LIBS.items():
    data = get(url)
    open(path, "wb").write(data)
    print("OK", path, len(data) // 1024, "KB")

FONTS = [
    "https://fonts.googleapis.com/css2?family=Cairo:wght@400;600;700&display=swap",
    "https://fonts.googleapis.com/css2?family=Playpen+Sans+Arabic:wght@400;600&display=swap",
]
css_all = []
for u in FONTS:
    css = get(u).decode("utf8")
    for f in set(re.findall(r"https://fonts\.gstatic\.com[^)'\"\s]+", css)):
        name = hashlib.sha1(f.encode()).hexdigest()[:12] + ".woff2"
        open("fonts/" + name, "wb").write(get(f))
        css = css.replace(f, name)
    css_all.append(css)
open("fonts/fonts.css", "w", encoding="utf8").write("\n".join(css_all))
print("OK fonts/fonts.css +", len(os.listdir("fonts")) - 1, "font files")
print("تم. ارفع المجلدين lib و fonts مع بقية الملفات.")
