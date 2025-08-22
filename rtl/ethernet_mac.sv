`include "crc32_eth.svh"

module ethernet_mac (
    input  logic        clk,
    input  logic        rst_n,

    // TX interface
    input  logic        tx_in_valid,
    output logic        tx_in_ready,
    input  logic [7:0]  tx_in_data,
    input  logic        tx_in_last,

    output logic        tx_out_valid,
    input  logic        tx_out_ready,
    output logic [7:0]  tx_out_data,
    output logic        tx_out_last,
    output logic        tx_out_is_crc,

    // RX interface
    input  logic        rx_in_valid,
    output logic        rx_in_ready,
    input  logic [7:0]  rx_in_data,
    input  logic        rx_in_last,

    output logic        rx_frame_good,
    output logic        rx_frame_bad_crc,
    output logic        rx_frame_bad_len,
    output logic [15:0] rx_frame_len_total
);

    // TX instance
    mac_tx u_mac_tx (
        .clk      (clk),
        .rst_n    (rst_n),
        .in_valid (tx_in_valid),
        .in_ready (tx_in_ready),
        .in_data  (tx_in_data),
        .in_last  (tx_in_last),

        .out_valid(tx_out_valid),
        .out_ready(tx_out_ready),
        .out_data (tx_out_data),
        .out_last (tx_out_last),
        .out_is_crc(tx_out_is_crc)
    );

    // RX instance
    mac_rx u_mac_rx (
        .clk        (clk),
        .rst_n      (rst_n),
        .in_valid   (rx_in_valid),
        .in_ready   (rx_in_ready),
        .in_data    (rx_in_data),
        .in_last    (rx_in_last),

        .frame_good     (rx_frame_good),
        .frame_bad_crc  (rx_frame_bad_crc),
        .frame_bad_len  (rx_frame_bad_len),
        .frame_len_total(rx_frame_len_total)
    );

endmodule
