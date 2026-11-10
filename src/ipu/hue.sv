`default_nettype none

module hue (
    input  logic [23:0] i_colour,
    input  logic [1:0]  i_rotation,
    output wire [23:0] o_colour
);
    localparam IMPLEMENTED = 0;
    // TODO: 0 = RGB, 1 = GBR, 2 = BRG; 3 is reserved.
    // This baseline offers cyclic channel rotations, not arbitrary hue adjustment.
    assign o_colour = 0;
endmodule
