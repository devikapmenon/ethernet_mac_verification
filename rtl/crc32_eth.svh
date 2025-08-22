// Ethernet CRC-32 (IEEE 802.3) helper for LSB-first byte streaming
// Polynomial: 0x04C11DB7 (reflected form 0xEDB88320)
// Init = 0xFFFF_FFFF, Final XOR = 0xFFFF_FFFF, transmit least-significant byte first

`ifndef CRC32_ETH_SVH
`define CRC32_ETH_SVH
function automatic logic [31:0] crc32_eth_update(input logic [31:0] crc_in,
                                                 input logic [7:0] data_byte);
  logic [31:0] crc;
  crc = crc_in ^ {24'h0, data_byte};
  // Process 8 LSB-first bit steps using reflected poly 0xEDB88320
  for (int i = 0; i < 8; i++) begin
    if (crc[0]) crc = (crc >> 1) ^ 32'hEDB8_8320;
    else crc = (crc >> 1);
  end
  return crc;
endfunction


function automatic logic [31:0] crc32_eth_init();
  return 32'hFFFF_FFFF;
endfunction


function automatic logic [31:0] crc32_eth_final(input logic [31:0] crc);
  return ~crc;  // final XOR
endfunction
