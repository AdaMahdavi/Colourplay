# Verification Objectives

## Current Checks

The supplied cocotb smoke test elaborates the wired hierarchy and checks the
intentional inactive outputs. It does **not** test pixel processing, UART, VGA
timing or protocol compliance. `REQUIRE_FUNCTIONAL=1` explicitly fails until
functional tests replace this scaffold.

## Unit Acceptance Tests

| Module | Required checks |
|---|---|
| IO | Two-beat order, consecutive requests, metadata delay, held output, reserved writes, malformed beats, SOF recovery |
| Colour Detection | Inclusive threshold, per-channel failure, subtraction extremes |
| Hue | Three exact channel permutations, invalid mode rejection |
| Contrast | Identity, zero gain, max gain, signed shift, positive/negative clamp |
| Bounding Box | Empty, one-pixel, edges, disjoint pixels, accepted-SOF boundary |
| IPU | Pixel accounting, stable stalls, selective bypass, metadata/config alignment |
| VGA | Raster dimensions, sync widths/polarities, blanking RGB, request lead/wrap, staging occupancy, underflow/overflow |

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
bursts. Measure maximum staging occupancy at line/frame boundaries and derive
the chosen depth from that trace plus an analytical bound.

## Sign-Off Boundaries

Scaffold CI is not functional sign-off. Simulation is not physical sign-off.
Before fabrication, add synthesis/area reports, timing constraints for external
input/output paths, reset checks and the selected shuttle's precheck.
