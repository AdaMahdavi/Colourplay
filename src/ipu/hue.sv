`default_nettype none

module hue #(
    parameter integer LATENCY = 4   // clocks from i_start to o_done; choose and document yours
) (
    input  logic        clk,
    input  logic        rst_n,

    // input from IPU: at most one start every 2 clocks, never stalled
    input  logic        i_start,
    input  logic [23:0] i_colour,   // {r, g, b}
    input  logic [4:0]  i_angle,    // 0..23, 15 degree steps

    // output to IPU: exactly LATENCY clocks after the matching i_start
    output wire         o_done,
    output wire [23:0]  o_colour
);
    localparam IMPLEMENTED = 0;

    // Rotation about the grey axis. Coefficients are signed Q2.8 (256 = 1.0):
    //   r' = clamp((a*r + b*g + c*b + 128) >>> 8)
    //   g' = clamp((c*r + a*g + b*b + 128) >>> 8)
    //   b' = clamp((b*r + c*g + a*b + 128) >>> 8)
    // (a, b, c) comes from the 8-row table in docs/modules/ipu/hue.md.
    // Steps 8..15 and 16..23 reuse rows 0..7 rotated as (a,b,c) -> (b,c,a).
    //
    // start with angles 0, 8, 16: RGB, BRG and GBR channel swaps. get these
    //   passing first; the general case must reproduce them exactly.
    // 9 products per pixel and 2 clocks per pixel: decide how many multipliers
    //   to build and how to share them. widen before multiplying, add the
    //   rounding constant, shift arithmetically, clamp last.
    // capture i_colour and i_angle on i_start; the inputs may change afterwards.
    // o_done must pulse once per start, even if two starts are 2 clocks apart.

    assign o_done = 0;
    assign o_colour = 0;
    wire _unused = &{clk, rst_n, i_start, i_colour, i_angle, 1'b0};
endmodule
