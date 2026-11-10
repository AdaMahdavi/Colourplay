`default_nettype none

module contrast (
    input  logic [23:0] i_colour,
    input  logic [7:0]  i_gain,
    output wire [23:0] o_colour
);
    localparam IMPLEMENTED = 0;
    // TODO: per channel, clamp(128 + (((c - 128) * gain) >>> 4)).
    // gain is unsigned Q4.4. Widen signed operands before multiplying and clamp
    // before converting to eight bits. 8'h10 is the identity gain.
    assign o_colour = 0;
endmodule
