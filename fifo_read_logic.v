// fifo_read_logic.v
// Author: Vladislav Rykov

`define DEST_ID	1 //< DestID byte index

module fifo_read_logic #(parameter DEPTH = 3, UWIDTH = 8, PTR_SZ = 2, PTR_IN_SZ = 4)
			(input clk, rst,
			 input read_port_1_done, read_port_2_done, read_port_3_done,
			 input [(PTR_SZ-1):0] rq2_wptr,
			 input [(UWIDTH-1):0] udata,
			 output reg uread_en,
			 output reg [(PTR_SZ-1):0] uaddr,
			 output reg [(PTR_IN_SZ-1):0] uaddr_in,
			 output reg read_port_1_en, read_port_2_en, read_port_3_en,
			 output reg [(PTR_SZ-1):0] raddr_port_1, raddr_port_2, raddr_port_3,
			 output reg [(PTR_SZ-1):0] rptr_gray,
			 output reg [(PTR_SZ-1):0] iaddr, idata,
			 output reg iwrite_en, iread_en
);

  // Read logic and routing states
  localparam IDLE = 2'b00, READ_NEXT_IDX = 2'b01, READ_DST_ID = 2'b10, DISPATCH = 2'b11;
  reg [1:0] current_state, next_state;
    
  // Port x states
  localparam PIDLE = 2'b00, PBUSY = 2'b01, PDONE = 2'b10;
  reg [1:0] port_1_current_state, port_1_next_state;
  reg [(PTR_SZ-1):0] port_1_queue [(PTR_SZ-1):0];
  reg [(PTR_SZ-1):0] port_1_ridx, port_1_widx;
  wire port_1_empty = port_1_widx == port_1_ridx;  

  reg [1:0] port_2_current_state, port_2_next_state;
  reg [(PTR_SZ-1):0] port_2_queue [(PTR_SZ-1):0];
  reg [(PTR_SZ-1):0] port_2_ridx, port_2_widx;
  wire port_2_empty = port_2_widx == port_2_ridx;  

  reg [1:0] port_3_current_state, port_3_next_state;
  reg [(PTR_SZ-1):0] port_3_queue [(PTR_SZ-1):0];
  reg [(PTR_SZ-1):0] port_3_ridx, port_3_widx;
  wire port_3_empty = port_3_widx == port_3_ridx;  

  reg [(PTR_SZ-1):0] rptr;
  reg [(PTR_SZ-1):0] vrptr;
  wire vrempty = vrptr == rq2_wptr;
  wire rempty = rptr == rq2_wptr;

  reg [(PTR_SZ-1):0] ridx;
  reg [(UWIDTH-1):0] dest_id;
  reg [2:0] out_port;

  assign ptr_gray = rptr;
  //assign ptr_gray = (rptr >> 1) ^ rptr;
  //assign rq2_wptr[] 

  always @(posedge clk or negedge rst)
  begin
    if (!rst) current_state <= IDLE;
    else      current_state <= next_state;
  end

  // sequential output
  always @(posedge clk or negedge rst)
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
      vrptr <= 0;

      uaddr <= 0;
      uaddr_in <= 0;
      uread_en <= 0;

      iaddr <= 0;
      idata <= 0;
      iwrite_en <= 0;
      iread_en <= 0;

      port_1_ridx <= 0;
      port_1_widx <= 0;
      port_2_ridx <= 0;
      port_2_widx <= 0;
      port_3_ridx <= 0;
      port_3_widx <= 0;

      ridx <= 0;
      dest_id <= 0;
      out_port <= 0;
    //else
      
    end
  end

  // on any change in current state or write pointer
  always @(current_state or rq2_wptr)
  begin
    next_state = current_state;

    case (current_state)
      IDLE: begin
        if (!vrempty) begin
          // read right index from fifo_idx_map
          iaddr = rptr;
          iread_en = 1;
          vrptr = (vrptr + 1) % DEPTH;
          next_state = READ_NEXT_IDX;
        end else
          next_state = IDLE;
      end
      READ_NEXT_IDX: begin
        iread_en = 0;
        uaddr = idata;
        uaddr_in = `DEST_ID;
        uread_en = 1;
        
        ridx = idata;
        next_state = READ_DST_ID;
      end
      READ_DST_ID: begin
        // read dest_id
        uread_en = 0;
        dest_id = udata;
        next_state = DISPATCH;
      end
      DISPATCH: begin
        out_port = dest_id >= 0 && dest_id <= 127? 0 : dest_id >= 128 && dest_id <= 195? 1 : 2;
          
        case (out_port)
          0: begin
            port_1_queue[port_1_widx] = ridx;
            port_1_widx <= (port_1_widx + 1) % DEPTH;
          end
          1: begin
            port_2_queue[port_2_widx] = ridx;
            port_2_widx <= (port_2_widx + 1) % DEPTH;
          end
          2: begin
            port_3_queue[port_3_widx] = ridx;
            port_3_widx <= (port_3_widx + 1) % DEPTH;
          end
        endcase

        next_state = IDLE;
      end
    endcase
  end

  // Port 1 FSM
  always @(posedge clk or negedge rst)
  begin
    if (!rst) port_1_current_state <= PIDLE;
    else      port_1_current_state <= port_1_next_state;
  end

  always @(port_1_current_state, port_1_widx, posedge read_port_1_done)
  begin
    port_1_next_state = port_1_current_state;

    case (port_1_current_state)
      PIDLE: begin
        if (!port_1_empty) begin
          raddr_port_1 = port_1_queue[port_1_ridx];
          read_port_1_en = 1;
          port_1_next_state = PBUSY;
        end else
          port_1_next_state = PIDLE;
      end
      PBUSY: begin
        if (read_port_1_done) begin
          read_port_1_en = 0;
          iaddr = rptr;
          idata = port_1_queue[port_1_ridx];
          iwrite_en = 1;
          port_1_next_state = PDONE;
        end else
          port_1_next_state = PBUSY;
      end
      PDONE: begin
        iwrite_en = 0;
        rptr = (rptr + 1) % DEPTH;
        port_1_ridx = (port_1_ridx + 1) % DEPTH;
        port_1_next_state = PIDLE;
      end
    endcase
  end

  // Port 2 FSM
  always @(posedge clk or negedge rst)
  begin
    if (!rst) port_2_current_state <= PIDLE;
    else      port_2_current_state <= port_2_next_state;
  end

  always @(port_2_current_state, port_2_widx, posedge read_port_2_done)
  begin
    port_2_next_state = port_2_current_state;

    case (port_2_current_state)
      PIDLE: begin
        if (!port_2_empty) begin
          raddr_port_2 = port_2_queue[port_2_ridx];
          read_port_2_en = 1;
          port_2_next_state = PBUSY;
        end else
          port_2_next_state = PIDLE;
      end
      PBUSY: begin
        if (read_port_2_done) begin
          read_port_2_en = 0;
          iaddr = rptr;
          idata = port_2_queue[port_2_ridx];
          iwrite_en = 1;
          port_2_next_state = PDONE;
        end else begin
          port_2_next_state = PBUSY;
        end
      end
      PDONE: begin
        $display("here done");
        iwrite_en = 0;
        rptr = (rptr + 1) % DEPTH;
        port_2_ridx = (port_2_ridx + 1) % DEPTH;
        port_2_next_state = PIDLE;
      end
    endcase
  end

  // Port 3 FSM
  always @(posedge clk or negedge rst)
  begin
    if (!rst) port_3_current_state <= IDLE;
    else      port_3_current_state <= port_3_next_state;
  end

  always @(port_3_current_state, port_3_widx, posedge read_port_3_done)
  begin
    port_3_next_state = port_3_current_state;

    case (port_3_current_state)
      PIDLE: begin
        if (!port_3_empty) begin
          raddr_port_3 = port_3_queue[port_3_ridx];
          read_port_3_en = 1;
          port_3_next_state = PBUSY;
        end else
          port_3_next_state = PIDLE;
      end
      PBUSY: begin
        if (read_port_3_done) begin
          read_port_3_en = 0;
          iaddr = rptr;
          idata = port_3_queue[port_3_ridx];
          iwrite_en = 1;
          port_3_next_state = PDONE;
        end else
          port_3_next_state = PBUSY;
      end
      PDONE: begin
        iwrite_en = 0;
        rptr = (rptr + 1) % DEPTH;
        port_3_ridx = (port_3_ridx + 1) % DEPTH;
        port_3_next_state = PIDLE;
      end
    endcase
  end

endmodule
