# `vga` - Schedules Pixel Requests and Drives the Display

## Overview

This module owns the entire VGA path: pixel enable, raster counters, advance
input requests, local scanout storage, box overlay, colour quantization,
blanking and synchronization. There is no top-level timing scheduler beside it.

## Parameters

| Name | Default | Description |
|---|---|---|
| `REQUEST_LEAD` | 16 | Draft advance in pixel slots; must cover verified end-to-end latency |

## Ports

| Group | Signals |
|---|---|
| Clock/reset | `clk`, `rst_n` |
| Requests to IO | `o_request`, `o_request_x[9:0]`, `o_request_y[9:0]`, `o_request_sof`, `o_request_eof` |
| Pixel sink from IPU | `i_colour[23:0]`, `i_valid`, `o_ready`, `i_x[9:0]`, `i_y[9:0]`, `i_sof`, `i_eof` |
| Bounding box | `i_box_valid`, `i_min_x[9:0]`, `i_max_x[9:0]`, `i_min_y[9:0]`, `i_max_y[9:0]` |
| Status | `i_error` |
| Configuration | `i_dither_enable` (register `0x0` bit 2) |
| Display pins | `o_vga[7:0]` |

## Architecture Overview

Generate a pixel enable every two system clocks, without creating a second
clock domain. Use the following target raster:

| Axis | Visible | Front porch | Sync | Back porch | Total |
|---|---|---|---|---|---|
| Horizontal | 640 | 16 | 96 | 48 | 800 |
| Vertical | 480 | 10 | 2 | 33 | 525 |

HSYNC and VSYNC are active-low. A 25 MHz pixel rate yields about 59.52 Hz,
not exactly the nominal 25.175 MHz VGA timing. Physical monitor tolerance and
50 MHz closure on the selected IHP process remain unverified.

Issue each request `REQUEST_LEAD` slots ahead of its target visible position,
including wrap through line and frame blanking. The requested coordinate is
the future pixel's position. Save early arrivals in local staging; consume one
pixel at each visible display deadline. Size staging from worst-case occupancy,
including drain during blanking. Do not substitute a frame buffer.

At display SOF, snapshot the box for the previous input frame. Overlay a white
one-pixel inclusive border, then convert to RGB222. Force RGB to zero in
blanking and register RGB and sync consistently.

### Converting to RGB222

The output pins carry only two bits per channel (64 colours), because the eight
`uo_out` pins hold HSYNC, VSYNC and the [Tiny VGA Pmod](https://github.com/mole99/tiny-vga)
colour bits. Plain truncation keeps channel bits 7:6, which bands gradients and
hue changes. With `i_dither_enable`, add a threshold from a 4 x 4 ordered
(Bayer) matrix indexed by the **screen** position before truncating:

```text
d   = 4 * BAYER[y % 4][x % 4]            // 0..60
out = min(3, (channel + d) >> 6)          // per channel, 9-bit sum
```

```text
BAYER = {{ 0,  8,  2, 10},
         {12,  4, 14,  6},
         { 3, 11,  1,  9},
         {15,  7, 13,  5}}
```

The same `d` is added to all three channels. Neighbouring pixels then round
differently, so the eye averages them into in-between shades. The overlay
border (255) stays white because the sum saturates to 3.

## Errors and Reset

The display never pauses for `valid` or `ready`. Missing, duplicate or wrong-
coordinate pixels cause a visible magenta error pixel and sticky frame error.
On frame error, suppress box drawing. Latch IO error even during blanking and
show a red active-video border until reset. Reception lock may recover on a new
frame without clearing this diagnostic. Recovery must preserve raster timing.
Do not silently repeat an unrelated old pixel.

Reset clears staged data, box-valid and lock. Start raster scheduling in blanking
to allow the first frame's prefetched pixels to arrive.

## Implementation Tasks

First prove counters and sync with a local test pattern. Then implement the
request/response path, occupancy accounting and error handling. Only then add
the box overlay, then RGB222 conversion with dithering. RGB, markers and synchronization must be
checked at the displayed pixel, not just at a pipeline input.
