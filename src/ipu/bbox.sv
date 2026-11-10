`default_nettype none

module bbox (

    input  logic          clk,
    input  logic        rst_n,

    // from ipu
    input  logic                i_accept,   // a pixel was transferred this cycle
    input  logic              i_selected,   // that pixel matched the colour range
    input  logic [9:0]               i_x,
    input  logic [9:0]               i_y,
    input  logic                   i_sof,   // first accepted pixel of a frame
    input  logic    i_previous_frame_bad,   // the frame that just ended had reception errors (sampled with sof)

    // configuration
    input  logic [7:0]         i_min_run,   // register 0x7, run-length noise filter. 0 and 1 disable it

    // to vga
    output logic                 o_valid,   // previous frame produced a box
    output logic [9:0]           o_min_x,   // inclusive bounds of the previous frame's box
    output logic [9:0]           o_max_x,
    output logic [9:0]           o_min_y,
    output logic [9:0]           o_max_y
);

    /* finds the box around the selected pixels of each frame.
        a run-length filter ignores stray matches so a few noisy pixels can't stretch the box across the screen.
        the box is published once per frame, when the next frame starts.
        see docs/modules/ipu/bbox.md for the filter and publication rules. */

    // implement the run-length filter
    // implement the current-frame bounds
    // implement publication at accepted sof, including empty and bad frames

    // *: only accepted pixels count. a stalled pixel is still one pixel.


    // *: placeholder tie-offs, replace as you implement
    assign o_valid = 0;
    assign o_min_x = 0;
    assign o_max_x = 0;
    assign o_min_y = 0;
    assign o_max_y = 0;

endmodule
