# Implementation Tasks

## Working Agreement

Each student owns **one task** below. Every task starts with a small first
step, then builds the main piece, and is checked against `test/colourplay_model.py`.
The tasks differ in kind: IO and VGA carry the most state, hue the most
arithmetic. The table under [Comparing the tasks](#comparing-the-tasks) shows
where each one's difficulty lies.

Module files are port-complete starting points with placeholder tie-offs.
Replace them with real logic and tests;
never mark a module complete merely because it compiles. Change a shared
port only by agreement with the owner on the other side.

## Tasks

### Task 1 - Input Unit (`io`)

Turn the two-beat pin protocol into RGB888 pixels with the right coordinates.

- **Start with:** assemble beats from a fixed pattern into pixels.
- **Then build:** a three-entry request queue that pairs each response with the
  request VGA made 4 clocks earlier; the configuration registers (56 stored
  bits, shadow and active copies) that only change between frames; illegal-write
  rejection; the lock and error tracking that produces `previous_frame_bad`.
- **Done when:** back-to-back requests, missing or extra beats, bad SOF and
  illegal writes all behave as in [Input Encoding](encoding/input.md).

### Task 2 - VGA Output Unit (`vga`)

Drive a stable 640 x 480 picture and ask for pixels early enough.

- **Start with:** a colour-bar test pattern, viewed in the
  [VGA playground](https://vga-playground.com/).
- **Then build:** request scheduling `REQUEST_LEAD` slots ahead, including wrap
  through blanking; scanout staging sized from measured worst-case occupancy;
  box overlay from a per-frame snapshot; RGB222 output with ordered
  dithering; visible errors.
- **Done when:** sync widths and polarities, raster size, blanking, request
  order and the staging bound are proven in simulation.

### Task 3 - Hue Rotation (`hue`)

Rotate colours about the grey axis in 15 degree steps.

- **Start with:** steps 0, 8 and 16, which are plain channel swaps.
- **Then build:** the 8-row coefficient table and its rotation; the products,
  rounding and clamping; then cut the multiplier count as far as you can while
  staying bit-exact at one pixel every two clocks.
- **Done when:** all 24 steps match the model exactly, greys are unchanged,
  and the chosen latency and area are recorded.

### Task 4 - Selection, Contrast and Bounding Box (`colour_detect`, `contrast`, `bbox`)

Find the object, adjust its contrast and draw a tight box around it.

- **Start with:** `colour_detect`, the per-channel tolerance test.
- **Then build:** `contrast`, the saturating gain around 128; the run-length
  noise filter; min/max tracking on accepted pixels only; publishing at frame
  start, suppressing empty and bad frames.
- **Done when:** contrast matches the model at every gain, and the box matches
  the model with and without the filter, across frame boundaries and stalls.

### Task 5 - Processing Pipeline (`ipu`)

Join the colour units into one stream that never loses or repeats a pixel.

- **Start with:** a pass-through pipeline that delivers every pixel unchanged with
  its coordinates and frame markers.
- **Then build:** ready/valid stages around the fixed-latency, non-stallable `hue`;
  carrying selection bits and metadata alongside it; per-pixel bypass so
  unselected pixels keep their colour; equal latency in every mode.
- **Done when:** random stall patterns produce exactly one correct output per
  input with matching coordinates and frame markers.

### Task 6 - System Test Bench (`test/`)

Prove the whole chip draws the right picture.

- **Start with:** decode the VGA pins of a test pattern into a PNG.
- **Then build:** a cycle-exact cocotb source driver that answers pixel requests from
  an image; frame capture from the output pins; comparison against
  `process_frame()`; random configuration and error injection.
- **Done when:** a full frame matches the model pixel for pixel, and each
  injected fault is visible on screen.

## Comparing the Tasks

| Task | Arithmetic | State and timing | Interface contract | Verification focus |
|---|---|---|---|---|
| 1 IO | Light | Request queue, register file, lock | Pin protocol, metadata order | Protocol faults |
| 2 VGA | Light | Raster counters, scheduler, staging | Fixed display deadlines | Timing and occupancy |
| 3 Hue | Heavy (multiplier sharing) | Pipeline, multiplier sharing | Fixed latency, no stall | Bit-exact numerics |
| 4 Selection | Medium (3 contrast products) | Run counter, per-frame bounds | Accepted-pixel and SOF rules | Saturation, frame boundaries |
| 5 Pipeline | Light (bypass muxes) | Elastic stages, latency matching | Ready/valid both sides | Stall patterns |
| 6 Test bench | Model reuse | Cycle-exact driver | Both pin protocols | Whole-frame images |

With fewer than six students, the instructor takes task 6 first, then task 5.
Each student still owns exactly one task.

## Milestones

1. **Weeks 1-2:** first steps done; interfaces between neighbouring tasks agreed;
   each owner posts a yosys flip-flop and multiplier estimate against the area
   budget.
2. **Weeks 3-4:** an unfiltered image through the real request path (tasks
   1, 2, 5, 6); hue and selection pass their unit tests (tasks 3, 4).
3. **Weeks 5-6:** hue, contrast, selection and box on screen; recovery tests.
4. **Weeks 7-8:** full-frame comparisons, synthesis area against the 2x2 budget,
   documentation, and a demo using the [filter playground](demos/playground.html)
   settings.

## Completion Checklist

- Implemented RTL, matching module page and isolated tests.
- No unknown outputs, accepted-pixel loss or duplicates.
- Latency, throughput, storage and area measured against the budget.
- Negative tests exercise visible errors and clean recovery.
- Remove scaffold tie-offs only when the corresponding tests exist.

## Stretch Tasks

A 3-tap horizontal filter; several boxes for separate
objects; physical VGA bring-up. Vertical neighbourhood filters need line
storage and a separate memory budget.
