// packet_sender.v
// Author: Vladislav Rykov

`define SRC_ID 0
`define DST_ID 1
`define SIZE   2
`define DATA   3

`define SIZE_MASK 111
`define SIZE_BITS 3

module packet_sender #(UWIDTH = 8, PTR_IN_SZ = 4)
                      (input clk, rst,
                       input rempty,
                       output rinc, packet_valid,
                       output [(PTR_IN_SZ-1):0] raddr_in,
                       output [(UWIDTH-1):0] packet_out
);
  localparam IDLE = 3'd0, SRC = 3'd1, DST = 3'd2, SIZE = 3'd3, DATA = 3'd4, CRC = 3'd5;
  reg [2:0] current_state, next_state;

  reg [(PTR_IN_SZ-1):0] pidx;
  reg [(`SIZE_BITS-1):0] dsz;

  always @(posedge clk or negedge rst)
  begin
    if (!rst) current_state <= IDLE;
    else      current_state <= next_state;
  end

  // fsm combinational block
  always @(current_state or rempty)
  begin
    
  end


endmodule
