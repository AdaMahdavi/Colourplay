`default_nettype none

module ipu (
    input  logic         clk,
    input  logic         rst_n,
    input  logic [127:0] i_configuration,

    // input from IO
    input  logic [23:0]  i_colour,
    input  logic         i_valid,
    output wire          o_ready,
    input  logic [9:0]   i_x,
    input  logic [9:0]   i_y,
    input  logic         i_sof,
    input  logic         i_eof,
    input  logic         i_previous_frame_bad,

    // output to VGA
    output wire [23:0]   o_colour,
    output wire          o_valid,
    input  logic         i_ready,
    output wire [9:0]    o_x,
    output wire [9:0]    o_y,
    output wire          o_sof,
    output wire          o_eof,
    output wire          o_box_valid,
    output wire [9:0]    o_min_x,
    output wire [9:0]    o_max_x,
    output wire [9:0]    o_min_y,
    output wire [9:0]    o_max_y
);
    localparam IMPLEMENTED = 0;
    wire selected;
    wire [23:0] hue_colour, contrast_colour;
    wire hue_done;

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

    // TODO: hue is a fixed-latency unit that cannot stall. only start it when
    //   the result is guaranteed somewhere to go; carry selected, x, y, sof, eof
    //   alongside it for hue.LATENCY clocks so they rejoin the right pixel.
    // apply hue/contrast only to selected pixels with the effect enabled;
    //   unselected pixels leave with their original colour.
    // every enable/selection combination must have the same total latency.
    // propagate ready/valid backpressure; a stall must not duplicate or drop pixels.
    assign o_ready = 0;
    assign o_colour = 0;
    assign o_valid = 0;
    assign o_x = 0;
    assign o_y = 0;
    assign o_sof = 0;
    assign o_eof = 0;
endmodule
