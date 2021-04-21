`include "fifo_memory.v"
`include "fifo_idx_map.v"
`include "fifo_read_logic.v"

`define CLK_1     2 // F=250KHz T=4us
`define CLK_2     5 // F=100KHz T=10us

`define PTR_SZ 	  2
`define PTR_IN_SZ 4
`define UWIDTH    8

module fifo_fixture;
  reg clk2, rst;

  wire read_port_1_en, read_port_2_en, read_port_3_en;
  reg write_en;
  wire uread_en;
  wire [(`PTR_SZ-1):0]      raddr_port_1, raddr_port_2, raddr_port_3;
  wire [(`PTR_IN_SZ-1):0]   raddr_in_port_1, raddr_in_port_2, raddr_in_port_3;
  wire [(`PTR_SZ-1):0]      uaddr;
  wire [(`PTR_IN_SZ-1):0]   uaddr_in;
  reg [(`PTR_SZ-1):0]      waddr;
  reg [(`PTR_IN_SZ-1):0]   waddr_in;
  reg [(`UWIDTH-1):0]      wdata;
  wire [(`UWIDTH-1):0] rdata_port_1, rdata_port_2, rdata_port_3;
  wire [(`UWIDTH-1):0] udata;

  wire [(`PTR_SZ-1):0] irdata, iraddr;
  reg [(`PTR_SZ-1):0] iwaddr, iwdata;
  wire iwrite_en, iread_en;
  
  reg read_port_1_done, read_port_2_done, read_port_3_done;
  reg [(`PTR_SZ-1):0] rq2_wptr;
  wire [(`PTR_SZ-1):0] rptr_gray;


  fifo_memory fm (.read_port_1_en(read_port_1_en), .read_port_2_en(read_port_2_en), .read_port_3_en(read_port_2_en), .write_en(write_en), .uread_en(uread_en), .raddr_port_1(raddr_port_1), .raddr_port_2(raddr_port_2), .raddr_port_3(raddr_port_3), .raddr_in_port_1(raddr_in_port_1), .raddr_in_port_2(raddr_in_port_2), .raddr_in_port_3(raddr_in_port_3), .uaddr(uaddr), .uaddr_in(uaddr_in), .waddr(waddr), .waddr_in(waddr_in), .wdata(wdata), .rdata_port_1(rdata_port_1), .rdata_port_2(rdata_port_2), .rdata_port_3(rdata_port_3), .udata(udata));

  fifo_idx_map fim (.rst(rst), .read_en(iread_en), .write_en(iwrite_en), .raddr(iraddr), .waddr(iwaddr), .wdata(iwdata), .rdata(irdata));

  fifo_read_logic frl (.clk(clk2), .rst(rst), .read_port_1_done(read_port_1_done), .read_port_2_done(read_port_2_done), .read_port_3_done(read_port_3_done), .rq2_wptr(rq2_wptr), .udata(udata), .uread_en(uread_en), .uaddr(uaddr), .uaddr_in(uaddr_in), .read_port_1_en(read_port_1_en), .read_port_2_en(read_port_2_en), .read_port_3_en(read_port_3_en), .raddr_port_1(raddr_port_1), .raddr_port_2(raddr_port_2), .raddr_port_3(raddr_port_3), .rptr_gray(rptr_gray), .iaddr(iraddr), .idata(irdata), .iwrite_en(iwrite_en), .iread_en(iread_en));


  reg [(4-1):0] i, k;
  reg [8:0] j;

  initial begin
   fork
     begin: clock_thread
       clk2 = 1'b0;
       forever #`CLK_2 clk2 =~ clk2;
     end
     begin: stimulus_thread
       rst = 0; rq2_wptr = 0;
       read_port_1_done = 0; read_port_2_done = 0; read_port_3_done = 0;
       waddr = 0; waddr_in = 0; wdata = 0;
       iwaddr = 0; iwdata = 0;
       /* // testing fifo_memory
       #`CLK_2 rst = 1; write_en = 1; waddr = 0; waddr_in = 0; wdata = 10; // source_id
       #`CLK_2 waddr_in = 1; wdata = 5; // dest_id
       #`CLK_2 waddr_in = 2; wdata = 3; // size
       #`CLK_2 waddr_in = 3; wdata = 0; // data 1
       #`CLK_2 waddr_in = 4; wdata = 1; // data 2
       #`CLK_2 waddr_in = 5; wdata = 2; // data 3
       #`CLK_2 waddr_in = 6; wdata = 15; // crc
       */

       /* // testing fifo_idx_map
       #`CLK_2 rst = 1; iwrite_en = 1; iwaddr = 0; iwdata = 3; // source_id
       #`CLK_2 iwaddr = 1; iwdata = 3; // dest_id
       #`CLK_2 iwaddr = 2; iwdata = 3; // size
       */
       
       // testing fifo_read_logic
       // packet 1
       #`CLK_2 rst = 1; write_en = 1; waddr = 0; waddr_in = 0; wdata = 10; // source_id
       #`CLK_2 waddr_in = 1; wdata = 160; // dest_id
       #`CLK_2 waddr_in = 2; wdata = 3; // size
       #`CLK_2 waddr_in = 3; wdata = 0; // data 1
       #`CLK_2 waddr_in = 4; wdata = 1; // data 2
       #`CLK_2 waddr_in = 5; wdata = 2; // data 3
       #`CLK_2 waddr_in = 6; wdata = 15; rq2_wptr = 1; // crc

       #`CLK_2 waddr = 1; waddr_in = 0; wdata = 11; // source_id
       #`CLK_2 waddr_in = 1; wdata = 16; // dest_id
       #`CLK_2 waddr_in = 2; wdata = 3; // size
       #`CLK_2 waddr_in = 3; wdata = 0; // data 1
       #`CLK_2 waddr_in = 4; wdata = 1; // data 2
       #`CLK_2 waddr_in = 5; wdata = 2; // data 3
       #`CLK_2 waddr_in = 6; wdata = 15; rq2_wptr = 2; // crc
       
       #`CLK_2 waddr = 2; waddr_in = 0; wdata = 11; // source_id
       #`CLK_2 waddr_in = 1; wdata = 160; // dest_id
       #`CLK_2 waddr_in = 2; wdata = 3; // size
       #`CLK_2 waddr_in = 3; wdata = 0; // data 1
       #`CLK_2 waddr_in = 4; wdata = 1; // data 2
       #`CLK_2 waddr_in = 5; wdata = 2; // data 3
       #`CLK_2 waddr_in = 6; wdata = 15; rq2_wptr = 3; // crc
       
       #(`CLK_2*10) read_port_2_done = 1;
       #`CLK_2 read_port_2_done = 0;
       #(`CLK_2*2) read_port_1_done = 1;
       #`CLK_2 read_port_1_done = 0;
       #(`CLK_2*2) read_port_3_done = 1;
       #`CLK_2 read_port_3_done = 0;
       /* // packet 2
       #`CLK_2 waddr = 0; waddr_in = 0; wdata = 10; // source_id
       #`CLK_2 waddr_in = 1; wdata = 5; // dest_id
       #`CLK_2 waddr_in = 2; wdata = 3; // size
       #`CLK_2 waddr_in = 3; wdata = 0; // data 1
       #`CLK_2 waddr_in = 4; wdata = 1; // data 2
       #`CLK_2 waddr_in = 5; wdata = 2; // data 3
       #`CLK_2 waddr_in = 6; wdata = 15; // crc
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
       for (j = 0; j < 60; j = j+1) begin
         // 1. memory dump
         #(`CLK_2) for (i = 0; i < 11; i = i+1) 
                       $display("memory[0][%d] = %b [1][%d] = %b [2][%d] = %b", i, fm.memory[0][i], i, fm.memory[1][i], i, fm.memory[2][i]);
         for (i = 0; i < 3; i = i+1) $display("idx_map[%d] = %b", i, fim.memory[i]);
       
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
       
       end
     end
     begin: dve_thread
       $vcdpluson;
     end
     begin: ending_thread
       #(60*`CLK_2) disable clock_thread; disable stimulus_thread; disable dve_thread;
     end
   join
   $finish;
  end
  
  initial
    $monitor("Time %d, clk = %b rst = %b", $time, clk2, rst);

endmodule
