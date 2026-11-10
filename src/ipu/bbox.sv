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
    // from configuration register 0x7; 0 and 1 both mean "no filtering"
    input  logic [7:0] i_min_run,
    output wire        o_valid,
    output wire [9:0]  o_min_x,
    output wire [9:0]  o_max_x,
    output wire [9:0]  o_min_y,
    output wire [9:0]  o_max_y
);
    localparam IMPLEMENTED = 0;
    // TODO: maintain current-frame bounds plus an any-hit bit.
    // noise filter: count consecutive selected pixels on the current row
    //   (restart at x == 0). a pixel only counts toward the box once the run
    //   reaches i_min_run; when it first does, the run's first pixel
    //   (x - i_min_run + 1) becomes a min_x candidate. no line buffer needed.
    // On accepted SOF, publish the previous frame, then seed this frame with
    // the same accepted pixel. Empty or bad previous frames clear output valid.
    assign o_valid = 0;
    assign o_min_x = 0;
    assign o_max_x = 0;
    assign o_min_y = 0;
    assign o_max_y = 0;
endmodule
