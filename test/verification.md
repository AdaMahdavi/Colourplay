# Verification Objectives

## Smoke Test

The cocotb smoke test elaborates the wired hierarchy and checks reset outputs.
`REQUIRE_FUNCTIONAL=1` makes it fail until functional tests replace it.

## Unit Acceptance Tests

| Module | Required checks |
|---|---|
| IO | Two-beat order, consecutive requests, metadata delay, held output, reserved writes, malformed beats, SOF recovery |
| Colour Detection | Inclusive threshold, per-channel failure, subtraction extremes |
| Hue | All 24 steps against the model, greys unchanged, steps 0/8/16 equal channel swaps, back-to-back starts |
| Contrast | Identity, zero gain, max gain, signed shift, positive/negative clamp |
| Bounding Box | Empty, one-pixel, edges, disjoint pixels, accepted-SOF boundary, runs one short of and equal to the minimum run |
| IPU | Pixel accounting, stable stalls, selective bypass, metadata/config alignment |
| VGA | Raster dimensions, sync widths/polarities, blanking RGB, request lead/wrap, staging occupancy, underflow/overflow, dither pattern against the model |

## System Test

The instructor driver loads an image in host memory, observes requests and emits
two beats per requested pixel at the exact specified delay. Test benches must
not drive ports in the same simulator phase that samples them.

Capture full frames from the **output pins**. Reconstruct RGB222 and compare
against the same quantized integer model. Check both pixel values and raster
position; a shifted image is a failure even if its histogram is correct.

Cover reset mid-pixel, missing first/second beats, extra valid beats, invalid
config, new settings during blanking, empty selected frames and first-frame
box suppression. A delayed or changing image should show the documented
one-frame box lag rather than mixing frame geometry.
Verify that bad-frame qualification survives the following SOF and that
configuration errors raised in blanking remain visible until reset.

The input rate must sustain one RGB888 pixel per two system clocks in active
bursts. Measure minimum and maximum latency and staging occupancy at line/frame
boundaries, and confirm `STAGING_DEPTH >= REQUEST_LEAD - L_min`.

## Synthesis

Report each module's flip-flop and multiplier count from yosys and compare it with
the area budget in [Module Interface Contracts](../docs/modules/colourplay_if.md).
