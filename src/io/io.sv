`default_nettype none

module io (

    input  logic          clk,
    input  logic        rst_n,

    // from the prepared-image source
    input  logic [11:0]           i_data,   // one beat: half of an RGB888 pixel, or a configuration word
    input  logic                 i_valid,   // pixel beat present this cycle
    input  logic                   i_sof,   // first beat of pixel (0,0)
    input  logic                i_config,   // configuration word present this cycle

    // from vga
    input  logic               i_request,   // vga asked for a pixel this slot
    input  logic [9:0]       i_request_x,   // coordinates of the requested pixel
    input  logic [9:0]       i_request_y,
    input  logic           i_request_sof,   // requested pixel is the first of the frame
    input  logic           i_request_eof,   // requested pixel is the last of the frame

    // to ipu
    output logic [23:0]         o_colour,   // assembled {r, g, b}
    output logic                 o_valid,
    input  logic                 i_ready,
    output logic [9:0]               o_x,   // coordinates saved from the matching request
    output logic [9:0]               o_y,
    output logic                   o_sof,
    output logic                   o_eof,
    output logic    o_previous_frame_bad,   // the frame that just ended had reception errors (sampled with sof)

    // configuration
    output logic [63:0]  o_configuration,   // active register copy, see docs/encoding/configuration.md

    // status
    output logic                 o_error    // sticky until reset
);

    /* this module is the chip's only contact with the outside world. vga asks for pixels ahead of time;
        the source answers each request a fixed number of clocks later with two 12-bit beats, which
        are rebuilt into one RGB888 pixel tagged with the request's coordinates.
        the same pins carry configuration writes during vertical blanking.
        the source cannot be stalled: a missed deadline is an error, never a wait.
        see docs/encoding/input.md for the pin protocol and timing. */

    // implement beat assembly and the completed-pixel holding register
    // implement the request metadata delay (requests overlap: keep them in order)
    // implement the configuration registers (shadow and active copies, meaningful bits only)
    // implement protocol error detection, lock, and previous_frame_bad

    // *: an unfinished pixel and a completed one are different registers.


    // *: placeholder tie-offs, replace as you implement
    assign o_colour             = 0;
    assign o_valid              = 0;
    assign o_x                  = 0;
    assign o_y                  = 0;
    assign o_sof                = 0;
    assign o_eof                = 0;
    assign o_previous_frame_bad = 1;
    assign o_configuration      = 0;
    assign o_error              = 1;

endmodule
