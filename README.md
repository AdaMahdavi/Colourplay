![](../../workflows/gds/badge.svg) ![](../../workflows/docs/badge.svg) ![](../../workflows/test/badge.svg) ![](../../workflows/fpga/badge.svg)

# Colourplay

Colourplay is a standalone image-processing project for Tiny Tapeout. A prepared
source supplies RGB pixels, the chip selectively changes their colours, and a
VGA output displays the result. The project is designed for learning streaming
image processing, module-level verification and display pipelines.

**Status: design specification and student RTL skeletons.** The hierarchy is
wired, but processing and display modules are deliberately unimplemented.
Passing scaffold checks is not functional verification or tapeout readiness.

- [Design documentation](https://adamahdavi.github.io/Colourplay/)
- [TinyTapeout 3D viewer](https://adamahdavi.github.io/Colourplay/gds/)
- [Introduction](docs/introduction.md)
- [Module interfaces](docs/modules/colourplay_if.md)
- [Implementation tasks](docs/tasks.md)
- [Editable architecture diagram](docs/diagrams/colourplay.drawio)

## Visual demos

**[Open the filter playground](https://adamahdavi.github.io/Colourplay/demos/playground.html)**:
click an object to select its colour, then change tolerance, the box noise filter,
hue angle and contrast. Only the selected object changes; the sky and ground are
left alone.

![Filter pipeline: input, mask, box filter, hue, contrast, VGA hue sweep](docs/demos/pipeline.gif)

Both are generated from `test/colourplay_model.py`, the same integer arithmetic
the RTL must match. They are not recordings of the RTL.

## Hierarchy

```text
tt_um_colourplay
├── io
├── ipu
│   ├── colour_detect
│   ├── hue
│   ├── contrast
│   └── bbox
└── vga
```

Module templates use explicit `i_`/`o_` ports grouped by their neighbouring module,
parameters where appropriate, and implementation hints rather than completed
solutions, following the author's
[PCS templates](https://github.com/AdaMahdavi/10G-Ethernet-Parser/tree/main/RTL/PCS).

## Build the documentation

```sh
python3 -m venv .venv
. .venv/bin/activate
pip install -r docs/requirements.txt
mkdocs build --strict
mkdocs serve
```

## Check the skeleton

With Icarus Verilog and Make installed:

```sh
pip install -r test/requirements.txt
make -C test
```

This checks only elaboration, reset and scaffold tie-offs. For an explicit
**expected failure** showing that functional sign-off is not available:

```sh
REQUIRE_FUNCTIONAL=1 make -C test
```

Each RTL template has `IMPLEMENTED = 0`. Implement the module and its acceptance
tests before changing this marker. The GDS workflow runs on every push and
publishes the spec site plus the TinyTapeout viewer (under `/gds/`) to GitHub Pages.
