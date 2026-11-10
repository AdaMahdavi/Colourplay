# Input Encoding

## Overview

This is a **draft synchronous parallel protocol**. The harness and chip share
`clk` at a target 50 MHz. The harness drives
inputs before each rising edge; outputs change after rising edges. A simulation
driver should drive on falling edges and sample only after settling.

## Pin Assignment

| Pins | Direction | Meaning |
|---|---|---|
| `ui_in[7:0]` | Input | `data[7:0]` |
| `uio_in[3:0]` | Input | `data[11:8]` |
| `uio_in[4]` | Input | Beat valid |
| `uio_in[5]` | Input | Start of frame on the first beat of pixel (0,0) |
| `uio_in[6]` | Input | Configuration write qualifier |
| `uio_out[7]` | Output | Pixel request |
| `clk`, `rst_n` | Input | Shared clock and active-low reset |

`uio_oe = 0x80`. The data word is `{uio_in[3:0], ui_in[7:0]}`.

## Pixel Transfers

| Beat | `data[11:0]` |
|---|---|
| 0 | `{R[7:0], G[7:4]}` |
| 1 | `{G[3:0], B[7:0]}` |

For every request slot, the harness returns both beats. Requests may be
consecutive: each slot occupies two system clocks. With request sampled at edge
`n`, beat 0 is sampled at `n+4` and beat 1 at `n+5`; the next request, if any,
is sampled at `n+2`. The request signal is high across both edges of a slot,
but counts as **one** request on its first edge. Slot phase resets with the VGA
counter phase. The harness mirrors this phase from shared reset and clock.

SOF is asserted only with beat 0 of the first pixel. IO must compare it with
VGA's saved request metadata. A missing, extra or mistimed beat raises an input
error. Frame restart occurs only at the next correctly timed SOF; invalid data
must not shift the coordinates of subsequent pixels.

There is no physical `ready` input to the source. Requests define fixed
deadlines, not an elastic bus. Internal `valid/ready` is separately specified.

## Configuration Transfers

When `config=1` and `valid=0`, one word contains `{address[3:0], value[7:0]}`.
Writes are allowed only while VGA is not requesting pixels and IO has no pending
responses, during vertical blanking. IO updates shadow registers and commits them
before accepting the next frame's first pixel.

Simultaneous config/valid, reserved configuration values, SOF on beat 1 and
configuration outside the allowed window are protocol errors.
Reject such writes without changing the shadow register. Keep an error
indication sticky until reset, so errors during blanking remain visible.

## Reset and Recovery

After reset, keep valid/config/SOF low. VGA must spend the initial lead interval
in blanking before requesting pixel (0,0); the source sends nothing until requested.
Hold reset for at least four system clocks and release it on a falling edge in
simulation. Shared slot phase must be reacquired after every reset.

On input error, remember that the current frame's bounding-box result is invalid
and show an error indication. At the next assembled SOF, attach the remembered
old-frame error to the pixel's `previous_frame_bad` sideband before clearing the
per-frame history. The separate sticky display error clears only on reset.
Clear protocol lock at the adapter and reacquire it at a
correctly timed SOF. The exact lock FSM is a student design task.
