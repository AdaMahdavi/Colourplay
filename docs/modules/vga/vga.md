# `vga` - Schedules Pixel Requests and Drives the Display

## Overview

This module owns the entire VGA path: pixel enable, raster counters, advance
input requests, local scanout storage, box overlay, colour quantization,
blanking and synchronization. There is no top-level timing scheduler beside it.

## Parameters

| Name | Default | Description |
|---|---|---|
| `REQUEST_LEAD` | 8 | Advance in pixel slots; must cover the measured end-to-end latency |
| `STAGING_DEPTH` | 4 | Staging entries; at least `REQUEST_LEAD` minus the minimum measured latency in slots |

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

HSYNC and VSYNC are active-low. A 25 MHz pixel rate yields about 59.52 Hz
instead of the 59.94 Hz of nominal 25.175 MHz timing; monitors and the VGA
playground accept it.

Issue each request `REQUEST_LEAD` slots ahead of its target visible position,
including wrap through line and frame blanking. The requested coordinate is
the future pixel's position. Save early arrivals in local staging; consume one
pixel at each visible display deadline. A pixel waits in staging for
`REQUEST_LEAD` minus its latency, so occupancy is at most `REQUEST_LEAD - L_min`
where `L_min` is the minimum end-to-end latency in slots. Measure it and confirm
`STAGING_DEPTH` covers it. Do not substitute a frame buffer.

At display SOF, snapshot the box for the previous input frame. Overlay a white
one-pixel inclusive border, then convert to RGB222. Force RGB to zero in
blanking and register RGB and sync consistently.

### Converting to RGB222

The output pins carry only two bits per channel (64 colours), because the eight
`uo_out` pins hold HSYNC, VSYNC and the [Tiny VGA Pmod](https://github.com/mole99/tiny-vga)
colour bits. The DAC levels are 0, 85, 170 and 255, so the quantiser scales by
3/256. Keeping channel bits 7:6 instead would show 128 as 170 and everything from
192 up as white. Without dither, round to the nearest level; with
`i_dither_enable`, use a threshold from a 4 x 4 ordered (Bayer) matrix indexed
by the **screen** position:

```text
t   = dither ? 16 * BAYER[y % 4][x % 4] + 8 : 128   // 8..248, or 128
out = (3 * channel + t) >> 8                         // per channel, 10-bit sum
```

`3 * channel` is a shift and an add. The sum is at most 765 + 248 = 1013, so
`out` never exceeds 3 and needs no clamp. Averaged over a 4 x 4 tile, the
dithered output is within 1.5 % of full scale of the input.

```text
BAYER = {{ 0,  8,  2, 10},
         {12,  4, 14,  6},
         { 3, 11,  1,  9},
         {15,  7, 13,  5}}
```

The same `t` is used for all three channels. Neighbouring pixels then round
differently, so the eye averages them into in-between shades. The overlay
border (255) stays white for every threshold.

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
