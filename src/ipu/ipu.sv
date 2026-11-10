`default_nettype none

module ipu (

    input  logic          clk,
    input  logic        rst_n,

    // configuration
    input  logic [63:0]  i_configuration,   // active register copy from io

    // from io
    input  logic [23:0]         i_colour,   // original {r, g, b}
    input  logic                 i_valid,
    output logic                 o_ready,
    input  logic [9:0]               i_x,
    input  logic [9:0]               i_y,
    input  logic                   i_sof,
    input  logic                   i_eof,
    input  logic    i_previous_frame_bad,   // sampled with i_sof, passed to bbox

    // to vga
    output logic [23:0]         o_colour,   // processed {r, g, b}
    output logic                 o_valid,
    input  logic                 i_ready,
    output logic [9:0]               o_x,
    output logic [9:0]               o_y,
    output logic                   o_sof,
    output logic                   o_eof,

    // to vga: bounding box of the previous frame
    output logic             o_box_valid,
    output logic [9:0]           o_min_x,
    output logic [9:0]           o_max_x,
    output logic [9:0]           o_min_y,
    output logic [9:0]           o_max_y
);

    /* joins the colour units into one stream. selection always looks at the original pixel;
        only selected pixels go through the enabled effects, everything else leaves with its original colour.
        every accepted pixel must come out exactly once, with its own coordinates and frame markers.
        see docs/modules/ipu/ipu.md */

    logic        selected;
    logic [23:0] hue_colour, contrast_colour;
    logic        hue_done;

    colour_detect u_colour_detect (
        .i_colour(i_colour), .i_reference(i_configuration[31:8]),
        .i_tolerance(i_configuration[39:32]), .o_selected(selected)
    );
    hue u_hue (
        .clk(clk), .rst_n(rst_n), .i_start(i_valid && o_ready),
        .i_colour(i_colour), .i_angle(i_configuration[52:48]),
        .o_done(hue_done), .o_colour(hue_colour)
    );
    contrast u_contrast (
        .i_colour(hue_colour), .i_gain(i_configuration[47:40]), .o_colour(contrast_colour)
    );
    bbox u_bbox (
        .clk(clk), .rst_n(rst_n), .i_accept(i_valid && o_ready),
        .i_selected(selected), .i_x(i_x), .i_y(i_y), .i_sof(i_sof),
        .i_previous_frame_bad(i_previous_frame_bad),
        .i_min_run(i_configuration[63:56]),
        .o_valid(o_box_valid), .o_min_x(o_min_x), .o_max_x(o_max_x),
        .o_min_y(o_min_y), .o_max_y(o_max_y)
    );

    // implement the elastic stages around the fixed-latency hue unit
    // implement carrying selection and metadata alongside each pixel
    // implement the per-pixel bypass for unselected pixels and disabled effects

    // *: hue cannot stall. latency must be the same in every mode.


    // *: placeholder tie-offs, replace as you implement
    assign o_ready  = 0;
    assign o_colour = 0;
    assign o_valid  = 0;
    assign o_x      = 0;
    assign o_y      = 0;
    assign o_sof    = 0;
    assign o_eof    = 0;

endmodule
