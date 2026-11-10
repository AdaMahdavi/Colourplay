## How it works

Colourplay is a standalone image-processing prototype. A prepared source sends
two 12-bit beats per RGB888 pixel. IO assembles pixels, IPU selectively changes
their colours, and VGA schedules requests and displays RGB222 with a bounding box.
Image storage stays in the source harness, not on the chip.

The RTL currently consists of wired student skeletons. It does not yet process
images or generate valid VGA timing. Clock, area and I/O protocol are draft targets.

## How to test

Run the scaffold smoke test in `test/`. Functional acceptance criteria and module
specifications are published at https://adamahdavi.github.io/Colourplay/.

## External hardware

The baseline is a simulation/playground source and viewer. Physical operation
requires a synchronous image source and a TinyVGA-compatible DAC/adapter.
