`default_nettype none

module io (
    input  logic         clk,
    input  logic         rst_n,

    // input from the prepared-image harness
    input  logic [11:0]  i_data,
    input  logic         i_valid,
    input  logic         i_sof,
    input  logic         i_config,

    // input from VGA: request coordinates are attached to the assembled pixel
    input  logic         i_request,
    input  logic [9:0]   i_request_x,
    input  logic [9:0]   i_request_y,
    input  logic         i_request_sof,
    input  logic         i_request_eof,

    // output to IPU
    output wire [23:0]   o_colour,
    output wire          o_valid,
    input  logic         i_ready,
    output wire [9:0]    o_x,
    output wire [9:0]    o_y,
    output wire          o_sof,
    output wire          o_eof,
    output wire          o_previous_frame_bad,
    output wire [127:0]  o_configuration,
    output wire          o_error
);
    localparam IMPLEMENTED = 0;

    // TODO: assemble two 12-bit beats and attach saved request metadata.
    // Keep an unfinished pixel separate from the completed-pixel holding register.
    // Hold output data stable until valid && ready. Detect missed source deadlines.
    // Decode shadow configuration writes; commit only before a new frame enters IPU.
    // At assembled SOF, attach the old frame's error history before clearing it.
    // Separately keep o_error sticky until reset, including configuration errors.
    assign o_colour = 0;
    assign o_valid = 0;
    assign o_x = 0;
    assign o_y = 0;
    assign o_sof = 0;
    assign o_eof = 0;
    assign o_previous_frame_bad = 1;
    assign o_configuration = 0;
    assign o_error = 1;
endmodule
