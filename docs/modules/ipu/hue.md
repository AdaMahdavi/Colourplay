# `hue` - Rotates Colour Channels

## Overview

The first implementation provides cyclic channel permutations. This produces a
visible colour effect with simple hardware. It is deliberately **not** an
arbitrary-angle hue rotation algorithm.

## Ports

| Name | Width | Direction | Description |
|---|---|---|---|
| `i_colour` | 24 | Input | RGB888 colour |
| `i_rotation` | 2 | Input | Rotation selection |
| `o_colour` | 24 | Output | Reordered channels |

## Architecture Overview

| Mode | Output |
|---|---|
| 0 | `{R,G,B}` |
| 1 | `{G,B,R}` |
| 2 | `{B,R,G}` |
| 3 | Reserved; IO rejects configuration |

No division, HSV conversion or multiplier is required. Mode 3 should be asserted
as invalid in verification, not advertised as another effect.

## Implementation Tasks

Implement the three permutations and verify them with distinct channel values
and equal-channel greys. Arbitrary hue adjustment is a separate stretch task
requiring its own numerical contract, resource estimate and reference model.
