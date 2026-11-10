# Module Interface Contracts

## Overview

Colourplay uses explicit ports rather than SystemVerilog `interface` objects,
following the author's PCS templates. This page documents the channel contracts;
there is no RTL file named `colourplay_if.sv`.

All channels are synchronous to `clk`. There are no clock-domain crossings in
the baseline. Use a clock enable for pixel timing, not a generated fabric clock.

## Pixel Channel

Direction is from the source module's point of view.

| Signal | Width | Direction | Meaning |
|---|---|---|---|
| `colour` | 24 | Output | `{r,g,b}`, eight bits per channel |
| `valid` | 1 | Output | Payload and sideband available |
| `ready` | 1 | Input | Sink can accept the pixel |
| `x`, `y` | 10 each | Output | Logical active-image coordinates |
| `sof`, `eof` | 1 each | Output | First/last pixel of the frame |

A transfer occurs when valid and ready are both high at the rising edge.
While stalled, keep valid, colour and all sideband stable. Do not count a held
pixel more than once. SOF/EOF have meaning only on accepted pixels.

IO is the source to IPU; IPU is the source to VGA. Coordinates/frame markers
travel alongside the RGB888 colour channel.

IO additionally carries `previous_frame_bad`, sampled only with accepted SOF.
It describes errors in the frame that just ended, not the new SOF pixel.
Keep this bit stable along with the pixel while stalled.

## VGA Request Channel

VGA emits `request`, `request_x`, `request_y`, `request_sof` and `request_eof`.
Each request names a future active pixel, not the current raster position.
IO saves this metadata with the corresponding two-beat input transaction.

The request level spans a two-clock slot. Both VGA and IO must use the same
first-edge slot phase. Internally IO observes the request once per slot.

## Bounding Box Channel

IPU outputs `box_valid`, `min_x`, `max_x`, `min_y` and `max_y`, each bound ten bits.
Bounds are inclusive. These registers describe the previous completed input
frame. VGA snapshots them for display at the next visible SOF and holds that
snapshot throughout the display frame, despite advance input requests.

## Error Channel

IO's `error` is sticky until reset, including illegal configuration writes.
VGA latches it and displays a red border on active video until reset. Therefore
an error occurring in blanking is still visible in the next frame.

IO separately accumulates reception errors for the current input frame. When
assembling the next valid SOF, it attaches the old history as
`previous_frame_bad` before clearing that per-frame history. Bbox publishes the
old bounds only when this bit is zero and there were selected pixels. This
qualification survives the SOF that clears the old reception history.

## Latency and Storage

Target throughput is one pixel per two clocks. `REQUEST_LEAD=16` pixel slots is
a provisional end-to-end budget, including source response, assembly, IPU and
VGA output registering. An implementation must prove this budget before the
pin protocol is frozen.

IO requires a 12-bit partial-beat register plus one 24-bit completed-pixel holding
register and its valid/coordinate/frame/error sideband. In addition, reserve
three request-metadata entries of 22 bits each (66 payload bits plus occupancy
state): requests at edges n, n+2 and n+4 may coexist when beat 0 is sampled.
An equivalent cycle delay implementation is acceptable. IPU requires stage registers.
VGA requires bounded scanout staging sized from the measured latency and maximum
occupancy. There is no specified line buffer or frame buffer.

For sizing, a VGA pixel record is 46 bits: RGB24, x10, y10, SOF1,
EOF1, plus a separate valid bit (47 total if not tracked by FIFO pointers).
The IO holding record additionally carries `previous_frame_bad` (48 bits total
including valid).
A provisional 16-record staging allocation would be 736 payload bits, not an
area-approved depth. Reducing or eliminating it requires a cycle-accurate
fixed-latency contract, not an assumption that average rates match.
