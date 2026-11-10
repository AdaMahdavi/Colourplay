`default_nettype none
// this module is purely combinational.

module colour_detect (

    // from ipu
    input  logic [23:0]     i_colour,   // original {r, g, b} pixel, before any effect
    input  logic [23:0]  i_reference,   // configured reference colour
    input  logic [7:0]   i_tolerance,   // inclusive per-channel difference limit

    // to ipu
    output logic          o_selected    // pixel is within tolerance on every channel
);

    // decides whether a pixel belongs to the object we are recolouring. see docs/modules/ipu/colour_detect.md

    // implement the per-channel comparison
    // * hint: unsigned subtraction wraps around.


    // *: placeholder tie-offs, replace as you implement
    assign o_selected = 0;

endmodule
