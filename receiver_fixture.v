`include "packet_receiver.v"
`define CLK_1     5 // for test ease
module receiver_fixture;
  reg clk1, rst;
  reg packet_valid_i;
  reg [7:0] pdata;
  reg wfull_port_1,wfull_port_2,wfull_port_3;
  wire stop_packet_send;
  wire FIFO_EN_1,FIFO_EN_2,FIFO_EN_3;
  wire winc_port_1,winc_port_2,winc_port_3,waddr_in_port_1,waddr_in_port_2,waddr_in_port_3;
  wire [7:0]wdata_port_1,wdata_port_2,wdata_port_3;


  packet_receiver rf(.clk1(clk1), .rst(rst), .packet_valid_i(packet_valid_i), .pdata(pdata), .wfull_port_1(wfull_port_1), .wfull_port_2(wfull_port_2), .wfull_port_3(wfull_port_3), .stop_packet_send(stop_packet_send), .FIFO_EN_1(FIFO_EN_1), .FIFO_EN_2(FIFO_EN_2), .FIFO_EN_3(FIFO_EN_3), .winc_port_1(winc_port_1), .winc_port_2(winc_port_2), .winc_port_3(winc_port_3), .wdata_port_1(wdata_port_1), .wdata_port_2(wdata_port_2), .wdata_port_3(wdata_port_3));

  initial begin
   fork
     begin: clock_1_thread
       clk1 = 1'b0;
       forever #`CLK_1 clk1 =~ clk1;
     end
     begin: stimulus_thread
       rst = 0; 
       // packet 1
       #`CLK_1 rst = 1; 
       #`CLK_1 packet_valid_i = 1;
       // #`CLK_1 wfull_port_1 enable so that packet shouldnt enter in router(test later)
       #`CLK_1 pdata = 00000000;
       #`CLK_1 pdata = 00000000;
       #`CLK_1 pdata = 00000001;
       #`CLK_1 pdata = 11111111;
       #`CLK_1 pdata = 11111111;
       $display("packet entered succesfully");
     end
     begin: ending_thread
       #(20*`CLK_1) disable clock_1_thread; disable stimulus_thread;
     end
   join
   $finish;
  end
  
  initial
    $monitor("Time = %d, clk = %b, rst = %b, packet_valid_i = %b, FIFO_EN_1 = %b, FIFO_EN_2 = %b, FIFO_EN_3 = %b, pdata = %b, wdata_port_1 = %b, wdata_port_2 = %b, wdata_port_3 = %b, winc_port_1 = %d, winc_port_2 = %d, winc_port_3 = %d", $time, clk1, rst, packet_valid_i, FIFO_EN_1, FIFO_EN_2, FIFO_EN_3, pdata, wdata_port_1, wdata_port_2, wdata_port_3, winc_port_1, winc_port_2, winc_port_3);

endmodule
