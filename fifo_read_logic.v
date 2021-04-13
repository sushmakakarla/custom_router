// fifo_read_logic.v
// Author: Vladislav Rykov

module fifo_read_logic #(parameter DEPTH = 3, UWIDTH = 8, PTR_SZ = 2, PTR_IN_SZ = 4)
			(input clk2, rst,
			 input read_port_1_done, read_port_2_done, read_port_3_done,
			 input [(PTR_SZ-1):0] rq2_wptr,
			 input [(UWIDTH-1):0] uin,
			 output reg uread_en,
			 output reg [(PTR_SZ-1):0] uaddr,
			 output reg [(PTR_IN_SZ-1):0] uaddr_in,
			 output reg read_port_1_en, read_port_2_en, read_port_3_en,
			 output reg [(PTR_SZ-1):0] raddr_port_1, raddr_port_2, raddr_port_3,
			 output reg rempty,
			 output reg [(PTR_SZ-1):0] rptr
);

  localparam IDLE = 2'b00, BUSY_1 = 2'b01, BUSY_2 = 2'b10, BUSY_3 = 2'b11;
  reg [1:0] current_state, next_state;
  reg [2:0] active_ports;

  always @(posedge clk2 or negedge rst)
  begin
    if (!rst) current_state <= IDLE;
    else      next_state    <= current_state;
  end

  always @(*)
  begin
    rempty = rptr == rq2_wptr;
  end

  always @(posedge clk2 or negedge rst)
  begin
    if (!rst)
    begin
      read_port_1_en <= 0;
      read_port_2_en <= 0;
      read_port_3_en <= 0;
      raddr_port_1 <= 0;
      raddr_port_2 <= 0;
      raddr_port_3 <= 0;
      rptr <= 0;
    else
      // routing logic
    end
  end

  always @(current_state or rq2_rptr or read_port_1_done or read_port_2_done or read_port_3_done)
  begin
    // fsm logic
  end

endmodule
