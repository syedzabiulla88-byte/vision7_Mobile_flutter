#!/usr/bin/env python3
"""Generate Vision 7 app icons from the logo SVG for iOS and Android."""
import os
from PIL import Image, ImageDraw

# --- Colors ---
BLUE = (16, 24, 41)       # #101829 - dark blue background
GOLD = (242, 200, 20)     # #f2c814 - gold logo

# --- iOS icon sizes (from Contents.json) ---
IOS_SIZES = [
    ('icon-20.png', 20),
    ('icon-20@2x.png', 40),
    ('icon-20@3x.png', 60),
    ('icon-29.png', 29),
    ('icon-29@2x.png', 58),
    ('icon-29@3x.png', 87),
    ('icon-40.png', 40),
    ('icon-40@2x.png', 80),
    ('icon-40@3x.png', 120),
    ('icon-60@2x.png', 120),
    ('icon-60@3x.png', 180),
    ('icon-76.png', 76),
    ('icon-76@2x.png', 152),
    ('icon-83.5@2x.png', 167),
    ('icon-1024.png', 1024),
]

# --- Android mipmap sizes ---
ANDROID_SIZES = [
    ('mipmap-mdpi', 48),
    ('mipmap-hdpi', 72),
    ('mipmap-xhdpi', 96),
    ('mipmap-xxhdpi', 144),
    ('mipmap-xxxhdpi', 192),
]

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
IOS_DIR = os.path.join(BASE_DIR, 'ios/Runner/Assets.xcassets/AppIcon.appiconset')
ANDROID_DIR = os.path.join(BASE_DIR, 'android/app/src/main/res')


def draw_icon(size):
    """Draw a Vision 7 app icon at the given size."""
    img = Image.new('RGBA', (size, size), BLUE + (255,))
    draw = ImageDraw.Draw(img)

    # --- Shield path points (normalized to 0-1 range, then scaled) ---
    cx, cy = size * 0.5, size * 0.42  # center of shield

    # Shield outline - pentagon with curved bottom
    # Top: (cx, cy - sh), UpperLeft: (cx - sw, cy - sh*0.3), LowerLeft: (cx - sw*0.85, cy + sh*0.6), Bottom: (cx, cy + sh), LowerRight: (cx + sw*0.85, cy + sh*0.6), UpperRight: (cx + sw, cy - sh*0.3)
    sh = size * 0.34  # shield height
    sw = size * 0.42  # shield width

    shield_points = [
        (cx, cy - sh),                          # top
        (cx + sw, cy - sh * 0.3),               # upper right
        (cx + sw * 0.85, cy + sh * 0.65),       # lower right
        (cx, cy + sh * 1.05),                   # bottom point
        (cx - sw * 0.85, cy + sh * 0.65),       # lower left
        (cx - sw, cy - sh * 0.3),               # upper left
    ]

    # Draw shield fill
    draw.polygon(shield_points, fill=GOLD + (255,))

    # Shield outline
    for i in range(len(shield_points)):
        p1 = shield_points[i]
        p2 = shield_points[(i + 1) % len(shield_points)]
        draw.line([p1, p2], fill=(15, 23, 42, 255), width=max(2, size // 32))

    # --- Soccer ball (circle in upper center of shield) ---
    ball_r = size * 0.075
    ball_cx, ball_cy = cx, cy - sh * 0.52
    draw.ellipse(
        [ball_cx - ball_r, ball_cy - ball_r, ball_cx + ball_r, ball_cy + ball_r],
        fill=BLUE + (255,),
    )
    # Ball outline
    draw.ellipse(
        [ball_cx - ball_r, ball_cy - ball_r, ball_cx + ball_r, ball_cy + ball_r],
        outline=BLUE + (255,),
        width=max(1, size // 48),
    )

    # --- Text: VISION 7 ---
    try:
        # Try to use a bold font
        from PIL import ImageFont
        font_size_v = int(size * 0.13)
        font_size_7 = int(size * 0.22)

        font_v = ImageFont.truetype('/System/Library/Fonts/Helvetica.ttc', font_size_v)
        font_7 = ImageFont.truetype('/System/Library/Fonts/Helvetica.ttc', font_size_7)

        text_v = 'VISION'
        text_7 = '7'

        # Measure text
        v_bbox = draw.textbbox((0, 0), text_v, font=font_v)
        n7_bbox = draw.textbbox((0, 0), text_7, font=font_7)

        v_w = v_bbox[2] - v_bbox[0]
        v_h = v_bbox[3] - v_bbox[1]
        n7_w = n7_bbox[2] - n7_bbox[0]
        n7_h = n7_bbox[3] - n7_bbox[1]

        # Position: VISION above center, 7 below it
        v_y = cy - size * 0.02 - v_h
        n7_y = cy + size * 0.01

        draw.text((cx - v_w / 2, v_y), text_v, font=font_v, fill=BLUE + (255,))
        draw.text((cx - n7_w / 2, n7_y), text_7, font=font_7, fill=BLUE + (255,))

    except Exception:
        # Fallback: no custom font available, skip text
        pass

    # --- Rounded corners (iOS style) ---
    # Apply corner mask
    corner_radius = int(size * 0.22)
    mask = Image.new('L', (size, size), 0)
    mask_draw = ImageDraw.Draw(mask)
    mask_draw.rounded_rectangle(
        [0, 0, size, size],
        radius=corner_radius,
        fill=255,
    )
    img.putalpha(mask)

    return img


def main():
    print("Generating iOS app icons...")
    for name, size in IOS_SIZES:
        path = os.path.join(IOS_DIR, name)
        icon = draw_icon(size)
        icon.save(path, 'PNG')
        print(f"  {name} ({size}x{size})")

    print("\nGenerating Android app icons...")
    for folder, size in ANDROID_SIZES:
        path = os.path.join(ANDROID_DIR, folder, 'ic_launcher.png')
        icon = draw_icon(size)
        icon.save(path, 'PNG')
        print(f"  {folder}/ic_launcher.png ({size}x{size})")

    # Also generate adaptive foreground for Android
    print("\nGenerating Android adaptive foreground...")
    for folder, size in ANDROID_SIZES:
        path = os.path.join(ANDROID_DIR, folder, 'ic_launcher_foreground.png')
        icon = draw_icon(size)
        icon.save(path, 'PNG')
        print(f"  {folder}/ic_launcher_foreground.png ({size}x{size})")

    print("\nDone! All app icons generated.")


if __name__ == '__main__':
    main()
