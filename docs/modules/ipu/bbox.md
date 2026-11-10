# `bbox` - Tracks the Selected Region

## Overview

This unit stores the inclusive minimum and maximum coordinates of selected
pixels. It tracks one box around all matching pixels in a frame.

## Ports

| Name | Width | Direction | Description |
|---|---|---|---|
| `clk`, `rst_n` | 1 each | Input | Clock and active-low reset |
| `i_accept` | 1 | Input | One pixel transferred |
| `i_selected` | 1 | Input | Original pixel matched the colour range |
| `i_x`, `i_y` | 10 each | Input | Pixel coordinates |
| `i_sof` | 1 | Input | First accepted pixel of a frame |
| `i_previous_frame_bad` | 1 | Input | Error history of the old frame, qualified by accepted SOF |
| `o_valid` | 1 | Output | Previous frame contained selected pixels |
| `o_min_x`, `o_max_x`, `o_min_y`, `o_max_y` | 10 each | Output | Previous-frame bounds |

## Architecture Overview

Maintain current-frame bounds and an `any_selected` bit separately from the
published box. At an accepted SOF, publish the old frame's bounds, clear current
state and include that same SOF pixel in the new frame if selected. An empty
old frame clears `o_valid`. Also clear output valid when
`i_previous_frame_bad` is set on that SOF; the old error history must not be
mistaken for a failure of the new frame's first pixel.

The display uses previous-frame geometry, which is correct for a repeated static
image and one frame behind a changing source. VGA holds a separate display
snapshot so advance processing of a new frame cannot move the visible box
mid-frame. Invalid input frames require suppression of their result.

Two sets of four ten-bit bounds require 80 payload bits, plus valid/hit state;
VGA's display snapshot is additional storage.

## Implementation Tasks

Test a single matching pixel, border pixels, no matches, all matches, disjoint
regions and two consecutive frames. SOF with `i_accept=0` must not publish or
clear anything.
