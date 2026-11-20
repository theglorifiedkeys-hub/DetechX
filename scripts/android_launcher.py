"""Install DetechX launcher assets into the generated Android runner."""
from pathlib import Path

from PIL import Image, ImageOps

root = Path(__file__).resolve().parents[1]
res = root / "android/app/src/main/res"
with Image.open(root / "assets/launcher.png") as source:
    icon = source.convert("RGB")
for density, size in {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192}.items():
    folder = res / f"mipmap-{density}"
    folder.mkdir(parents=True, exist_ok=True)
    ImageOps.fit(icon, (size, size), Image.Resampling.LANCZOS).save(folder / "ic_launcher.png")
foreground = res / "drawable-nodpi"
foreground.mkdir(parents=True, exist_ok=True)
ImageOps.fit(icon, (432, 432), Image.Resampling.LANCZOS).save(foreground / "detechx_ice.png")
adaptive = res / "mipmap-anydpi-v26"
adaptive.mkdir(parents=True, exist_ok=True)
(adaptive / "ic_launcher.xml").write_text('''<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@android:color/black" />
    <foreground android:drawable="@drawable/detechx_ice" />
</adaptive-icon>
''', encoding="utf-8")
