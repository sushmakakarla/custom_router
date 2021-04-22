// fifo_read_logic_fixture.v
// Author: Vladislav Rykov
//
// TODO: solve unused fifo position index issue (wfull at last position)

`include "fifo_read_logic.v"

`define CLK_1     5 // for test ease

`define DEPTH     3
`define PTR_SZ 	  2

module fifo_write_logic_fixture;
  reg clk1, rst;

  reg rinc;
  reg [(`PTR_SZ-1):0] rq2_waddr;
  wire [(`PTR_SZ-1):0] raddr, raddr_gray;
  wire rempty, read_en;

  reg [(4-1):0] i, k;
  reg [8:0] j;

  
  fifo_read_logic #(.DEPTH(`DEPTH), .PTR_SZ(`PTR_SZ)) frl (.clk(clk1), .rst(rst), .rinc(rinc), .rq2_waddr(rq2_waddr), .rempty(rempty), .read_en(read_en), .raddr(raddr), .raddr_gray(raddr_gray));

  initial begin
   fork
     begin: clock_1_thread
       clk1 = 1'b0;
       forever #`CLK_1 clk1 =~ clk1;
     end
     begin: stimulus_thread
       rst = 0; rinc = 0; rq2_waddr = 3;
       // packet 1
       #`CLK_1 rst = 1;
       #(`CLK_1*2) rinc = 1;
       #`CLK_1 rinc = 0;
       #`CLK_1 rinc = 1;
       #`CLK_1 rinc = 0;
       #`CLK_1 rinc = 1;
       #`CLK_1 rinc = 0;
       $display("no reaction at winc toggle");
       #`CLK_1 rinc = 1;
       #`CLK_1 rinc = 0;
       #`CLK_1 rq2_waddr = 3;
       #(`CLK_1*2) rinc = 1;
       #`CLK_1 rinc = 0;
       #`CLK_1 rq2_waddr = 0;
       #`CLK_1 rinc = 1;
       #`CLK_1 rinc = 0;
       #`CLK_1 rinc = 1;
       #`CLK_1 rinc = 0;
       /* 
       // packet 2 
       #`CLK_1 winc = 0; waddr_in = 0; wdata = 100; // source_id
       #`CLK_1 waddr_in = 1; wdata = 10; // dest_id
       #`CLK_1 waddr_in = 2; wdata = 4; // size
       #`CLK_1 waddr_in = 3; wdata = 0; // data 1
       #`CLK_1 waddr_in = 4; wdata = 1; // data 2
       #`CLK_1 waddr_in = 5; wdata = 2; // data 3
       #`CLK_1 waddr_in = 6; wdata = 3; // data 4
       #`CLK_1 waddr_in = 7; wdata = 55; winc = 1; // crc
       
       // packet 3
       #`CLK_1 winc = 0; waddr_in = 0; wdata = 255; // source_id
       #`CLK_1 waddr_in = 1; wdata = 63; // dest_id
       #`CLK_1 waddr_in = 2; wdata = 5; // size
       #`CLK_1 waddr_in = 3; wdata = 0; // data 1
       #`CLK_1 waddr_in = 4; wdata = 1; // data 2
       #`CLK_1 waddr_in = 5; wdata = 2; // data 3
       #`CLK_1 waddr_in = 6; wdata = 3; // data 4
       #`CLK_1 waddr_in = 7; wdata = 4; // data 5
       #`CLK_1 waddr_in = 8; wdata = 55; winc = 1; // crc
       
       #`CLK_1 winc = 0;
       */
     end
     begin: checking_thread
       /* // checking fifo_memory
       for (j = 0; j < 8; j = j+1)
         #(`CLK_2) for (i = 0; i < 8; i = i+1) $display("memory[%d] = %b", i, fm.memory[i]);
       */

       /* // checking fifo_idx_map
       for (j = 0; j < 4; j = j+1)
         #(`CLK_2) for (i = 0; i < 3; i = i+1) $display("memory[%d] = %b", i, fim.memory[i]);
       */

       // cheching fifo_read_logic
       for (j = 0; j < 24; j = j+1) begin
         // 1. memory dump

         /*
         // 2. dispatcher monitor
         $display("Dispatcher\ncurrent_state = %d, next_state = %d, rq2_wptr = %d rptr = %d, vrptr = %d", frl.current_state, frl.next_state, rq2_wptr, frl.rptr, frl.vrptr);
       
         // 4. Indexing
         $display("Indexing\niread_en = %d, iaddr = %d, idata = %d, ridx = %d", frl.iread_en, frl.iaddr, frl.idata, frl.ridx);

         // 4. Routing
         $display("Routing\nuread_en = %d, uaddr = %d, uaddr_in = %d, udata = %d, dest_id = %d, out_port = %d", frl.uread_en, frl.uaddr, frl.uaddr_in, frl.udata, frl.dest_id, frl.out_port);

         // 5. Monitor port 1   
         $display("Port 1\nread_port_1_en = %d, raddr_port_1 = %d, port_1_current_state = %d, port_1_next_state = %d, port_1_ridx = %d, port_1_widx = %d, port_1_empty = %d, read_port_1_done = %d", frl.read_port_1_en, frl.raddr_port_1, frl.port_1_current_state, frl.port_1_next_state, frl.port_1_ridx, frl.port_1_widx, frl.port_1_empty, frl.read_port_1_done);
         for (i = 0; i < 3; i = i+1) $display("port_1_queue[%d] = %b", i, frl.port_1_queue[i]);
         
         // 6. Monitor port 2
         $display("Port 2\nread_port_2_en = %d, raddr_port_2 = %d, port_2_current_state = %d, port_2_next_state = %d, port_2_ridx = %d, port_2_widx = %d, port_2_empty = %d, read_port_2_done = %d", frl.read_port_2_en, frl.raddr_port_2, frl.port_2_current_state, frl.port_2_next_state, frl.port_2_ridx, frl.port_2_widx, frl.port_2_empty, frl.read_port_2_done);
         for (i = 0; i < 3; i = i+1) $display("port_2_queue[%d] = %b", i, frl.port_2_queue[i]);
         
         // 7. Monitor port 3
         $display("Port 3\nread_port_3_en = %d, raddr_port_3 = %d, port_3_current_state = %d, port_3_next_state = %d, port_3_ridx = %d, port_3_widx = %d, port_3_empty = %d, read_port_3_done = %d", frl.read_port_3_en, frl.raddr_port_3, frl.port_3_current_state, frl.port_3_next_state, frl.port_3_ridx, frl.port_3_widx, frl.port_3_empty, frl.read_port_3_done);
         for (i = 0; i < 3; i = i+1) $display("port_3_queue[%d] = %b", i, frl.port_3_queue[i]);
         */
       end
     end
     begin: dve_thread
       $vcdpluson;
     end
     begin: ending_thread
       #(24*`CLK_1) disable clock_1_thread; disable stimulus_thread; disable dve_thread;
     end
   join
   $finish;
  end
  
  initial
    $monitor("Time %3d, clk = %b rst = %b, cs = %d, ns = %d, rinc = %d, rq2_waddr = %d, rempty = %d, rempty_tmp = %d, read_en = %d, raddr = %d, raddr_tmp = %d, raddr_gray = %d, waddr = %d", $time, clk1, rst, frl.current_state, frl.next_state, frl.rinc, frl.rq2_waddr, frl.rempty, frl.rempty_tmp, frl.read_en, frl.raddr, frl.raddr_tmp, frl.raddr_gray, frl.waddr);

endmodule
