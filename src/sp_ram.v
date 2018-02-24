`ifdef __ICARUS__
    `ifndef INCLUDE_PARAMS
        `include "./src/def_params.v"
    `endif
`endif

// Quartus II Verilog Template
// Single port RAM with single read/write address 

module sp_ram 
#(parameter DATA_WIDTH=8, parameter ADDR_WIDTH=6, parameter INIT_FILE = "", parameter OUT_FILE = "")
(
    input [(DATA_WIDTH-1):0] data,
    input [(ADDR_WIDTH-1):0] addr,
    input we, clk,
    output [(DATA_WIDTH-1):0] q
`ifdef SIMULATE
    ,input finish
`endif
);

    // Declare the RAM variable
    reg [DATA_WIDTH-1:0] ram[0:2**ADDR_WIDTH-1];

    // Variable to hold the registered read address
    reg [ADDR_WIDTH-1:0] addr_reg;

    initial $readmemh(INIT_FILE, ram);

    always @ (posedge clk)
    begin
        // Write
        if (we)
            ram[addr] <= data;

        addr_reg <= addr;
    end

    // Continuous assignment implies read returns NEW data.
    // This is the natural behavior of the TriMatrix memory
    // blocks in Single Port mode.  
    assign q = ram[addr_reg];

`ifdef SIMULATE
    always@(posedge(finish)) begin
        $writememh(OUT_FILE, ram);
    end
    // always@(posedge clk) begin
    //     $strobe("%0d\tsp_ram: File: %s We: %b Addr: %h Data: %h q: %h", $time, INIT_FILE, we, addr, data, q);
    // end
`endif

endmodule
