// fifo_idx_map.v
// Author: Vladislav Rykov

// DEPTH     - FIFO size (WIDTH from fifo_memory.v)
// WIDTH     - FIFO entry width (PTR_SZ from fifo_memory.v)
// PTR_SZ    - FIFO entry index size in bits
module fifo_idx_map #(parameter DEPTH = 3, PTR_SZ = 2)
		     (input rst, read_en, write_en,
		      input [(PTR_SZ-1):0] raddr, waddr,
		      input [(PTR_SZ-1):0]  wdata,
		      output reg [(PTR_SZ-1):0] rdata
);

  reg [(PTR_SZ-1):0] memory [(DEPTH-1):0];
  reg [(PTR_SZ-1):0] i;
 
  always @(*)
  begin
    if (write_en) memory[waddr] = wdata;
    if (read_en)  rdata = memory[raddr];
  end

  always @(negedge rst)
    for (i = 0; i < DEPTH; i = i+1) memory[i] = i;
endmodule
