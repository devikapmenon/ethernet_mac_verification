// Simple MAC RX: accepts full frame bytes (header+payload+pad+FCS)
// Checks CRC and frame length (min 64, max 1518). Outputs result pulses.


`include "crc32_eth.svh"


module mac_rx (
    input logic clk,
    input logic rst_n,


    input logic in_valid,
    output logic in_ready,
    input logic [7:0] in_data,
    input logic in_last,


    output logic frame_good,
    output logic frame_bad_crc,
    output logic frame_bad_len,
    output logic [15:0] frame_len_total
);
  // Always ready in this simple model
  assign in_ready = 1'b1;


  // Keep last 4 bytes for FCS, and compute CRC over all but last 4 bytes
  logic [7:0] last0, last1, last2, last3;  // last0 = most recent
  logic [31:0] crc;
  logic [15:0] count;

  // Add these at the top of your module declarations
  logic [31:0] fcs_recv;
  logic [31:0] fcs_calc;
  logic bad_len;


  // A byte is eligible for CRC update if we have already buffered 4 bytes
  function automatic logic use_for_crc(input int c);
    return (c > 4);  // after 4 bytes, the oldest byte goes to CRC
  endfunction
  // Shift and CRC update
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      last0 <= 8'h00;
      last1 <= 8'h00;
      last2 <= 8'h00;
      last3 <= 8'h00;
      crc <= crc32_eth_init();
      count <= 16'd0;
      frame_good <= 1'b0;
      frame_bad_crc <= 1'b0;
      frame_bad_len <= 1'b0;
      frame_len_total <= 16'd0;
      fcs_recv <= 32'd0;
      fcs_calc <= 32'd0;
      bad_len  <= 1'b0;
    end else begin
      frame_good <= 1'b0;  // pulses
      frame_bad_crc <= 1'b0;
      frame_bad_len <= 1'b0;


      if (in_valid && in_ready) begin
        count <= count + 16'd1;


        // shift in new byte
        last3 <= last2;
        last2 <= last1;
        last1 <= last0;
        last0 <= in_data;


        // After first 4 bytes have been received, update CRC with the oldest byte (last3 before shift)
        if (use_for_crc(count)) begin
          crc <= crc32_eth_update(crc, last3);
        end


        if (in_last) begin
          // Now the 4 most recent bytes are the FCS bytes (LSB-first on the wire)
          fcs_recv <= {last0, last1, last2, last3};
          // finalize CRC (we have updated through all but last 4 bytes)
          fcs_calc <= crc32_eth_final(crc);

          frame_len_total <= count;  // includes FCS

          // Length checks per IEEE 802.3
          bad_len <= (count < 16'd64) || (count > 16'd1518);
          if (bad_len) frame_bad_len <= 1'b1;

          if (fcs_calc == fcs_recv && !bad_len) frame_good <= 1'b1;
          else if (fcs_calc != fcs_recv) frame_bad_crc <= 1'b1;

          // reset for next frame
          last0 <= 8'h00;
          last1 <= 8'h00;
          last2 <= 8'h00;
          last3 <= 8'h00;
          crc   <= crc32_eth_init();
          count <= 16'd0;
        end
      end
    end
  end
endmodule
