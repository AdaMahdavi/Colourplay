`default_nettype none

module vga #(

    parameter REQUEST_LEAD  = 8,   // pixel slots between a request and its display position
    parameter STAGING_DEPTH = 4    // early-arrival storage, must cover REQUEST_LEAD minus the minimum latency
)(
    input  logic          clk,
    input  logic        rst_n,

    // to io
    output logic               o_request,   // ask io for one pixel this slot
    output logic [9:0]       o_request_x,   // coordinates of the requested pixel (a future position, not the current one)
    output logic [9:0]       o_request_y,
    output logic           o_request_sof,
    output logic           o_request_eof,

    // from ipu
    input  logic [23:0]         i_colour,   // processed {r, g, b}
    input  logic                 i_valid,
    output logic                 o_ready,
    input  logic [9:0]               i_x,
    input  logic [9:0]               i_y,
    input  logic                   i_sof,
    input  logic                   i_eof,

    // from ipu: bounding box of the previous frame
    input  logic             i_box_valid,
    input  logic [9:0]           i_min_x,
    input  logic [9:0]           i_max_x,
    input  logic [9:0]           i_min_y,
    input  logic [9:0]           i_max_y,

    // status
    input  logic                 i_error,   // sticky io error, shown on screen

    // configuration
    input  logic         i_dither_enable,   // register 0x0 bit 2

    // to the TinyVGA pins
    output logic [7:0]             o_vga    // {HSYNC, B[0], G[0], R[0], VSYNC, B[1], G[1], R[1]}
);

    /* owns all display timing: 640 x 480 at a 25 MHz pixel rate from the 50 MHz clock.
        pixels are requested ahead of time, held until their raster position comes up, then drawn.
        the display never waits: a missing pixel is shown as an error, not a stall.
        see docs/modules/vga/vga.md for raster timing, error display and RGB222 conversion. */

    // implement the pixel enable and raster counters
    // implement request scheduling REQUEST_LEAD slots ahead, including through blanking
    // implement bounded staging for early arrivals
    // implement the box overlay, RGB222 conversion and error display

    // *: no second clock domain. use an enable.
    // * hint: start with a test pattern before you touch requests.


    // *: placeholder tie-offs, replace as you implement
    assign o_request     = 0;
    assign o_request_x   = 0;
    assign o_request_y   = 0;
    assign o_request_sof = 0;
    assign o_request_eof = 0;
    assign o_ready       = 0;
    assign o_vga         = 0;

endmodule
