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

  reg read_port_1_en, read_port_2_en, read_port_3_en;
  reg write_en;
  reg uread_en;
  reg [(`PTR_SZ-1):0]      raddr_port_1, raddr_port_2, raddr_port_3;
  reg [(`PTR_IN_SZ-1):0]   raddr_in_port_1, raddr_in_port_2, raddr_in_port_3;
  reg [(`PTR_SZ-1):0]      uaddr;
  reg [(`PTR_IN_SZ-1):0]   uaddr_in;
  reg [(`PTR_SZ-1):0]      waddr;
  reg [(`PTR_IN_SZ-1):0]   waddr_in;
  reg [(`UWIDTH-1):0]      wdata;
  wire [(`UWIDTH-1):0] rdata_port_1, rdata_port_2, rdata_port_3;
  wire [(`UWIDTH-1):0] udata;

  /*
  reg read_port_1_done, read_port_2_done, read_port_3_done;
  reg [(ptr_sz-1):0] rq2_wptr;
  reg [(uwidth-1):0] udata;
  wire uread_en;
  wire [(ptr_sz-1):0] uaddr;
  wire [(ptr_in_sz-1):0] uaddr_in;
  wire read_port_1_en, read_port_2_en, read_port_3_en;
  wire [(ptr_sz-1):0] raddr_port_1, raddr_port_2, raddr_port_3;
  wire [(ptr_sz-1):0] rptr_gray;
  */
  
  wire [(`PTR_SZ-1):0] irdata;
  reg [(`PTR_SZ-1):0] iraddr, iwaddr, iwdata;
  reg iwrite_en, iread_en;

  fifo_memory fm (.read_port_1_en(read_port_1_en), .read_port_2_en(read_port_2_en), .read_port_3_en(read_port_2_en), .write_en(write_en), .uread_en(uread_en), .raddr_port_1(raddr_port_1), .raddr_port_2(raddr_port_2), .raddr_port_3(raddr_port_3), .raddr_in_port_1(raddr_in_port_1), .raddr_in_port_2(raddr_in_port_2), .raddr_in_port_3(raddr_in_port_3), .uaddr(uaddr), .uaddr_in(uaddr_in), .waddr(waddr), .waddr_in(waddr_in), .wdata(wdata), .rdata_port_1(rdata_port_1), .rdata_port_2(rdata_port_2), .rdata_port_3(rdata_port_3), .udata(udata));

  fifo_idx_map fim(.rst(rst), .read_en(iread_en), .write_en(iwrite_en), .raddr(iraddr), .waddr(iwaddr), .wdata(iwdata), .rdata(irdata));

  reg [(4-1):0] i;

  initial begin
   fork
     begin: clock_thread
       clk2 = 1'b0;
       forever #`CLK_2 clk2 =~ clk2;
     end
     begin: stimulus_thread
       rst = 0;
       /*
       #`CLK_2 rst = 1; write_en = 1; waddr = 0; waddr_in = 0; wdata = 10; // source_id
       #`CLK_2 waddr_in = 1; wdata = 5; // dest_id
       #`CLK_2 waddr_in = 2; wdata = 3; // size
       #`CLK_2 waddr_in = 3; wdata = 0; // data 1
       #`CLK_2 waddr_in = 4; wdata = 1; // data 2
       #`CLK_2 waddr_in = 5; wdata = 2; // data 3
       #`CLK_2 waddr_in = 6; wdata = 15; // crc
       */
       #`CLK_2 rst = 1; iwrite_en = 1; iwaddr = 0; iwdata = 3; // source_id
       #`CLK_2 iwaddr = 1; iwdata = 3; // dest_id
       #`CLK_2 iwaddr = 2; iwdata = 3; // size
     end
     begin: checking_thread
       #(`CLK_2) for (i = 0; i < 3; i = i+1) $display("memory[%d] = %b", i, fim.memory[i]);
       #(`CLK_2) for (i = 0; i < 3; i = i+1) $display("memory[%d] = %b", i, fim.memory[i]);
       #(`CLK_2) for (i = 0; i < 3; i = i+1) $display("memory[%d] = %b", i, fim.memory[i]);
       #(`CLK_2) for (i = 0; i < 3; i = i+1) $display("memory[%d] = %b", i, fim.memory[i]);
     end
     begin: dve_thread
       $vcdpluson;
     end
     begin: ending_thread
       #50 disable clock_thread; disable stimulus_thread; disable dve_thread;
     end
   join
   $finish;
  end
  
  initial
    $monitor("Time %d, clk = %b rst = %b", $time, clk2, rst);

endmodule
