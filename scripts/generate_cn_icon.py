#!/usr/bin/env python3
"""CN: Original Papercart paper/cart artwork (A1), Python standard library only.

Run from any directory, then use flutter_launcher_icons_cn.yaml. Geometry is
shared by the SVG source and supersampled PNGs, so assets remain reproducible.
"""
from pathlib import Path
import struct
import zlib

OUT = Path(__file__).resolve().parents[1] / 'assets/cn'
BG = (20, 61, 70, 255)
WHITE = (255, 250, 235, 255)
GOLD = (242, 184, 92, 255)
# All foreground geometry stays within the adaptive icon safe region.
SHAPES = [
    (WHITE, [(36, 22), (56, 22), (65, 31), (65, 58), (36, 58)]),
    (GOLD, [(56, 22), (56, 32), (65, 32)]),
    (BG, [(41, 38), (59, 38), (59, 41), (41, 41)]),
    (BG, [(41, 45), (57, 45), (57, 48), (41, 48)]),
    (GOLD, [(23, 46), (29, 46), (36, 64), (65, 64), (69, 53),
            (74, 55), (69, 69), (32, 69), (25, 51), (23, 51)]),
]
CIRCLES = [(39, 76, 4), (62, 76, 4)]


def inside(x, y, points):
    hit = False
    j = len(points) - 1
    for i, (xi, yi) in enumerate(points):
        xj, yj = points[j]
        if (yi > y) != (yj > y) and x < (xj-xi)*(y-yi)/(yj-yi)+xi:
            hit = not hit
        j = i
    return hit


def pixel(x, y, mode):
    color = BG if mode == 'full' else (0, 0, 0, 0)
    for fill, points in SHAPES:
        if inside(x, y, points):
            color = fill
    for cx, cy, r in CIRCLES:
        if (x-cx)**2 + (y-cy)**2 <= r*r:
            color = GOLD
    if mode == 'mono' and color[3]:
        color = (255, 255, 255, 255)
    return color


def png(path, mode, size=512):
    rows = bytearray()
    for y in range(size):
        rows.append(0)
        for x in range(size):
            samples = [pixel((x+dx)*100/size, (y+dy)*100/size, mode)
                       for dy in (.25, .75) for dx in (.25, .75)]
            alpha = sum(p[3] for p in samples)
            # Premultiplied averaging keeps transparent edges free of dark halos.
            rows.extend([round(sum(p[c]*p[3] for p in samples)/alpha)
                         if alpha else 0 for c in range(3)] + [round(alpha/4)])
    def chunk(kind, data):
        return (struct.pack('!I', len(data)) + kind + data +
                struct.pack('!I', zlib.crc32(kind+data)))
    path.write_bytes(b'\x89PNG\r\n\x1a\n' +
                     chunk(b'IHDR', struct.pack('!2I5B', size, size, 8, 6, 0, 0, 0)) +
                     chunk(b'IDAT', zlib.compress(rows, 9)) + chunk(b'IEND', b''))


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    svg = ['<!-- CN: Original Papercart artwork, A1, 2026-10-19. -->',
           '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">',
           '<path fill="#143d46" d="M0 0H100V100H0Z"/>']
    for color, points in SHAPES:
        fill = '#'+''.join(f'{c:02x}' for c in color[:3])
        coords = ' '.join(f'{x},{y}' for x, y in points)
        svg.append(f'<polygon fill="{fill}" points="{coords}"/>')
    for x, y, r in CIRCLES:
        svg.append(f'<circle fill="#f2b85c" cx="{x}" cy="{y}" r="{r}"/>')
    (OUT/'papercart.svg').write_text('\n'.join(svg+['</svg>', '']))
    for name, mode in [('papercart', 'full'), ('papercart_foreground', 'fg'),
                       ('papercart_monochrome', 'mono')]:
        png(OUT/f'{name}.png', mode)
    # CN: Replace the legacy, unused launcher_icon resources too, so no old
    # launcher artwork is packaged. flutter_launcher_icons writes ic_launcher.
    res = OUT.parents[1] / 'android/app/src/main/res'
    for density, size in [('mdpi', 48), ('hdpi', 72), ('xhdpi', 96),
                          ('xxhdpi', 144), ('xxxhdpi', 192)]:
        png(res/f'mipmap-{density}/launcher_icon.png', 'full', size)


if __name__ == '__main__':
    main()
