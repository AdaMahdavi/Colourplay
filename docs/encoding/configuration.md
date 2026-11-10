# Configuration Encoding

## Overview

IO maintains 16 eight-bit shadow registers. Register `n` occupies
`configuration[8*n +: 8]`. IPU receives the active copy, committed before a new
frame enters the processing pipeline. Do not alter a frame's settings halfway
through its pixels.

| Address | Name | Reset | Meaning |
|---|---|---|---|
| `0x0` | Effect enables | `0x00` | Bit 0: hue; bit 1: contrast; bit 2: VGA dither; bits 7:3 reserved zero |
| `0x1` | Reference blue | `0x00` | Selection reference B |
| `0x2` | Reference green | `0x00` | Selection reference G |
| `0x3` | Reference red | `0x00` | Selection reference R |
| `0x4` | Selection tolerance | `0x00` | Inclusive difference limit |
| `0x5` | Contrast gain | `0x10` | Unsigned Q4.4 |
| `0x6` | Hue angle | `0x00` | Step 0-23, degrees = 15 x step; 24-255 rejected |
| `0x7` | Box minimum run | `0x01` | Run-length noise filter for `bbox`; 0 and 1 disable it |
| `0x8`-`0xF` | Reserved | `0x00` | Writes must be zero |

The configuration reference is `configuration[31:8] = {R,G,B}`. Colour selection
and bounding-box tracking operate even when both effects are disabled.

Version 0 always enables the box overlay when valid; a programmable overlay
enable is a later interface extension. The baseline has no register readback
pins. Input/configuration errors are reported through IO's error signal and VGA's
visible error indication, sticky until reset. An invalid write leaves shadow
configuration unchanged.

The RTL currently exposes the configuration bus but does **not** implement these
registers or reset values.
