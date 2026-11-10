# Implementation Tasks

## Working Agreement

Module files are port-complete starting points. `IMPLEMENTED=0`, constant
tie-offs and TODOs are intentional. Replace them with real logic and tests;
never mark a module complete merely because it compiles.

Assign people to module boundaries, not to overlapping pieces of one module.
Verification accompanies every task. The instructor owns image preparation,
the source driver and system integration decisions.

## Work Packages

| Task | Owner slot | Deliverable | Acceptance |
|---|---|---|---|
| IO-1: pixel input | 1 | Two-beat assembly and request metadata | Consecutive pixels, stalls, bad beats, SOF recovery |
| IO-2: configuration | 1 | Shadow/active registers | Reset defaults; no mid-frame changes; reject illegal writes |
| IPU-1: selection/contrast | 2 | Detector, saturating contrast | Integer-model agreement at boundaries |
| IPU-2: hue/control | 3 | Channel rotations and selective bypass | Original background preserved; equal latency by mode |
| IPU-3: box | 4 | Bounds and empty-frame state | Correct accepted-SOF publication and inclusive bounds |
| VGA-1: raster | 5 | Counter/sync test pattern | Exact 800 by 525 raster and active-low pulse widths |
| VGA-2: scanout | 5 | Requests, staging, overlay | No stale pixels; occupancy bound; visible errors |
| SYS-1: verification | 6 or shared | Replay tests and captured images | Whole-frame RGB/coordinates/sync comparisons |

With four people, combine the two IPU colour tasks and share system verification.
With five or six, preserve a clear verification/integration owner.

## Milestones

1. **Weeks 1-2:** agree cycle schedule; simulate IO assembly and VGA pattern
   independently; establish a source-driver test.
2. **Weeks 3-4:** display an unfiltered prepared image through the real request
   path; prove the staging occupancy bound and reset/recovery.
3. **Weeks 5-6:** selective contrast/channel rotation and bounding-box overlay;
   verify unchanged background and frame-latched settings.
4. **Weeks 7-8:** whole-system tests, image captures, synthesis estimates and
   documentation. Demonstrate mode changes using image replay.

## Completion Checklist

- Implemented RTL, matching module page and isolated tests.
- No unknown outputs, accepted-pixel loss or duplicates.
- Latency, throughput and storage measured; update the draft budget.
- Negative tests exercise visible errors and clean recovery.
- Remove scaffold tie-offs only when the corresponding tests exist.

## Stretch Tasks

Arbitrary-angle hue adjustment; ordered dithering; 3-tap horizontal filtering;
physical VGA source/DAC bring-up; synthesis and
placement feasibility. Vertical neighbourhood filters need additional line
storage and a separate memory budget.
