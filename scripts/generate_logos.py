#!/usr/bin/env python3
"""Generate Online Pharma logos for Flutter app assets."""
from PIL import Image, ImageDraw, ImageFont
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "assets/images/app_launcher_logo/launcher_icon.png"
OUT_LAUNCHER = ROOT / "assets/images/app_launcher_logo/launcher_icon.png"
OUT_LIGHT = ROOT / "assets/images/app_logos/app-logo-light.png"
OUT_DARK = ROOT / "assets/images/app_logos/app-logo-dark.png"

BANNER_WIDTH = 564
BANNER_HEIGHT = 242
TEXT = "Online Pharma"
FONT_PATH = "/System/Library/Fonts/Supplemental/Arial Bold.ttf"


def load_logo(size: int) -> Image.Image:
    img = Image.open(SRC).convert("RGBA")
    return img.resize((size, size), Image.Resampling.LANCZOS)


def save_square_launcher(size: int = 1024) -> None:
    canvas = Image.new("RGBA", (size, size), (255, 255, 255, 0))
    logo = load_logo(int(size * 0.82))
    offset = (size - logo.width) // 2
    canvas.paste(logo, (offset, offset), logo)
    canvas.save(OUT_LAUNCHER, format="PNG")
    print(f"launcher_icon: {size}x{size}")


def save_rectangle_banner(path: Path, bg: tuple, text_color: tuple) -> None:
    canvas = Image.new("RGBA", (BANNER_WIDTH, BANNER_HEIGHT), bg)
    pad_x = 20
    logo_size = int(BANNER_HEIGHT * 0.62)
    logo = load_logo(logo_size)
    ly = (BANNER_HEIGHT - logo_size) // 2
    lx = pad_x
    canvas.paste(logo, (lx, ly), logo)

    draw = ImageDraw.Draw(canvas)
    text_x_start = lx + logo_size + 18
    max_text_width = BANNER_WIDTH - text_x_start - pad_x

    font_size = int(BANNER_HEIGHT * 0.24)
    font = ImageFont.truetype(FONT_PATH, font_size)
    bbox = draw.textbbox((0, 0), TEXT, font=font)
    text_w = bbox[2] - bbox[0]
    text_h = bbox[3] - bbox[1]

    while text_w > max_text_width and font_size > 16:
        font_size -= 2
        font = ImageFont.truetype(FONT_PATH, font_size)
        bbox = draw.textbbox((0, 0), TEXT, font=font)
        text_w = bbox[2] - bbox[0]
        text_h = bbox[3] - bbox[1]

    tx = text_x_start
    ty = (BANNER_HEIGHT - text_h) // 2 - bbox[1]
    draw.text((tx, ty), TEXT, fill=text_color, font=font)
    canvas.save(path, format="PNG")
    print(f"{path.name}: {BANNER_WIDTH}x{BANNER_HEIGHT} font={font_size}px")


def main() -> None:
    if not SRC.exists():
        raise SystemExit(f"Source logo not found: {SRC}")
    OUT_LIGHT.parent.mkdir(parents=True, exist_ok=True)
    save_rectangle_banner(OUT_LIGHT, (255, 255, 255, 255), (30, 58, 95, 255))
    save_rectangle_banner(OUT_DARK, (18, 28, 45, 255), (255, 255, 255, 255))


if __name__ == "__main__":
    main()
