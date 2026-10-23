"""Generates lib/core/widgets/logo_strokes.dart for the animated splash screen.

    python tool/trace_logo.py

Renders icons/app-icon-no-bg.svg (headless Edge, see generate_icons.py; set EDGE to override) and
finds the pen path through each stroke of the wordmark: the cheapest route through the glyph
between the waypoints below, where cost falls steeply towards the middle of the stroke.
Waypoints are in SVG units, in writing order; each list is one pen-down stroke.
"""

import heapq
import re

from PIL import Image

from generate_icons import ROOT, read_svg, render_png

PX = 4  # rendered pixels per SVG unit
WAYPOINTS = [
    # g, then its connector into the a
    [(43, 143), (34, 142), (24, 145), (18, 152), (17, 162), (21, 171), (31, 179), (40, 175), (45, 165), (43, 145),
     (43, 141), (45, 155), (47, 169), (49, 184), (51, 199), (49, 210), (43, 214), (34, 210), (32, 201), (37, 192),
     (47, 182), (57, 175), (64, 167), (68, 164)],
    # a, its exit stroke, up and down the r
    [(92, 134), (84, 133), (75, 135), (69, 144), (68, 158), (71, 165), (82, 171), (91, 166), (95, 158), (92, 136),
     (95, 149), (97, 162), (102, 167), (110, 166), (115, 158), (116, 141), (117, 131), (118, 128), (121, 130),
     (125, 145), (128, 165)],
    # the r's shoulder, into the second a
    [(124, 141), (127, 133), (132, 128), (137, 126), (140, 130), (142, 133), (149, 134), (154, 132)],
    # a, and its connector into the g
    [(179, 123), (168, 120), (159, 125), (154, 136), (155, 147), (161, 154), (168, 156), (177, 151), (181, 141),
     (179, 123), (182, 140), (185, 149), (190, 153), (196, 152), (203, 145), (206, 141)],
    # g, running into the e
    [(229, 114), (220, 111), (210, 115), (205, 125), (205, 134), (208, 144), (217, 147), (226, 144), (232, 134),
     (230, 114), (232, 128), (235, 145), (237, 162), (239, 177), (235, 183), (226, 183), (219, 177), (218, 169),
     (224, 162), (233, 154), (240, 148), (248, 143), (257, 136), (266, 128), (273, 119), (274, 111), (270, 106),
     (262, 104), (256, 108), (253, 118), (254, 128), (258, 135), (266, 139), (274, 139), (280, 135)],
]


def glyph_mask(svg):
    png = ROOT / 'build/trace_logo/glyph.png'
    render_png(svg['text'], png, round(svg['size'] * PX))
    img = Image.open(png).convert('RGBA')
    w, h = img.size
    alpha = img.getchannel('A').load()
    return w, h, {(x, y) for y in range(h) for x in range(w) if alpha[x, y] > 128}


def depth(inside):
    """Chessboard distance of each glyph pixel to the outside."""
    d, cur, k = {}, set(inside), 0
    while cur:
        k += 1
        for p in cur:
            d[p] = k
        cur = {(x, y) for x, y in cur
               if all((x + dx, y + dy) in cur for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)))}
    return d


def route(a, b, inside, cost):
    dist, prev, queue = {a: 0.0}, {}, [(0.0, a)]
    while queue:
        c, p = heapq.heappop(queue)
        if p == b:
            break
        if c > dist[p]:
            continue
        for dx in (-1, 0, 1):
            for dy in (-1, 0, 1):
                q = (p[0] + dx, p[1] + dy)
                if q == p or q not in inside:
                    continue
                nc = c + cost[q] * (1.414 if dx and dy else 1)
                if nc < dist.get(q, float('inf')):
                    dist[q], prev[q] = nc, p
                    heapq.heappush(queue, (nc, q))
    path = [b]
    while path[-1] != a:
        path.append(prev[path[-1]])
    return path[::-1]


