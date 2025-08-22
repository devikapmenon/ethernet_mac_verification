// Simple MAC TX: accepts a pre-FCS frame stream (Dest+Src+Type+Payload)
// Adds padding to ensure total pre-FCS length >= 60 bytes (14 header + >=46 payload)
// Appends 4 CRC bytes (LSB-first). No preamble/SFD modeled.

`include "crc32_eth.svh"

module mac_tx (
    input logic clk,
    input logic rst_n,

    // Input stream (header + payload, no FCS)
    input  logic       in_valid,
    output logic       in_ready,
    input  logic [7:0] in_data,
    input  logic       in_last,   // marks last byte of input frame (before FCS)

    // Output stream (complete frame: header+payload+pad+FCS)
    output logic       out_valid,
    input  logic       out_ready,
    output logic [7:0] out_data,
    output logic       out_last,
    output logic       out_is_crc  // high when outputting FCS bytes (for error injection in TB)
);

  typedef enum logic [2:0] {
    S_IDLE,
    S_STREAM,
    S_PAD,
    S_CRC0,
    S_CRC1,
    S_CRC2,
    S_CRC3
  } state_e;
  state_e state, nxt;

  logic [31:0] crc;
  logic [15:0] count;  // pre-FCS byte count (header+payload+pad)
  logic [31:0] fcs;  // ~crc at end of pre-FCS bytes

  // combinational defaults
  always_comb begin
    in_ready   = 1'b0;
    out_valid  = 1'b0;
    out_last   = 1'b0;
    out_is_crc = 1'b0;
    out_data   = 8'h00;
    nxt        = state;

    unique case (state)
      S_IDLE: begin
        // Wait for first input byte to start a frame
        in_ready = out_ready;  // accept only if we can forward
        if (in_valid && out_ready) begin
          out_valid = 1'b1;
          out_data  = in_data;
          nxt       = S_STREAM;
        end
      end

      S_STREAM: begin
        // Forward bytes; update CRC and count in sequential always_ff
        in_ready  = out_ready;
        out_valid = in_valid & out_ready;
        out_data  = in_data;
        if (in_valid && out_ready && in_last) begin
          // Decide whether to pad next
          if (count + 16'd1 < 16'd60) nxt = S_PAD;  // still need to reach 60 pre-FCS bytes
          else nxt = S_CRC0;
        end
      end

      S_PAD: begin
        // Emit zero padding until count reaches 60
        out_valid = 1'b1;
        out_data  = 8'h00;
        if (out_ready && (count == 16'd59)) nxt = S_CRC0;  // after writing 60th byte
      end
      S_CRC0: begin
        out_valid  = 1'b1;
        out_data   = fcs[7:0];
        out_is_crc = 1'b1;
        if (out_ready) nxt = S_CRC1;
      end
      S_CRC1: begin
        out_valid  = 1'b1;
        out_data   = fcs[15:8];
        out_is_crc = 1'b1;
        if (out_ready) nxt = S_CRC2;
      end
      S_CRC2: begin
        out_valid  = 1'b1;
        out_data   = fcs[23:16];
        out_is_crc = 1'b1;
        if (out_ready) nxt = S_CRC3;
      end
      S_CRC3: begin
        out_valid  = 1'b1;
        out_data   = fcs[31:24];
        out_is_crc = 1'b1;
        out_last   = out_ready;
        if (out_ready) nxt = S_IDLE;
      end

      default: nxt = S_IDLE;
    endcase
  end
  // sequential: counters and CRC
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state <= S_IDLE;
      crc   <= crc32_eth_init();
      count <= 16'd0;
      fcs   <= '0;
    end else begin
      state <= nxt;

      // Reset per frame start
      if (state == S_IDLE && nxt == S_STREAM) begin
        crc   <= crc32_eth_update(crc32_eth_init(), in_data);
        count <= 16'd1;
      end else begin
        // STREAM updates
        if (state == S_STREAM && in_valid && out_ready) begin
          crc   <= crc32_eth_update(crc, in_data);
          count <= count + 16'd1;
          if (in_last) begin
            // compute final crc now or after padding
            if (count + 16'd1 >= 16'd60) begin
              fcs <= crc32_eth_final(crc32_eth_update(crc, in_data));
            end
          end
        end
        // PAD updates
        if (state == S_PAD && out_ready) begin
          crc   <= crc32_eth_update(crc, 8'h00);
          count <= count + 16'd1;
          if (count == 16'd59) begin
            fcs <= crc32_eth_final(crc32_eth_update(crc, 8'h00));
          end
        end
        // On finishing CRC3, clear
        if (state == S_CRC3 && out_ready) begin
          crc   <= crc32_eth_init();
          count <= 16'd0;
          fcs   <= '0;
        end
      end
    end
  end
endmodule
