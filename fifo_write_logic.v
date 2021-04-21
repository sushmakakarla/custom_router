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
  
  reg wfull_tmp, write_en_tmp;
  reg [(PTR_SZ-1):0] raddr, waddr_tmp;
  assign [(PTR_SZ-1):0] waddr_gray_tmp = (waddr_tmp >> 1) ^ waddr_tmp;

  // FSM sequential block
  always @(posedge clk or negedge rst)
  begin
    if (!rst) current_state <= IDLE;
    else      current_state <= next_state;
  end

  // FSM combinational block
  always @(current_state or wfull_tmp)
  begin
    next_state = current_state;
    write_en_tmp = 0;

    case (current_state)
      IDLE: begin
        write_en_tmp = 0;
        if (!wfull_tmp) next_state = WRITE;
        else        next_state = IDLE;
      end
      WRITE: begin
        write_en_tmp = 1;
        if (wfull_tmp)  next_state = FULL;
        else        next_state = WRITE;
      end
      FULL: begin
        write_en = 0;
        if (!wfull_tmp) next_state = WRITE;
        else        next_state = FULL;
      end
  end

  // sequential block
  always @(posedge clk or negedge rst)
  begin
    if (!rst) begin
      write_en <= 0;
      wfull <= 0;
      waddr <= 0;
      waddr_gray <= 0;
    end else begin
      write_en <= write_en_tmp;
      wfull <= wfull_tmp;
      waddr <= waddr_tmp;
      waddr_gray <= waddr_gray_tmp;
    end
  end

  // combinational blocks
  always @(*)
  begin
    wfull_tmp = ((waddr_tmp + 1) % DEPTH) == raddr;
    if (winc && !wfull_tmp) waddr_tmp = (waddr_tmp + 1) % DEPTH;
  end

  always @(rq2_raddr)
    for (i = 0; i < PTR_SZ; i=i+1)
       raddr[i] = ^(rq2_raddr >> i);

endmodule
