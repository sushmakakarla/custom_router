`include "fifo.v"

`define CLK_1     5 // for test ease
//`define CLK_1     2 // F=250KHz T=4us
`define CLK_2     5 // F=100KHz T=10us

`define DEPTH     3
`define WIDTH     11
`define UWIDTH    8
`define PTR_SZ 	  2
`define PTR_IN_SZ 4

module fifo_fixture;
  reg clk1, clk2, rst;

  reg winc, rinc;
  reg [(`PTR_IN_SZ-1):0] waddr_in, raddr_in;
  reg [(`UWIDTH-1):0] wdata;
  wire [(`UWIDTH-1):0] rdata;
  wire wfull, rempty;

  reg [(4-1):0] i, k;
  reg [8:0] j;

  fifo #(.DEPTH(`DEPTH), .WIDTH(`WIDTH), .UWIDTH(`UWIDTH), .PTR_SZ(`PTR_SZ), .PTR_IN_SZ(`PTR_IN_SZ)) f (.clk1(clk1), .clk2(clk2), .rst(rst), .winc(winc), .rinc(rinc), .waddr_in(waddr_in), .raddr_in(raddr_in), .wdata(wdata), .rdata(rdata), .wfull(wfull), .rempty(rempty));

  initial begin
   fork
     begin: clock_1_thread
       clk1 = 1'b0;
       forever #`CLK_1 clk1 =~ clk1;
     end
     begin: clock_2_thread
       clk2 = 1'b0;
       forever #`CLK_2 clk2 =~ clk2;
     end
     begin: stimulus_thread
       rst = 0; winc = 0; rinc = 0; waddr_in = 0; raddr_in = 0;
       wdata = 0;
       // packet 1
       #`CLK_1 rst = 1; 
       #(`CLK_1*2) waddr_in = 0; wdata = 10; // source_id
       #`CLK_1 waddr_in = 1; wdata = 160; // dest_id
       #`CLK_1 waddr_in = 2; wdata = 3; // size
       #`CLK_1 waddr_in = 3; wdata = 0; // data 1
       #`CLK_1 waddr_in = 4; wdata = 1; // data 2
       #`CLK_1 waddr_in = 5; wdata = 2; // data 3
       #`CLK_1 waddr_in = 6; wdata = 15; winc = 1; // crc
       #`CLK_1 winc = 0;
       
        
       // packet 2 
       #`CLK_1 winc = 0; waddr_in = 0; wdata = 100; // source_id
       #`CLK_1 waddr_in = 1; wdata = 10; // dest_id
       #`CLK_1 waddr_in = 2; wdata = 4; // size
       #`CLK_1 waddr_in = 3; wdata = 0; // data 1
       #`CLK_1 waddr_in = 4; wdata = 1; // data 2
       #`CLK_1 waddr_in = 5; wdata = 2; // data 3
       #`CLK_1 waddr_in = 6; wdata = 3; // data 4
       #`CLK_1 waddr_in = 7; wdata = 55; winc = 1; // crc
       #`CLK_1 winc = 0;

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
       for (j = 0; j < 40; j = j+1) begin
         // 1. memory dump
         #(`CLK_1) for (i = 0; i < 11; i = i+1) 
                       $display("memory[0][%d] = %b [1][%d] = %b [2][%d] = %b", i, f.fm.memory[0][i], i, f.fm.memory[1][i], i, f.fm.memory[2][i]);
         
         // fifo_write_logic
         $display("Write Logic\ncurrent_state = %d, next_state = %d, winc = %d rq2_raddr = %d, wfull = %d, write_en = %d, waddr = %d, waddr_gray = %d", f.fwl.current_state, f.fwl.next_state, f.fwl.winc, f.fwl.rq2_raddr, f.fwl.wfull, f.fwl.write_en, f.fwl.waddr, f.fwl.waddr_gray);
                  


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
       #(40*`CLK_1) disable clock_1_thread; disable clock_2_thread; disable stimulus_thread; disable dve_thread;
     end
   join
   $finish;
  end
  
  initial
    $monitor("Time %d, clk = %b rst = %b", $time, clk2, rst);

endmodule
