# `bbox` - Tracks the Selected Region

## Overview

This unit finds the inclusive minimum and maximum coordinates of the selected
pixels in a frame. A streaming run-length filter ignores isolated noise so that a
few stray matches do not stretch the box across the image.

## Ports

| Name | Width | Direction | Description |
|---|---|---|---|
| `clk`, `rst_n` | 1 each | Input | Clock and active-low reset |
| `i_accept` | 1 | Input | One pixel transferred |
| `i_selected` | 1 | Input | Original pixel matched the colour range |
| `i_x`, `i_y` | 10 each | Input | Pixel coordinates |
| `i_sof` | 1 | Input | First accepted pixel of a frame |
| `i_previous_frame_bad` | 1 | Input | Error history of the old frame, qualified by accepted SOF |
| `i_min_run` | 8 | Input | Configuration register `0x7`; 0 and 1 disable filtering |
| `o_valid` | 1 | Output | Previous frame contained qualifying pixels |
| `o_min_x`, `o_max_x`, `o_min_y`, `o_max_y` | 10 each | Output | Previous-frame bounds |

## Architecture Overview

### Run-length filter

Count consecutive selected pixels on the current row; restart the count at
`x == 0` and on any unselected pixel. A selected pixel counts toward the box
only once the run has reached `need = max(1, i_min_run)`, so 0 and 1 both
count every selected pixel. On the pixel where the run first reaches `need`, the
run's first pixel `x - need + 1` becomes the `min_x` candidate; using
`i_min_run` directly would give `x + 1` at 0. This needs a counter, not a line
buffer.

The colour effects still apply to every selected pixel; only the box uses the
filter.

### Frame publication

Maintain current-frame bounds and an `any_selected` bit separately from the
published box. At an accepted SOF, publish the old frame's bounds, clear current
state and include that same SOF pixel in the new frame if it qualifies. An empty
old frame clears `o_valid`. Also clear output valid when
`i_previous_frame_bad` is set on that SOF; the old error history must not be
mistaken for a failure of the new frame's first pixel.

The display uses previous-frame geometry, which is correct for a repeated static
image and one frame behind a changing source. VGA holds a separate display
snapshot so advance processing of a new frame cannot move the visible box
mid-frame.

Two sets of four ten-bit bounds require 80 payload bits, plus valid/hit state
and an 8-bit run counter; VGA's display snapshot is additional storage.

## Implementation Tasks

Compare against `bbox()` in `test/colourplay_model.py`. Test a single matching
pixel, runs one shorter than and equal to `i_min_run`, runs touching x = 0 and
the right edge, runs broken by a row change, no matches, all matches, disjoint
regions and two consecutive frames. SOF with `i_accept=0` must not publish or
clear anything.
