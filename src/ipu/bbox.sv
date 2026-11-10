`default_nettype none

module bbox (
    input  logic       clk,
    input  logic       rst_n,
    // update only on accepted pixels, not on every cycle valid is held
    input  logic       i_accept,
    input  logic       i_selected,
    input  logic [9:0] i_x,
    input  logic [9:0] i_y,
    input  logic       i_sof,
    input  logic       i_previous_frame_bad,
    output wire        o_valid,
    output wire [9:0]  o_min_x,
    output wire [9:0]  o_max_x,
    output wire [9:0]  o_min_y,
    output wire [9:0]  o_max_y
);
    localparam IMPLEMENTED = 0;
    // TODO: maintain current-frame bounds plus an any-hit bit.
    // On accepted SOF, publish the previous frame, then seed this frame with
    // the same accepted pixel. Empty or bad previous frames clear output valid.
    assign o_valid = 0;
    assign o_min_x = 0;
    assign o_max_x = 0;
    assign o_min_y = 0;
    assign o_max_y = 0;
endmodule
