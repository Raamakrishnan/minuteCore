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
    output reg [`INSTR_SIZE : 0] data,
    output reg ready
);

    reg [`INSTR_SIZE : 0] mem [0 : 16];
    
    wire [`INSTR_SIZE : 0] q = mem[addr[`ADDR_SIZE : 2]];  

    initial begin
        $readmemh("./bin/imem.hex", mem);
    end

    always@(posedge(clk)) begin
        ready <= 0;
        if(enable) begin
            data <= q;
            $strobe("%0d\tIMEM: Addr: %h Data: %h", $time, addr, data);
            ready <= 1;
        end
    end
endmodule // imem