# `hue` - Rotates Hue About the Grey Axis

## Overview

This module rotates a pixel's colour around the grey axis of the RGB cube, in
steps of 15 degrees. Brightness and greys are preserved; only the hue turns.
It is a fixed-latency unit that cannot stall: IPU starts it at most once every
two clocks and the result appears exactly `LATENCY` clocks later.

## Parameters

| Name | Default | Description |
|---|---|---|
| `LATENCY` | 4 | Clocks from `i_start` to `o_done`. Chosen by the implementer and reported to IPU |

## Ports

| Name | Width | Direction | Description |
|---|---|---|---|
| `clk`, `rst_n` | 1 each | Input | Clock and active-low reset |
| `i_start` | 1 | Input | Capture `i_colour` and `i_angle`; at most once every 2 clocks |
| `i_colour` | 24 | Input | RGB888 pixel, `{r, g, b}` |
| `i_angle` | 5 | Input | Angle step 0-23 (degrees = 15 x step). 24-31 never arrive; IO rejects them |
| `o_done` | 1 | Output | One-cycle pulse, exactly `LATENCY` clocks after its `i_start` |
| `o_colour` | 24 | Output | Rotated RGB888 pixel, valid while `o_done` is high |

## Architecture Overview

### Rotation matrix

Rotating about the grey axis `(1,1,1)` gives a circulant matrix with three
coefficients `a`, `b`, `c`:

```text
r' = clamp((a*r + b*g + c*b_in + 128) >>> 8)
g' = clamp((c*r + a*g + b*b_in + 128) >>> 8)
b' = clamp((b*r + c*g + a*b_in + 128) >>> 8)
```

Coefficients are signed Q2.8 (`256` = 1.0, range -86 to 256, so 10 bits).
Each row adds to exactly 256, which is why greys come out unchanged.
Add `128` before the arithmetic shift to round, then clamp to 0-255.

### Coefficient table

Only eight rows are stored. Steps 8-15 use the row for `step - 8` rotated once,
`(a, b, c) -> (b, c, a)`; steps 16-23 rotate it twice.

| Step | Degrees | a | b | c |
|---|---|---|---|---|
| 0 | 0 | 256 | 0 | 0 |
| 1 | 15 | 250 | -35 | 41 |
| 2 | 30 | 233 | -62 | 85 |
| 3 | 45 | 206 | -80 | 130 |
| 4 | 60 | 171 | -85 | 170 |
| 5 | 75 | 130 | -80 | 206 |
| 6 | 90 | 85 | -62 | 233 |
| 7 | 105 | 41 | -35 | 250 |

At step 8 (120 degrees) the coefficients become `(0, 0, 256)`, so the output is
exactly `{b, r, g}`; step 16 gives `{g, b, r}`. The plain channel swaps are the
first test case of the general design, not a separate mode.

### Resources

Each pixel needs nine products of an 8-bit unsigned channel and a 10-bit signed
coefficient. With one pixel every two clocks, at least five multipliers are
required if they are shared, nine if not. The choice between table size,
multiplier count and `LATENCY` is the core design decision of this task;
record it and its area in the module notes.

## Implementation Tasks

1. Start with steps 0, 8 and 16, which are plain channel swaps.
2. Build the 8-row table and the row rotation.
3. Implement the products, rounding and clamp, and pipeline them to meet the
   two-clock issue rate.
4. Compare against `hue()` in `test/colourplay_model.py` for every step with
   random pixels, greys (must be unchanged), black, white and pure primaries.
   Starts two clocks apart must each produce exactly one result.

Try it in the [filter playground](../../demos/playground.html).
