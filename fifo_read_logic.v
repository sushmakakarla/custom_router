// fifo_read_logic.v
// Author: Vladislav Rykov

// DEPTH     - FIFO size
// PTR_SZ    - FIFO entry index size in bits
module fifo_read_logic #(parameter DEPTH = 3, PTR_SZ = 2)
			(input clk, rst,
			 input rinc,
			 input [(PTR_SZ-1):0] rq2_waddr,
			 output reg rempty, read_en,
			 output reg [(PTR_SZ-1):0] raddr,
			 output reg [(PTR_SZ-1):0] raddr_gray
);
  localparam IDLE = 2'b00, READ = 2'b01, EMPTY = 2'b10;
  reg [1:0] current_state, next_state;
  
  reg rempty_tmp, read_en_tmp;
  reg [(PTR_SZ-1):0] waddr, raddr_tmp;
  assign [(PTR_SZ-1):0] raddr_gray_tmp = (raddr_tmp >> 1) ^ raddr_tmp;

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
    read_en_tmp = 0;

    case (current_state)
      IDLE: begin
        read_en_tmp = 0;
        if (!rempty_tmp) next_state = READ;
        else             next_state = IDLE;
      end
      READ: begin
        read_en_tmp = 1;
        if (rempty_tmp)  next_state = EMPTY;
        else             next_state = READ;
      end
      EMPTY: begin
        read_en_tmp = 0;
        if (!rempty_tmp) next_state = READ;
        else             next_state = EMPTY;
      end
  end

  // sequential block
  always @(posedge clk or negedge rst)
  begin
    if (!rst) begin
      read_en <= 0;
      rempty <= 0;
      raddr <= 0;
      raddr_gray <= 0;
    end else begin
      read_en <= read_en_tmp;
      rempty <= rempty_tmp;
      raddr <= raddr_tmp;
      raddr_gray <= raddr_gray_tmp;
    end
  end

  // combinational blocks
  always @(*)
  begin
    rempty_tmp = raddr_tmp == waddr;
    if (rinc && !rempty_tmp) raddr_tmp = (raddr_tmp + 1) % DEPTH;
  end

  always @(rq2_raddr)
    for (i = 0; i < PTR_SZ; i=i+1)
       waddr[i] = ^(rq2_waddr >> i);

endmodule
