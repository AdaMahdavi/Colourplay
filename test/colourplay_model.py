"""Bit-exact integer reference model of the Colourplay IPU and VGA colour path.

Matches docs/encoding/configuration.md and the module pages. Use these
functions as expected values in cocotb tests.

    python test/colourplay_model.py   # regenerates docs/demos/pipeline.gif (needs Pillow)
"""

# Hue rotation about the grey axis, 15 degree steps. Row k holds (a, b, c) in
# Q2.8 (256 = 1.0) for steps 0..7; steps 8..23 rotate the triple once or twice.
HUE_STEPS = 24
HUE_TABLE_0_TO_7 = (
    (256, 0, 0), (250, -35, 41), (233, -62, 85), (206, -80, 130),
    (171, -85, 170), (130, -80, 206), (85, -62, 233), (41, -35, 250),
)


def hue_coefficients(step):
    if not 0 <= step < HUE_STEPS:
        raise ValueError("hue angle steps 24..31 are reserved")
    a, b, c = HUE_TABLE_0_TO_7[step % 8]
    for _ in range(step // 8):
        a, b, c = b, c, a
    return a, b, c


def clamp8(v):
    return min(255, max(0, v))


def hue(pixel, step):
    """out = clamp((M * rgb + 128) >>> 8) with circulant M = [[a,b,c],[c,a,b],[b,c,a]]."""
    a, b, c = hue_coefficients(step)
    r, g, bl = pixel
    return (
        clamp8((a * r + b * g + c * bl + 128) >> 8),
        clamp8((c * r + a * g + b * bl + 128) >> 8),
        clamp8((b * r + c * g + a * bl + 128) >> 8),
    )


def colour_detect(pixel, reference, tolerance):
    return all(abs(p - r) <= tolerance for p, r in zip(pixel, reference))


def contrast(pixel, gain):
    # Python >> on negative ints floors, matching >>> in RTL.
    return tuple(clamp8(128 + (((c - 128) * gain) >> 4)) for c in pixel)


def ipu_pixel(pixel, cfg):
    """Returns (output_pixel, selected). Unselected pixels pass unchanged."""
    selected = colour_detect(pixel, cfg["reference"], cfg["tolerance"])
    out = pixel
    if selected:
        if cfg["hue_enable"]:
            out = hue(out, cfg["hue_angle"])
        if cfg["contrast_enable"]:
            out = contrast(out, cfg["contrast_gain"])
    return out, selected


def bbox(selected, width, min_run):
    """Box over pixels in horizontal runs of at least min_run selected pixels.

    selected: row-major booleans. Runs restart at each row. min_run 0 or 1
    counts every selected pixel. Returns inclusive (min_x, max_x, min_y, max_y)
    or None when nothing qualified.
    """
    need = max(1, min_run)
    box = None
    run = 0
    for i, sel in enumerate(selected):
        x, y = i % width, i // width
        if x == 0:
            run = 0
        run = min(run + 1, 255) if sel else 0
        if run >= need:
            x0 = x - need + 1 if run == need else x
            if box is None:
                box = [x0, x, y, y]
            else:
                box = [min(box[0], x0), max(box[1], x), min(box[2], y), max(box[3], y)]
    return tuple(box) if box else None


def on_box_edge(x, y, box):
    if box is None:
        return False
    x0, x1, y0, y1 = box
    return x0 <= x <= x1 and y0 <= y <= y1 and (x in (x0, x1) or y in (y0, y1))


BAYER = ((0, 8, 2, 10), (12, 4, 14, 6), (3, 11, 1, 9), (15, 7, 13, 5))


def rgb222(pixel, x=0, y=0, dither=False):
    """RGB888 -> RGB222 on the 0/85/170/255 DAC scale: level = (3*c + t) >> 8.

    t is 128 (round to nearest) or, with dither, a 4x4 ordered threshold
    16*BAYER + 8 by screen position. The sum never exceeds 1013, so no clamp.
    """
    t = 16 * BAYER[y % 4][x % 4] + 8 if dither else 128
    return tuple((3 * c + t) >> 8 for c in pixel)


def process_frame(pixels, width, cfg, previous_box):
    """Returns (rgb222 list, box for the next frame). Overlay uses previous_box."""
    outputs, selected = [], []
    for i, p in enumerate(pixels):
        out, sel = ipu_pixel(p, cfg)
        selected.append(sel)
        x, y = i % width, i // width
        if on_box_edge(x, y, previous_box):
            out = (255, 255, 255)
        outputs.append(rgb222(out, x, y, cfg["dither_enable"]))
    return outputs, bbox(selected, width, cfg["min_run"])


def config_registers(cfg):
    """The 16 x 8-bit configuration registers, index = address."""
    r, g, b = cfg["reference"]
    regs = [0] * 16
    regs[0x0] = int(cfg["hue_enable"]) | (int(cfg["contrast_enable"]) << 1) | (int(cfg["dither_enable"]) << 2)
    regs[0x1], regs[0x2], regs[0x3] = b, g, r
    regs[0x4] = cfg["tolerance"]
    regs[0x5] = cfg["contrast_gain"]
    regs[0x6] = cfg["hue_angle"]
    regs[0x7] = cfg["min_run"]
    return regs


DEFAULT_CFG = {
    "reference": (177, 100, 105),
    "tolerance": 48,
    "hue_enable": True,
    "hue_angle": 8,
    "contrast_enable": True,
    "contrast_gain": 0x18,
    "min_run": 8,
    "dither_enable": True,
}


def _self_check():
    import math

    for k in range(HUE_STEPS):
        a, b, c = hue_coefficients(k)
        assert a + b + c == 256, k
        t = math.radians(15 * k)
        assert abs(a / 256 - (math.cos(t) + (1 - math.cos(t)) / 3)) < 0.01, k
    assert hue((10, 20, 30), 0) == (10, 20, 30)
    assert hue((10, 20, 30), 8) == (30, 10, 20)
    assert hue((10, 20, 30), 16) == (20, 30, 10)
    assert all(hue((v, v, v), k) == (v, v, v) for v in (0, 77, 255) for k in range(24))
    assert contrast((77, 128, 200), 0x10) == (77, 128, 200)
    assert contrast((0, 255, 7), 0) == (128, 128, 128)
    assert contrast((0, 255, 100), 0xFF) == (0, 255, 0)
    assert bbox([0, 1, 1, 0, 1, 0], 6, 2) == (1, 2, 0, 0)
    assert bbox([0, 0, 0, 1], 4, 2) is None
    assert bbox([1, 0, 1, 1], 2, 2) == (0, 1, 1, 1)
    assert rgb222((200, 63, 0)) == (2, 1, 0)
    assert rgb222((255, 255, 255), 1, 3, True) == (3, 3, 3)
    assert rgb222((40, 40, 40), 0, 0, True) == (0, 0, 0)
    assert rgb222((40, 40, 40), 2, 1, True) == (1, 1, 1)
    for v in range(256):
        mean = sum(rgb222((v, v, v), x, y, True)[0] for y in range(4) for x in range(4)) / 16
        assert abs(85 * mean - v) < 4, v
        assert abs(85 * rgb222((v, v, v))[0] - v) <= 43, v


def _make_gif(source, out_path):
    from PIL import Image, ImageDraw

    im = Image.open(source).convert("RGB")
    w, h = im.size
    raw = im.tobytes()
    pixels = [tuple(raw[i:i + 3]) for i in range(0, len(raw), 3)]
    cfg = dict(DEFAULT_CFG)
    sel = [colour_detect(p, cfg["reference"], cfg["tolerance"]) for p in pixels]
    raw_box = bbox(sel, w, 1)
    box = bbox(sel, w, cfg["min_run"])

    def show(pix, title, detail, boxes=()):
        pix = list(pix)
        for bx, colour in boxes:
            for i in range(len(pix)):
                if on_box_edge(i % w, i // w, bx):
                    pix[i] = colour
        img = Image.new("RGB", (w, h))
        img.putdata(pix)
        img = img.resize((w * 2, h * 2), Image.NEAREST)
        canvas = Image.new("RGB", (w * 2, h * 2 + 42), (16, 19, 27))
        canvas.paste(img, (0, 42))
        d = ImageDraw.Draw(canvas)
        d.text((8, 5), title, fill=(230, 237, 247))
        d.text((8, 22), detail, fill=(142, 207, 252))
        return canvas

    def vga(cfg_):
        out, _ = process_frame(pixels, w, cfg_, box)
        return [(r * 85, g * 85, b * 85) for r, g, b in out]

    def apply(fn):
        return [fn(p) if s else p for p, s in zip(pixels, sel)]

    frames, durations = [], []

    def add(frame, ms):
        frames.append(frame)
        durations.append(ms)

    ref = "reference ({},{},{}), tolerance {}".format(*cfg["reference"], cfg["tolerance"])
    add(show(pixels, "Input image (RGB888)", "What the source sends"), 1800)
    mask = [(255, 255, 255) if s else (p[0] // 4, p[1] // 4, p[2] // 4) for p, s in zip(pixels, sel)]
    add(show(mask, "colour_detect: selection mask", ref + ". Background not selected."), 1800)
    add(show(mask, "bbox: raw box (red) vs run filter >= 8 (green)",
             "Stray noise pixels stretch the raw box", [(raw_box, (255, 60, 60)), (box, (60, 255, 90))]), 2400)
    add(show(apply(lambda p: hue(p, 4)), "hue: 60 degrees on selected pixels", "Background passes through unchanged"), 1600)
    add(show(apply(lambda p: contrast(p, 0x20)), "contrast: gain 2.0 on selected pixels",
             "clamp(128 + ((c - 128) * gain >>> 4))"), 1600)
    add(show(vga(dict(cfg, dither_enable=False)), "vga output (RGB222): plain truncation",
             "Only 64 colours: gradients band"), 1600)
    add(show(vga(cfg), "vga output (RGB222): ordered dither",
             "4x4 Bayer threshold by screen position"), 1600)
    for k in range(HUE_STEPS):
        add(show(vga(dict(cfg, hue_angle=k)), "vga output (RGB222): hue sweep",
                 "angle {} x 15 = {} deg, contrast 1.5, dithered, box from last frame".format(k, 15 * k)), 220)
    durations[-1] = 1500
    frames[0].save(out_path, save_all=True, append_images=frames[1:], duration=durations, loop=0, optimize=True)


if __name__ == "__main__":
    import pathlib
    import sys

    _self_check()
    root = pathlib.Path(__file__).resolve().parent.parent
    _make_gif(sys.argv[1] if len(sys.argv) > 1 else root / "docs/demos/scene.png", root / "docs/demos/pipeline.gif")
    print("model self-check passed; wrote docs/demos/pipeline.gif")
