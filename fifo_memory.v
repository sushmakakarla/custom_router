// fifo_memory.v
// Author: Vladislav Rykov

// DEPTH     - FIFO size
// WIDTH     - FIFO entry width in units (bytes in our case)
// UWIDTH    - FIFO entry unit width in bits
// PTR_SZ    - FIFO entry index size in bits
// PTR_IN_SZ - FIFO index within entry size in bits (ideally ceil(log2(WIDTH)) )
module fifo_memory #(parameter DEPTH = 3, WIDTH = 11, UWIDTH = 8, PTR_SZ = 2, PTR_IN_SZ = 4)
		    (input read_port_1_en, read_port_2_en, read_port_3_en,
		     input write_en,
		     input uread_en,
		     input [(PTR_SZ-1):0]      raddr_port_1, raddr_port_2, raddr_port_3,
		     input [(PTR_IN_SZ-1):0]   raddr_in_port_1, raddr_in_port_2, raddr_in_port_3,
		     input [(PTR_SZ-1):0]      uaddr,
		     input [(PTR_IN_SZ-1):0]   uaddr_in,
		     input [(PTR_SZ-1):0]      waddr,
		     input [(PTR_IN_SZ-1):0]   waddr_in,
		     input [(UWIDTH-1):0]      wdata,
		     output reg [(UWIDTH-1):0] rdata_port_1, rdata_port_2, rdata_port_3,
		     output reg [(UWIDTH-1):0] udata
);

  reg [(UWIDTH-1):0] memory [(DEPTH-1):0][(WIDTH-1):0];
  // reg [(UWIDTH*WIDTH-1):0] memory [(DEPTH-1):0];

  always @(*)
  begin
    if (write_en) memory[waddr][waddr_in] = wdata;
    if (uread_en) udata = memory[uaddr][uaddr_in];
    if (read_port_1_en) rdata_port_1 = memory[raddr_port_1][raddr_in_port_1];
    if (read_port_2_en) rdata_port_2 = memory[raddr_port_2][raddr_in_port_2];
    if (read_port_3_en) rdata_port_3 = memory[raddr_port_3][raddr_in_port_3];
  end
endmodule
