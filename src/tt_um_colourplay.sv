`default_nettype none

module tt_um_colourplay (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);
    localparam IMPLEMENTED = 0;
    wire request, pixel_valid, pixel_ready, pixel_sof, pixel_eof;
    wire [23:0] pixel_colour, filtered_colour;
    wire [9:0] pixel_x, pixel_y, request_x, request_y;
    wire request_sof, request_eof;
    wire [127:0] configuration;
    wire filtered_valid, filtered_ready, filtered_sof, filtered_eof;
    wire [9:0] filtered_x, filtered_y;
    wire box_valid;
    wire [9:0] box_min_x, box_max_x, box_min_y, box_max_y;
    wire io_error;
    wire previous_frame_bad;

    io u_io (
        .clk(clk), .rst_n(rst_n), .i_data({uio_in[3:0], ui_in}),
        .i_valid(uio_in[4]), .i_sof(uio_in[5]), .i_config(uio_in[6]),
        .i_request(request), .i_request_x(request_x), .i_request_y(request_y),
        .i_request_sof(request_sof), .i_request_eof(request_eof),
        .o_colour(pixel_colour), .o_valid(pixel_valid), .i_ready(pixel_ready),
        .o_x(pixel_x), .o_y(pixel_y), .o_sof(pixel_sof), .o_eof(pixel_eof),
        .o_configuration(configuration), .o_error(io_error),
        .o_previous_frame_bad(previous_frame_bad)
    );

    ipu u_ipu (
        .clk(clk), .rst_n(rst_n), .i_configuration(configuration),
        .i_colour(pixel_colour), .i_valid(pixel_valid), .o_ready(pixel_ready),
        .i_x(pixel_x), .i_y(pixel_y), .i_sof(pixel_sof), .i_eof(pixel_eof),
        .i_previous_frame_bad(previous_frame_bad),
        .o_colour(filtered_colour), .o_valid(filtered_valid), .i_ready(filtered_ready),
        .o_x(filtered_x), .o_y(filtered_y), .o_sof(filtered_sof), .o_eof(filtered_eof),
        .o_box_valid(box_valid), .o_min_x(box_min_x), .o_max_x(box_max_x),
        .o_min_y(box_min_y), .o_max_y(box_max_y)
    );

    vga u_vga (
        .clk(clk), .rst_n(rst_n),
        .o_request(request), .o_request_x(request_x), .o_request_y(request_y),
        .o_request_sof(request_sof), .o_request_eof(request_eof),
        .i_colour(filtered_colour), .i_valid(filtered_valid), .o_ready(filtered_ready),
        .i_x(filtered_x), .i_y(filtered_y), .i_sof(filtered_sof), .i_eof(filtered_eof),
        .i_box_valid(box_valid), .i_min_x(box_min_x), .i_max_x(box_max_x),
        .i_min_y(box_min_y), .i_max_y(box_max_y), .i_error(io_error),
        .o_vga(uo_out)
    );

    assign uio_out = {request, 7'b0};
    assign uio_oe = 8'b1000_0000;
    wire _unused = &{ena, 1'b0};
endmodule
