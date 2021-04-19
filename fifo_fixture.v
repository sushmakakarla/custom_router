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

  fifo_memory fm (.read_port_1_en(read_port_1_en), .read_port_2_en(read_port_2_en), .read_port_3_en(read_port_2_en), .write_en(write_en), .uread_en(uread_en), .raddr_port_1(raddr_port_1), .raddr_port_2(raddr_port_2), .raddr_port_3(raddr_port_3), .raddr_in_port_1(raddr_in_port_1), .raddr_in_port_2(raddr_in_port_2), .raddr_in_port_3(raddr_in_port_3), .uaddr(uaddr), .uaddr_in(uaddr_in), .waddr(waddr), .waddr_in(waddr_in), .wdata(wdata), .rdata_port_1(rdata_port_1), .rdata_port_2(rdata_port_2), .rdata_port_3(rdata_port_3), .udata(udata));

  reg [(4-1):0] i;

  initial begin
   fork
     begin: clock_thread
       clk2 = 1'b0;
       forever #`CLK_2 clk2 =~ clk2;
     end
     begin: stimulus_thread
       rst = 0;
       #`CLK_2 rst = 1; write_en = 1; waddr = 0; waddr_in = 0; wdata = 10; // source_id
       #`CLK_2 waddr_in = 1; wdata = 5; // dest_id
       #`CLK_2 waddr_in = 2; wdata = 3; // size
       #`CLK_2 waddr_in = 3; wdata = 0; // data 1
       #`CLK_2 waddr_in = 4; wdata = 1; // data 2
       #`CLK_2 waddr_in = 5; wdata = 2; // data 3
       #`CLK_2 waddr_in = 6; wdata = 15; // crc
     end
     begin: checking_thread
       #(`CLK_2*8) for (i = 0; i < 10; i = i+1) $display("memory[%d] = %b", i, fm.memory[0][i]);
     end
     begin: dve_thread
       $vcdpluson;
     end
     begin: ending_thread
       #440 disable clock_thread; disable stimulus_thread; disable dve_thread;
     end
   join
   $finish;
  end
  
  initial
    $monitor("Time %d, clk = %b rst = %b", $time, clk2, rst);

endmodule
