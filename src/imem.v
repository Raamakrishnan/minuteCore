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

    reg [`INSTR_SIZE : 0] mem [4:0];

    always@(posedge(clk) or posedge(reset)) begin
        if(reset) begin
            $readmemh("imem.hex", mem);
            ready <= 0;
        end
        else if(enable) begin
            data <= mem[addr];
            ready <= 1;
        end
    end

endmodule // imem