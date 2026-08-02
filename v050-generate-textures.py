from pathlib import Path
from PIL import Image, ImageDraw

root = Path('Aegis7_Transforming_Robot_Mod/src/main/resources/assets/aegis7/textures')
(root / 'entity').mkdir(parents=True, exist_ok=True)
(root / 'item').mkdir(parents=True, exist_ok=True)
variants = {
    'stratos': ((77, 96, 112), (35, 205, 240), (185, 205, 218)),
    'wraith': ((54, 55, 65), (212, 50, 75), (164, 171, 184)),
    'vanguard': ((62, 75, 72), (255, 154, 42), (192, 202, 194)),
}

def entity_texture(name, base, glow, metal):
    im = Image.new('RGBA', (256, 256), (*base, 255))
    d = ImageDraw.Draw(im)
    for y in range(0, 256, 16):
        for x in range(0, 256, 16):
            shade = ((x // 16 + y // 16) % 4) * 7 - 10
            fill = tuple(max(0, min(255, c + shade)) for c in base) + (255,)
            d.rectangle((x, y, x + 15, y + 15), fill=fill)
            d.line((x, y, x + 15, y), fill=(*metal, 255), width=1)
            d.line((x, y, x, y + 15), fill=(18, 22, 26, 255), width=1)
            d.line((x + 15, y + 3, x + 15, y + 15), fill=(12, 15, 18, 255), width=1)
    for y in (9, 27, 55, 73, 94, 118, 145, 168, 192, 224):
        d.rectangle((4, y, 245, y + 2), fill=(*glow, 255))
    for x in (18, 48, 82, 116, 150, 184, 218):
        d.rectangle((x, 2, x + 2, 188), fill=(20, 24, 29, 255))
    d.rectangle((0, 0, 75, 15), fill=(*metal, 255))
    d.rectangle((38, 18, 90, 30), fill=(*glow, 255))
    d.rectangle((52, 112, 112, 125), fill=(30, 53, 65, 255))
    for i in range(24):
        x = (i * 37 + len(name) * 13) % 246
        y = (i * 61 + 17) % 190
        d.line((x, y, x + 7, y + 2), fill=(110, 91, 72, 180), width=1)
    im.save(root / 'entity' / f'{name}.png', optimize=True)

def core_texture(name, base, glow, metal):
    im = Image.new('RGBA', (16, 16), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    d.polygon([(8, 0), (14, 4), (14, 11), (8, 15), (2, 11), (2, 4)], fill=(*base, 255), outline=(*metal, 255))
    d.polygon([(8, 3), (11, 5), (11, 10), (8, 12), (5, 10), (5, 5)], fill=(*glow, 255))
    d.rectangle((7, 4, 8, 10), fill=(230, 250, 255, 255))
    im.save(root / 'item' / f'{name}.png', optimize=True)

for name, palette in variants.items():
    entity_texture(name, *palette)
core_texture('conversion_core', *variants['stratos'])
core_texture('wraith_core', *variants['wraith'])
core_texture('vanguard_core', *variants['vanguard'])
