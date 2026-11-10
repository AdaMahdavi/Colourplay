# `ipu` - Instantiates Colour Detection, Hue, Contrast and Bounding Box Units

## Overview

The Image Processing Unit receives completed RGB888 pixels from IO. It selects a
colour range, transforms selected pixels and tracks their bounding box. It does
not perform ray intersections or determine object identity.

## Parameters

The baseline uses 8-bit colour channels and 10-bit coordinates. The initial
templates keep these widths explicit.

## Ports

| Group | Signals |
|---|---|
| Clock/reset | `clk`, `rst_n` |
| Active configuration | `i_configuration[127:0]` |
| Pixel sink from IO | `i_colour[23:0]`, `i_valid`, `o_ready`, `i_x[9:0]`, `i_y[9:0]`, `i_sof`, `i_eof` |
| Frame qualification from IO | `i_previous_frame_bad`, sampled with accepted SOF |
| Pixel source to VGA | `o_colour[23:0]`, `o_valid`, `i_ready`, `o_x[9:0]`, `o_y[9:0]`, `o_sof`, `o_eof` |
| Bounding box | `o_box_valid`, `o_min_x[9:0]`, `o_max_x[9:0]`, `o_min_y[9:0]`, `o_max_y[9:0]` |

## Architecture Overview

| Instance | Module | Purpose |
|---|---|---|
| `u_colour_detect` | [`colour_detect`](colour_detect.md) | Classify the original colour |
| `u_hue` | [`hue`](hue.md) | Rotate selected colour channels |
| `u_contrast` | [`contrast`](contrast.md) | Apply gain around channel midpoint |
| `u_bbox` | [`bbox`](bbox.md) | Track selected accepted coordinates |

Colour detection always uses the unmodified input. Hue precedes contrast when
both are enabled. Bypass each disabled effect; bypass the entire transform for
unselected pixels. Selection must not change because an earlier effect altered
the colour.

Maintain a fixed latency across enable/mode combinations in the standalone
display path. The exact stage count is an implementation decision subject to
the VGA lead budget. Transfer coordinates and frame markers alongside RGB.

The skeleton instantiates the four children but holds output valid and ready
low. It is not a bypass implementation.

## Implementation Tasks

Choose stage boundaries, implement elastic ready/valid registers, implement
effect-enable/bypass muxes and prove that every accepted input produces exactly
one output with unchanged metadata. A stalled stream must not double-count box
samples.
