`ifdef __ICARUS__
    `ifndef INCLUDE_PARAMS
        `include "./src/def_params.v"
    `endif
`endif

module imem(
    input wire clk,
    input wire reset,
    input wire [`ADDR_SIZE : 0] addr,
    input wire enable,
    output wire [`INSTR_SIZE : 0] data,
    output reg ready
);

    reg [`INSTR_SIZE : 0] mem [0 : 16];

    reg [`ADDR_SIZE : 2] addr_reg;  

    initial begin
        $readmemh("./bin/imem.txt", mem);
    end

    assign data = mem[addr_reg];

    always@(posedge(clk)) begin
        if(enable)
            addr_reg <= addr[`ADDR_SIZE : 2];
`ifdef SIMULATE
        $strobe("%0d\tIMEM: Addr: %h Data: %h", $time, addr, data);
`endif
    end
endmodule // imem