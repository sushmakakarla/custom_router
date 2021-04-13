// fifo_idx_map.v
// Author: Vladislav Rykov

// DEPTH     - FIFO size (WIDTH from fifo_memory.v)
// WIDTH     - FIFO entry width (PTR_SZ from fifo_memory.v)
// PTR_SZ    - FIFO entry index size in bits
module fifo_idx_map #(parameter DEPTH = 3, WIDTH = 4, PTR_SZ = 2)
		     (input read_en, write_en,
		      input [(PTR_SZ-1):0] raddr, waddr,
		      input [(WIDTH-1):0]  wdata,
		      output [(WIDTH-1):0] rdata
);

  reg [(WIDTH-1):0] memory [(DEPTH-1):0];

  always @(*)
  begin
    if (write_en) memory[waddr] = wdata;
    if (read_en)  rdata = mem[raddr];
  end
endmodule
