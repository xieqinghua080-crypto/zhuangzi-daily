#!/usr/bin/env python3
"""Generate iPad 13" screenshots (2064×2752) using PIL compositing."""
from PIL import Image, ImageDraw, ImageFont
import os

BG_COLOR = (245, 240, 232)  # #F5F0E8
WHITE = (255, 255, 255)
CARD_SHADOW = (0, 0, 0, 20)
DARK = (44, 44, 44)       # #2C2C2C for quote
MEDIUM = (90, 90, 90)     # #5A5A5A for advice
GOLD = (139, 115, 85)     # #8B7355 for badges, source
LIGHT_GOLD = (232, 224, 208)  # #E8E0D0 badge bg
BORDER = (212, 197, 169)  # #D4C5A9 line
SOFT = (176, 160, 144)    # #B0A090 for date

W, H = 2064, 2752
CENTER = W // 2

def create_bg():
    img = Image.new('RGB', (W, H), BG_COLOR)
    return img

def draw_rounded_rect(draw, xy, radius, fill):
    x1, y1, x2, y2 = xy
    draw.rounded_rectangle(xy, radius=radius, fill=fill)

def add_text_centered(draw, text, y, font_size, color=DARK, max_width=1400):
    """Try to find font, fall back to default."""
    try:
        font = ImageFont.truetype("/System/Library/Fonts/PingFang.ttc", font_size)
    except:
        try:
            font = ImageFont.truetype("/System/Library/Fonts/STHeiti Light.ttc", font_size)
        except:
            font = ImageFont.load_default()
    
    lines = []
    # Simple word wrap for Chinese (each char ~font_size px wide)
    chars_per_line = max_width // (font_size * 0.7)
    for line in text.split('\n'):
        while len(line) > int(chars_per_line):
            lines.append(line[:int(chars_per_line)])
            line = line[int(chars_per_line):]
        lines.append(line)
    
    total_h = len(lines) * font_size * 1.4
    y_start = y - total_h // 2
    
    for i, line in enumerate(lines):
        bbox = draw.textbbox((0, 0), line, font=font)
        tw = bbox[2] - bbox[0]
        x = CENTER - tw // 2
        ly = y_start + i * font_size * 1.4
        draw.text((x, ly), line, font=font, fill=color)

# ---- Screenshot 1: Today's Sign ----
img = create_bg()
draw = ImageDraw.Draw(img)

# Card
card_w, card_h = 1600, 1000
cx, cy = CENTER, H // 2 - 80
draw_rounded_rect(draw, (cx - card_w//2, cy - card_h//2, cx + card_w//2, cy + card_h//2), 60, fill=WHITE)
# shadow effect
for i in range(20, 0, -1):
    offset = 80 - i * 4
    alpha = i * 3
    shadow = Image.new('RGBA', (card_w + offset*2, card_h + offset*2), (0,0,0,0))
    sdraw = ImageDraw.Draw(shadow)
    sdraw.rounded_rectangle((offset, offset, card_w + offset, card_h + offset), 60, fill=(0,0,0,int(alpha*0.3)))
    img.paste(shadow, (cx - card_w//2 - offset, cy - card_h//2 - offset), shadow)

# Badge
badge_w, badge_h = 220, 60
draw_rounded_rect(draw, (cx - badge_w//2, cy - 350, cx + badge_w//2, cy - 350 + badge_h), 30, fill=LIGHT_GOLD)
try:
    font = ImageFont.truetype("/System/Library/Fonts/PingFang.ttc", 36)
except:
    font = ImageFont.load_default()
draw.text((cx - 50, cy - 345), "✦ 今日签", font=font, fill=GOLD)

# Quote
try:
    font = ImageFont.truetype("/System/Library/Fonts/PingFang.ttc", 72)
except:
    font = ImageFont.load_default()
draw.text((cx - 360, cy - 220), "「吾生也有涯，而知也无涯。」", font=font, fill=DARK)

# Source
try:
    font = ImageFont.truetype("/System/Library/Fonts/PingFang.ttc", 40)
except:
    font = ImageFont.load_default()
draw.text((cx - 120, cy - 100), "——《庄子·养生主》", font=font, fill=GOLD)

# Line
draw_rounded_rect(draw, (cx - 40, cy - 40, cx + 40, cy - 40 + 3), 2, fill=BORDER)

# Advice
try:
    font = ImageFont.truetype("/System/Library/Fonts/PingFang.ttc", 48)
except:
    font = ImageFont.load_default()
advice = "你的注意力是有限的，别把它浪费在\n无关紧要的事情上。今天，专注在\n一件真正重要的事上。"
for i, line in enumerate(advice.split('\n')):
    bbox = draw.textbbox((0, 0), line, font=font)
    tw = bbox[2] - bbox[0]
    x = CENTER - tw // 2
    draw.text((x, cy + 60 + i * 68), line, font=font, fill=MEDIUM)

# Bottom bar
try:
    font_title = ImageFont.truetype("/System/Library/Fonts/PingFang.ttc", 44)
    font_date = ImageFont.truetype("/System/Library/Fonts/PingFang.ttc", 36)
except:
    font_title = ImageFont.load_default()
    font_date = font_title

draw.text((160, H - 150), "庄子的每日签", font=font_title, fill=GOLD)
draw.text((CENTER - 70, H - 140), "2026.5.16", font=font_date, fill=SOFT)

# Tag
draw_rounded_rect(draw, (W - 350, H - 180, W - 160, H - 115), 30, fill=DARK)
draw.text((W - 280, H - 170), "✧ 今日", font=font_date, fill=WHITE)

img.save("/Users/gaojimeishijia/Desktop/ipad1-today-2064x2752.png")
print("Screenshot 1 saved: ipad1-today-2064x2752.png")