def snap(point, inside, d):
    """The deepest glyph pixel near a waypoint."""
    x, y = round(point[0] * PX), round(point[1] * PX)
    near = [(x + dx, y + dy) for dx in range(-12, 13) for dy in range(-12, 13) if (x + dx, y + dy) in inside]
    return max(near, key=lambda p: (d[p], -abs(p[0] - x) - abs(p[1] - y)))


def smooth(points, k=9):
    n = len(points)
    out = []
    for i in range(n):
        window = [points[min(max(j, 0), n - 1)] for j in range(i - k, i + k + 1)]
        out.append((sum(p[0] for p in window) / len(window), sum(p[1] for p in window) / len(window)))
    out[0], out[-1] = points[0], points[-1]
    return out[::3] + [points[-1]]


def extend(points, by=3.0):
    """Lengthens both ends along the stroke, out to the round end caps the middle line falls short of."""
    def out(end, inner):
        dx, dy = end[0] - inner[0], end[1] - inner[1]
        n = (dx * dx + dy * dy) ** 0.5 or 1
        return (round(end[0] + dx / n * by, 2), round(end[1] + dy / n * by, 2))
    return [out(points[0], points[3])] + points + [out(points[-1], points[-4])]


def glyph_ops(d):
    """Path data (absolute M/L/C/Z only) as a flat list: opcode 0 M, 1 L, 2 C, 3 Z, then coordinates."""
    ops = []
    for cmd, args in re.findall(r'([MLCZ])([^MLCZ]*)', d):
        nums = [float(v) for v in re.findall(r'-?\d*\.?\d+', args)]
        ops += [{'M': 0, 'L': 1, 'C': 2, 'Z': 3}[cmd], *nums]
    assert not re.search(r'[a-zA-Z]', re.sub(r'[MLCZ]', '', d)), 'unsupported path command'
    return ops


def wrap(name, values, close, indent='  '):
    """A Dart list literal of numbers, wrapped at 120 columns."""
    lines, line = [], indent
    for v in values:
        item = f'{v:g}, '
        if len(line) + len(item) > 120:
            lines.append(line.rstrip())
            line = indent
        line += item
    lines.append(line.rstrip())
    return [f'{name}['] + lines + [close]


def main():
    svg = read_svg('app-icon-no-bg.svg')
    w, h, inside = glyph_mask(svg)
    d = depth(inside)
    cost = {p: 1 + 200.0 / d[p] ** 3 for p in inside}
    strokes = []
    for waypoints in WAYPOINTS:
        pts = [snap(p, inside, d) for p in waypoints]
        path = [pts[0]]
        for a, b in zip(pts, pts[1:]):
            path += route(a, b, inside, cost)[1:]
        strokes.append(extend([(round(x / PX, 2), round(y / PX, 2)) for x, y in smooth(path)]))

    lines = [
        '// Generated by tool/trace_logo.py from icons/app-icon-no-bg.svg. Do not edit.',
        '// dart format off',
        '',
        '/// Size of the square the logo is drawn in.',
        f'const logoViewBox = {svg["size"]:g}.0;',
        '',
        '/// The wordmark outline: opcode (0 move, 1 line, 2 cubic, 3 close) followed by its coordinates.',
        *wrap('const logoGlyph = <double>', glyph_ops(svg['d']), '];'),
        '',
        '/// Pen paths through the wordmark in writing order, one list of x, y pairs per stroke.',
        'const logoStrokes = <List<double>>[',
        *[line for s in strokes for line in wrap('  ', [v for p in s for v in p], '  ],', '    ')],
        '];',
        '',
    ]
    out = ROOT / 'lib/core/widgets/logo_strokes.dart'
    out.write_text('\n'.join(lines), encoding='utf-8', newline='\n')
    print('wrote', out.relative_to(ROOT), [len(s) for s in strokes])


if __name__ == '__main__':
    main()
