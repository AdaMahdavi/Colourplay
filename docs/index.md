# Colourplay Documentation

## Overview

- [Introduction](introduction.md)
- [`tt_um_colourplay`](modules/tt_um_colourplay.md): Top-Level Module for Colourplay
- [Module Interface Contracts](modules/colourplay_if.md)

## Encoding

- [Number Formats](encoding/number_format.md)
- [Input Encoding](encoding/input.md)
- [Configuration Encoding](encoding/configuration.md)

## IO

- [`io`](modules/io/io.md): Receives prepared pixels and configuration

## IPU

- [`ipu`](modules/ipu/ipu.md): Instantiates Colour Detection, Hue, Contrast and Bounding Box Units
- [`colour_detect`](modules/ipu/colour_detect.md): Selects pixels by colour range
- [`hue`](modules/ipu/hue.md): Rotates colour channels
- [`contrast`](modules/ipu/contrast.md): Adjusts colour contrast
- [`bbox`](modules/ipu/bbox.md): Tracks the selected region

## VGA

- [`vga`](modules/vga/vga.md): Schedules pixel requests and drives the display

## Development

- [Implementation Tasks](tasks.md)
- [Open Issues](open_issues.md)
