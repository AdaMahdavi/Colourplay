# `colour_detect` - Selects Pixels by Colour Range

## Overview

This combinational module compares a pixel against a configured RGB reference.
It selects the pixel if the absolute difference in **every** channel is less
than or equal to the tolerance.

## Ports

| Name | Width | Direction | Description |
|---|---|---|---|
| `i_colour` | 24 | Input | Original RGB888 pixel |
| `i_reference` | 24 | Input | Reference RGB888 colour |
| `i_tolerance` | 8 | Input | Inclusive per-channel difference |
| `o_selected` | 1 | Output | All three comparisons passed |

## Architecture Overview

Compare channels separately, preserving enough width for subtraction. This is
colour segmentation, not semantic object detection. A background pixel with the
same colour also matches; disconnected matching regions share one bounding box.

## Implementation Tasks

Cover exact matches, equality at the tolerance boundary, one channel outside the
range, black/white extremes and subtraction without unsigned wraparound.
