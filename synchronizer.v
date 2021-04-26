// DFF1
// Author: Vikas Gundapuneedi

module DFF1 #(parameter PTR_SZ=2)
             (input  rst,
              input  clk,
              input  [PTR_SZ:0] addr_gray,
              output reg [PTR_SZ:0] rq2_addr, rq1_addr
);
 
 //synchronizing the read pointer into the write clock domain 

  always @(posedge clk or negedge rst)
  begin
    if (!rst) begin
      { rq2_addr, rq1_addr } <= 2'b0;
    end else begin 
      { rq2_addr, rq1_addr } <= { rq1_addr, addr_gray };
    end
  end

endmodule

// synchronizer
// Author: Vladislav Rykov
module synchronizer #(parameter PTR_SZ=2)
                     (input clk1, clk2, rst,
                      input [PTR_SZ:0] waddr_gray, raddr_gray,
                      output [PTR_SZ:0] rq2_raddr, rq2_waddr
);
  wire [PTR_SZ:0] rq1_waddr, rq1_raddr;

  DFF1 #(.PTR_SZ(PTR_SZ)) w2rdff1 (.rst(rst), .clk(clk2), .addr_gray(waddr_gray), .rq1_addr(rq1_waddr), .rq2_addr(rq2_waddr));
  DFF1 #(.PTR_SZ(PTR_SZ)) r2wdff1 (.rst(rst), .clk(clk1), .addr_gray(raddr_gray), .rq1_addr(rq1_raddr), .rq2_addr(rq2_raddr));

endmodule

