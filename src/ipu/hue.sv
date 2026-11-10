`default_nettype none

module hue #(

    parameter LATENCY = 4   // clocks from i_start to o_done. choose yours and report it to ipu
)(
    input  logic          clk,
    input  logic        rst_n,

    // from ipu
    input  logic             i_start,   // capture i_colour and i_angle. at most once every 2 clocks, never stalled
    input  logic [23:0]     i_colour,   // {r, g, b}
    input  logic [4:0]       i_angle,   // step 0-23, 15 degrees per step

    // to ipu
    output logic              o_done,   // one-cycle pulse exactly LATENCY clocks after its i_start
    output logic [23:0]     o_colour    // rotated {r, g, b}, valid with o_done
);

    /* rotates a pixel's colour around the grey axis of the RGB cube.
        greys come out unchanged; every other colour turns by the selected angle.
        this unit has a fixed latency and cannot stall, so ipu only starts it when the result has somewhere to go.
        see docs/modules/ipu/hue.md for the coefficients and number formats. */

    // implement the coefficient lookup for the selected step
    // implement the products, rounding and saturation, bit-exact with test/colourplay_model.py
    // implement the pipeline that meets one start every 2 clocks

    // *: get steps 0, 8 and 16 right first.
    // * hint: the direct form needs nine products. you need fewer.


    // *: placeholder tie-offs, replace as you implement
    assign o_done   = 0;
    assign o_colour = 0;
    wire _unused = &{clk, rst_n, i_start, i_colour, i_angle, 1'b0};

endmodule
