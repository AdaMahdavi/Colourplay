`default_nettype none
// this module is purely combinational.

module contrast (

    // from hue (or the original pixel when hue is bypassed)
    input  logic [23:0]  i_colour,   // {r, g, b}
    input  logic [7:0]     i_gain,   // unsigned Q4.4, 8'h10 is unity

    // to ipu
    output logic [23:0]  o_colour    // {r, g, b}, saturated
);

    // stretches or squeezes each channel around mid-grey. see docs/modules/ipu/contrast.md

    // implement the per-channel gain and saturation
    // * hint: decide your signed widths before you write the multiply.


    // *: placeholder tie-offs, replace as you implement
    assign o_colour = 0;

endmodule
