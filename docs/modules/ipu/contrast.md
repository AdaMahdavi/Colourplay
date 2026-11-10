# `contrast` - Adjusts Colour Contrast

## Overview

This combinational unit scales each channel's distance from 128 and saturates
the result to the unsigned eight-bit range.

## Ports

| Name | Width | Direction | Description |
|---|---|---|---|
| `i_colour` | 24 | Input | RGB888 colour |
| `i_gain` | 8 | Input | Unsigned Q4.4 gain |
| `o_colour` | 24 | Output | Saturated RGB888 result |

## Architecture Overview

For each channel:

```text
result = clamp(128 + (((channel - 128) * gain) >>> 4), 0, 255)
```

Subtraction and multiplication use signed widened operands. Convert the gain to
a nonnegative signed value before the multiply; an eight-bit signed cast alone
would make gains above `0x7F` negative. Arithmetic right shift rounds negative
values toward minus infinity. Clamp before truncating.

## Implementation Tasks

Verify identity at `gain=0x10`, constant midpoint at zero gain, both saturation
limits and negative intermediate values. Compare against an integer reference
model rather than approximate floating-point output.
