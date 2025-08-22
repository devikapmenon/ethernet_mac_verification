`timescale 1ns / 1ps

module tb_top;
    logic clk;
    logic rst_n;

    // DUT instantiation
    ethernet_mac dut (
        .clk(clk),
        .rst_n(rst_n)
        // connect other signals here as needed
    );

endmodule

