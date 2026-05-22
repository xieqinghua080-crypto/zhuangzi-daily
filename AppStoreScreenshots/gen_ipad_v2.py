#!/usr/bin/env python3
"""Generate 3 iPad 13" screenshots (2064×2752) using PIL."""
from PIL import Image, ImageDraw, ImageFont
import os

BG = (245, 240, 232)
WHITE = (255, 255, 255)
DARK = (44, 44, 44)
GOLD = (139, 115, 85)
GOLD_BG = (232, 224, 208)
SOFT = (176, 160, 144)
MEDIUM = (90, 90, 90)

W, H = 2064, 2752
CX = W // 2

font_sizes = {}
for name in ["PingFang.ttc", "STHeiti Medium.ttc", "AppleGothic.ttf"]:
    path = f"/System/Library/Fonts/{name}"
    if os.path.exists(path):
        for sz in [36, 40, 44, 48, 72, 80, 96]:
            try:
                font_sizes[sz] = ImageFont.truetype(path, sz)
            except:
                pass
        break

def get_font(sz):
    if sz in font_sizes:
        return font_sizes[sz]
    return ImageFont.load_default()

def rr(draw, xy, r, fill):
    draw.rounded_rectangle(xy, radius=r, fill=fill)

def ctext(draw, text, y, sz, color=DARK):
    f = get_font(sz)
    b = draw.textbbox((0, 0), text, font=f)
    draw.text((CX - (b[2]-b[0])//2, y - (b[3]-b[1])//2), text, font=f, fill=color)

def ctext_ml(draw, lines, y_start, sz, color=DARK, line_h=None):
    f = get_font(sz)
    line_h = line_h or int(sz * 1.5)
    for i, line in enumerate(lines):
        b = draw.textbbox((0, 0), line, font=f)
        draw.text((CX - (b[2]-b[0])//2, y_start + i * line_h), line, font=f, fill=color)

# ============ Screenshot 1: Today's Sign ============
img = Image.new('RGB', (W, H), BG)
d = ImageDraw.Draw(img)

# Card background
rr(d, (CX-800, 500, CX+800, 1700), 60, WHITE)

# Badge
rr(d, (CX-110, 570, CX+110, 630), 30, GOLD_BG)
ctext(d, "✦ 今日签", 600, 36, GOLD)

# Quote
ctext(d, "「吾生也有涯，而知也无涯。」", 820, 72, DARK)

# Source
ctext(d, "——《庄子·养生主》", 940, 40, GOLD)

# Line
rr(d, (CX-40, 990, CX+40, 993), 2, (212, 197, 169))

# Advice
ctext_ml(d, [
    "你的注意力是有限的，别把它浪费在",
    "无关紧要的事情上。今天，专注在",
    "一件真正重要的事上。"
], 1090, 48, MEDIUM, 72)

# Bottom bar
ctext(d, "庄子的每日签", H-160, 44, GOLD)
ctext(d, "2026.5.16", H-150, 36, SOFT)
rr(d, (W-350, H-190, W-160, H-125), 30, DARK)
ctext(d, "✧ 今日", H-158, 36, WHITE)

img.save("/Users/gaojimeishijia/Desktop/ipad1-today-2064x2752.png")
print("✅ Screenshot 1 saved")

# ============ Screenshot 2: Sign Library ============
img = Image.new('RGB', (W, H), BG)
d = ImageDraw.Draw(img)

ctext(d, "签库", 120, 48, DARK)
rr(d, (W-350, 80, W-160, 135), 28, DARK)
ctext(d, "订阅后解锁全部", 108, 32, WHITE)

# Grid of 4 cards
cards = [
    ("养生主·三", "缘督以为经", "顺中道以为常法"),
    ("逍遥游·一", "北冥有鱼", "开篇即见大境界"),
    ("齐物论·十二", "天地与我并生", "万物与我合一"),
    ("人间世·八", "人皆知有用之用", "无用之用，方为大用"),
]

card_w, card_h = 720, 380
gap = 80
start_x = CX - card_w - gap//2
start_y = 260

for i, (badge, quote, sub) in enumerate(cards):
    row = i // 2
    col = i % 2
    x = start_x + col * (card_w + gap)
    y = start_y + row * (card_h + gap)
    
    rr(d, (x, y, x+card_w, y+card_h), 40, WHITE)
    
    # Badge in card
    bbox = d.textbbox((0, 0), badge, font=get_font(28))
    bw = bbox[2] - bbox[0]
    rr(d, (x+30, y+30, x+30+bw+30, y+30+20+28), 20, GOLD_BG)
    d.text((x+45, y+36), badge, font=get_font(28), fill=GOLD)
    
    # Quote
    d.text((x+40, y+120), f"「{quote}」", font=get_font(36), fill=DARK)
    
    # Subtitle
    d.text((x+40, y+200), sub, font=get_font(28), fill=GOLD)

img.save("/Users/gaojimeishijia/Desktop/ipad2-library-2064x2752.png")
print("✅ Screenshot 2 saved")

# ============ Screenshot 3: Settings ============
img = Image.new('RGB', (W, H), BG)
d = ImageDraw.Draw(img)

ctext(d, "设置", 120, 48, DARK)

# Settings card
set_x, set_y = 160, 220
set_w, set_h = 1744, 650
rr(d, (set_x, set_y, set_x+set_w, set_y+set_h), 50, WHITE)

settings_items = [
    ("推送时间", "每天早上通知", "07:00", None),
    ("字体", "选择签名风格", "楷体 ›", None),
    ("深色模式", "跟随系统", None, True),
    ("管理订阅", "¥22.00/月", "›", None),
]

item_h = (set_h - 40) // 4
for i, (title, desc, value, toggle) in enumerate(settings_items):
    iy = set_y + 20 + i * item_h
    
    # Divider (except last)
    if i < 3:
        rr(d, (set_x+60, iy+item_h, set_x+set_w-60, iy+item_h+1), 0, (238, 238, 238))
    
    # Title
    d.text((set_x+80, iy+20), title, font=get_font(40), fill=DARK)
    d.text((set_x+80, iy+70), desc, font=get_font(32), fill=SOFT)
    
    if toggle:
        # Toggle switch
        rr(d, (set_x+set_w-160, iy+20, set_x+set_w-80, iy+64), 22, (212, 197, 169))
        rr(d, (set_x+set_w-150, iy+26, set_x+set_w-110, iy+58), 16, WHITE)
    elif value:
        d.text((set_x+set_w-200, iy+25), value, font=get_font(36), fill=GOLD)

# Bottom text
ctext(d, "订阅后可解锁全部 81 签 · 每日推送 · 无广告", H-120, 36, SOFT)

img.save("/Users/gaojimeishijia/Desktop/ipad3-settings-2064x2752.png")
print("✅ Screenshot 3 saved")
print("All iPad screenshots generated!")
