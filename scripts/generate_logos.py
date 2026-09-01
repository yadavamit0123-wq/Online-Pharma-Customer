#!/usr/bin/env python3
"""Generate Online Pharma logos for Flutter app assets."""
from PIL import Image, ImageDraw, ImageFont
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = Path(
    "/Users/amityadav/.cursor/projects/Users-amityadav-Projects-Online-Pharma-All/assets/"
    "WhatsApp_Image_2026-08-10_at_1.23.31_PM-8cdd696e-966c-4740-b259-255bf740c839.png"
)
OUT_LAUNCHER = ROOT / "assets/images/app_launcher_logo/launcher_icon.png"
OUT_LIGHT = ROOT / "assets/images/app_logos/app-logo-light.png"
OUT_DARK = ROOT / "assets/images/app_logos/app-logo-dark.png"


def load_logo(size: int) -> Image.Image:
    img = Image.open(SRC).convert("RGBA")
    img = img.resize((size, size), Image.Resampling.LANCZOS)
    return img


def save_square_launcher(size: int = 1024) -> None:
    canvas = Image.new("RGBA", (size, size), (255, 255, 255, 0))
    logo = load_logo(int(size * 0.82))
    offset = (size - logo.width) // 2
    canvas.paste(logo, (offset, offset), logo)
    canvas.save(OUT_LAUNCHER, format="PNG")
    print(f"launcher_icon: {size}x{size}")


def save_rectangle_banner(path: Path, width: int, height: int, bg: tuple, text_color: tuple) -> None:
    canvas = Image.new("RGBA", (width, height), bg)
    logo_size = int(height * 0.72)
    logo = load_logo(logo_size)
    ly = (height - logo_size) // 2
    lx = int(height * 0.12)
    canvas.paste(logo, (lx, ly), logo)

    draw = ImageDraw.Draw(canvas)
    text = "Online Pharma"
    font_size = int(height * 0.28)
    try:
        font = ImageFont.truetype("/System/Library/Fonts/Supplemental/Arial Bold.ttf", font_size)
    except OSError:
        font = ImageFont.load_default()

    tx = lx + logo_size + int(height * 0.14)
    ty = (height - font_size) // 2 - int(height * 0.02)
    draw.text((tx, ty), text, fill=text_color, font=font)
    canvas.save(path, format="PNG")
    print(f"{path.name}: {width}x{height}")


def main() -> None:
    if not SRC.exists():
        raise SystemExit(f"Source logo not found: {SRC}")
    OUT_LAUNCHER.parent.mkdir(parents=True, exist_ok=True)
    OUT_LIGHT.parent.mkdir(parents=True, exist_ok=True)
    save_square_launcher(1024)
    save_rectangle_banner(OUT_LIGHT, 564, 242, (255, 255, 255, 255), (30, 58, 95, 255))
    save_rectangle_banner(OUT_DARK, 564, 242, (18, 28, 45, 255), (255, 255, 255, 255))


if __name__ == "__main__":
    main()
