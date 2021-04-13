// fifo_read_logic.v
// Author: Vladislav Rykov

`define DEST_ID	1

module fifo_read_logic #(parameter DEPTH = 3, UWIDTH = 8, PTR_SZ = 2, PTR_IN_SZ = 4)
			(input clk2, rst,
			 input read_port_1_done, read_port_2_done, read_port_3_done,
			 input [(PTR_SZ-1):0] rq2_wptr,
			 input [(UWIDTH-1):0] udata,
			 output reg uread_en,
			 output reg [(PTR_SZ-1):0] uaddr,
			 output reg [(PTR_IN_SZ-1):0] uaddr_in,
			 output reg read_port_1_en, read_port_2_en, read_port_3_en,
			 output reg [(PTR_SZ-1):0] raddr_port_1, raddr_port_2, raddr_port_3,
			 output reg [(PTR_SZ-1):0] rptr
			 output reg [(PTR_SZ-1):0] iaddr, idata,
			 output reg iwrite_en, iread_en
);

  localparam IDLE = 2'b00, BUSY_1 = 2'b01, BUSY_2 = 2'b10, BUSY_3 = 2'b11;
  reg [1:0] current_state, next_state;
  localparam RDST_START = 1'b0, RDST_DONE = 1'b1;
  reg rdst_current_state, rdst_next_state;
  localparam WIDX_START = 1'b0, WIDX_DONE = 1'b1;
  reg widx_current_state, widx_next_state;

  reg rempty = rptr == rq2_wptr;

  reg [2:0] active_ports;
  reg [(PTR_SZ-1):0] ridx;
  reg [(UWIDTH-1):0] dest_id;

  always @(posedge clk2 or negedge rst)
  begin
    if (!rst) current_state <= IDLE;
    else      next_state    <= current_state;
  end

  // sequential output logic
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
      
      active_ports = 0;
      ridx = 0;
      dest_id = 0;
    else
      // routing logic
    end
  end

  always @(current_state or rq2_wptr)
  begin
    // fsm logic
    next_state = current_state;
    // set default output

    // deref idx
    // read dest_id
    // decide port
    // if free set read_port_x_en
          
    // deref idx
    iaddr = rq2_wptr - 1;
    iread_en = 1;
    ridx = idata;
    iread_en = 0;

    // read dest_id
    uaddr = ridx;
    uaddr_in = `DEST_ID;
    dest_id = udata;
         
    case (current_state)
      IDLE: begin
        if (!rempty) // => fifo+1
        begin
          // decide port
          if (dest_id >= 0 && dest_id <= 127)
          begin
            raddr_port_1 = ridx;
            read_port_1_en = 1;
          end
          else if (dest_id >= 128 && dest_id <= 195)
          begin
            raddr_port_2 = ridx;
            read_port_2_en = 1;
          end
          else if (dest_id >= 196 && dest_id <= 255)
          begin
            raddr_port_3 = ridx;
            read_port_3_en = 1;
          end

          next_state = BUSY_1;
          active_ports = active_ports + 1;
          // wait for reading out
        end
      end
      BUSY_1: begin

      end
      BUSY_2: begin

      end
      BUSY_3: begin

      end
    endcase
  end

  always @(read_port_1_done)
  begin
          // read done
          // write next free idx
          // advance ptr
          // fifo-1
    read_port_1_en = 0;
    // write next ref idx to write
    iwrite_en = 1;
    iaddr = rptr;
    idata = raddr_port_1;
    iwrite_en = 0;
    // increment read ptr
    rptr = rptr + 1;
    
    case (current_state)
      BUSY_1: begin
        next_state = IDLE;
      end
      BUSY_2: begin
        next_state = BUSY_1;
      end
      BUSY_3: begin
        next_state = BUSY_2;
      end
    endcase

    active_ports = active_ports - 1;
  end

  // combinational output logic
  always @(*)
  begin

  end
endmodule
