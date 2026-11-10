`default_nettype none

module vga #(
    parameter integer REQUEST_LEAD = 16
) (
    input  logic        clk,
    input  logic        rst_n,

    // output to IO; scheduling belongs to this module
    output wire         o_request,
    output wire [9:0]   o_request_x,
    output wire [9:0]   o_request_y,
    output wire         o_request_sof,
    output wire         o_request_eof,

    // input from IPU
    input  logic [23:0] i_colour,
    input  logic        i_valid,
    output wire         o_ready,
    input  logic [9:0]  i_x,
    input  logic [9:0]  i_y,
    input  logic        i_sof,
    input  logic        i_eof,
    input  logic        i_box_valid,
    input  logic [9:0]  i_min_x,
    input  logic [9:0]  i_max_x,
    input  logic [9:0]  i_min_y,
    input  logic [9:0]  i_max_y,
    input  logic        i_error,

    // output to TinyVGA-compatible pins
    output wire [7:0]   o_vga
);
    localparam IMPLEMENTED = 0;
    // TODO(student): own /2 pixel enable, raster counters and advance requests.
    // Keep returned pixels in bounded local staging, matched by coordinates.
    // Draw the box, quantize to RGB222 and align RGB with sync/blanking.
    // Missing pixels produce visible magenta plus sticky error, never a stall.
    // REQUEST_LEAD is a draft budget, not proof of buffering or timing closure.
    assign o_request = 0;
    assign o_request_x = 0;
    assign o_request_y = 0;
    assign o_request_sof = 0;
    assign o_request_eof = 0;
    assign o_ready = 0;
    assign o_vga = 0;
endmodule
