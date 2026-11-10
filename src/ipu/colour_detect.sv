`default_nettype none

module colour_detect (
    // original pixel and active configuration from IPU
    input  logic [23:0] i_colour,
    input  logic [23:0] i_reference,
    input  logic [7:0]  i_tolerance,
    output wire        o_selected
);
    localparam IMPLEMENTED = 0;
    // TODO: compare absolute channel differences without unsigned wrap.
    // Select only if all three differences are <= tolerance, including equality.
    assign o_selected = 0;
endmodule
