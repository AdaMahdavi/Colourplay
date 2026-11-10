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
one-pixel inclusive border. Quantize after overlay by selecting channel bits
7:6. Force RGB to zero in blanking and register RGB and sync consistently.

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
the box overlay and quantization. RGB, markers and synchronization must be
checked at the displayed pixel, not just at a pipeline input.
