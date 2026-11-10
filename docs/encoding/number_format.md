# Number Formats

| Value | Format | Meaning |
|---|---|---|
| Pixel colour | RGB888, `{r, g, b}` | Three unsigned 8-bit channels |
| Display colour | RGB222 | Top two bits of each processed channel |
| Pixel coordinate | Unsigned 10-bit x and y | Active image: x 0-639, y 0-479 |
| Contrast gain | Unsigned Q4.4 | `0x10` is unity; range 0 to 15.9375 |
| Colour tolerance | Unsigned 8-bit | Inclusive maximum difference per channel |
| Hue angle | Unsigned 5-bit step | 0-23, degrees = 15 x step |
| Hue coefficient | Signed Q2.8, 10-bit | `256` is 1.0; table values -86 to 256 |
| Box minimum run | Unsigned 8-bit | Selected pixels in a row before they count |

Coordinates and frame markers travel as sideband alongside the RGB888 colour.

Arithmetic uses widened signed intermediate values. Do not truncate before
saturation. The baseline uses no gamma conversion, dithering or alpha channel.
