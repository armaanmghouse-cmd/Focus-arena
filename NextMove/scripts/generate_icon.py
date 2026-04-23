"""Generate the Next Move app icon (1024x1024 PNG).

Design: forward-chevron + trailing dot on an indigo-violet gradient.
The chevron represents the "next move"; the dot is the current position.

Run: python NextMove/scripts/generate_icon.py
Output: NextMove/NextMove/Resources/Assets.xcassets/AppIcon.appiconset/Icon.png
"""
from __future__ import annotations

from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFilter

SIZE = 1024
OUT = Path(__file__).resolve().parent.parent / "NextMove" / "Resources" / "Assets.xcassets" / "AppIcon.appiconset" / "Icon.png"


def build_gradient() -> Image.Image:
    """Indigo (top-left) → violet (bottom-right)."""
    # Matches Theme.accent (0.384, 0.502, 0.961) → Theme.accentSecondary (0.482, 0.38, 0.95)
    # Slightly richer for icon presence.
    top_left = np.array([0.30, 0.36, 0.90])
    bottom_right = np.array([0.46, 0.28, 0.78])

    xs = np.linspace(0, 1, SIZE)
    ys = np.linspace(0, 1, SIZE)
    x_grid, y_grid = np.meshgrid(xs, ys)
    t = (x_grid + y_grid) / 2

    r = top_left[0] * (1 - t) + bottom_right[0] * t
    g = top_left[1] * (1 - t) + bottom_right[1] * t
    b = top_left[2] * (1 - t) + bottom_right[2] * t

    rgb = np.stack([r, g, b], axis=-1)
    rgb = (rgb * 255).clip(0, 255).astype(np.uint8)
    return Image.fromarray(rgb, mode="RGB").convert("RGBA")


def add_soft_highlight(img: Image.Image) -> Image.Image:
    """Subtle radial highlight in the upper-left for depth."""
    highlight = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(highlight)
    cx, cy = int(SIZE * 0.28), int(SIZE * 0.22)
    radius = int(SIZE * 0.55)
    for i in range(40, 0, -1):
        alpha = int(3 + (40 - i) * 1.2)
        r = int(radius * (i / 40))
        draw.ellipse(
            [cx - r, cy - r, cx + r, cy + r],
            fill=(255, 255, 255, alpha),
        )
    highlight = highlight.filter(ImageFilter.GaussianBlur(radius=80))
    return Image.alpha_composite(img, highlight)


def draw_chevron_symbol(img: Image.Image) -> Image.Image:
    """Forward chevron + trailing dot — the 'next move' mark."""
    layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(layer)

    cx = SIZE // 2
    cy = SIZE // 2

    # Trailing dot (left of chevron) — represents current position.
    # Offsets chosen so the combined mark (dot + chevron) is visually centered.
    dot_radius = int(SIZE * 0.05)
    dot_cx = cx - int(SIZE * 0.21)
    draw.ellipse(
        [dot_cx - dot_radius, cy - dot_radius, dot_cx + dot_radius, cy + dot_radius],
        fill=(255, 255, 255, 230),
    )

    # Chevron — two stacked rounded strokes forming a right-pointing arrow.
    stroke_w = int(SIZE * 0.085)
    arm = int(SIZE * 0.165)
    tip_x = cx + int(SIZE * 0.19)
    tip_y = cy
    upper_start = (tip_x - arm, tip_y - arm)
    lower_start = (tip_x - arm, tip_y + arm)

    draw.line(
        [upper_start, (tip_x, tip_y)],
        fill=(255, 255, 255, 255),
        width=stroke_w,
        joint="curve",
    )
    draw.line(
        [lower_start, (tip_x, tip_y)],
        fill=(255, 255, 255, 255),
        width=stroke_w,
        joint="curve",
    )

    # Rounded end caps — PIL line doesn't cap by default.
    cap_r = stroke_w // 2
    for pt in [upper_start, lower_start, (tip_x, tip_y)]:
        draw.ellipse(
            [pt[0] - cap_r, pt[1] - cap_r, pt[0] + cap_r, pt[1] + cap_r],
            fill=(255, 255, 255, 255),
        )

    # Soft glow behind the chevron
    glow = layer.filter(ImageFilter.GaussianBlur(radius=22))
    glow_alpha = glow.split()[-1].point(lambda a: min(a, 90))
    glow.putalpha(glow_alpha)

    out = Image.alpha_composite(img, glow)
    out = Image.alpha_composite(out, layer)
    return out


def main() -> None:
    img = build_gradient()
    img = add_soft_highlight(img)
    img = draw_chevron_symbol(img)

    OUT.parent.mkdir(parents=True, exist_ok=True)
    img.convert("RGB").save(OUT, format="PNG", optimize=True)
    print(f"Wrote {OUT} ({OUT.stat().st_size / 1024:.1f} KB)")


if __name__ == "__main__":
    main()
