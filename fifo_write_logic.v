// fifo_write_logic.v
// Author: Vladislav Rykov

// DEPTH     - FIFO size
// UWIDTH    - FIFO entry unit width in bits
// PTR_SZ    - FIFO entry index size in bits
module fifo_write_logic #(parameter DEPTH = 3, UWIDTH = 8, PTR_SZ = 2)
			(input clk, rst,
			 input winc,
			 input [(PTR_SZ-1):0] rq2_raddr,
			 output reg wfull, write_en,
			 output reg [(PTR_SZ-1):0] waddr,
			 output reg [(PTR_SZ-1):0] waddr_gray
);
  localparam IDLE = 2'b00, WRITE = 2'b01, FULL = 2'b10;
  reg [1:0] current_state, next_state;
  
  reg [(PTR_SZ-1):0] raddr;
  assign waddr_gray = (waddr >> 1) ^ waddr;

  always @(posedge clk or negedge rst)
  begin
    if (!rst) current_state <= IDLE;
    else      current_state <= next_state;
  end

  always @(*) 
  begin
    next_state = current_state;
    
    case (current_state)
      IDLE: begin
        if (!wfull) next_state = WRITE;
        else        next_state = IDLE;
      end
      WRITE: begin
        
      end
      FULL: begin
 
      end
  end



  always @(rq2_raddr)
    for (i = 0; i < PTR_SZ; i=i+1)
       raddr[i] = ^(rq2_raddr >> i);

endmodule
