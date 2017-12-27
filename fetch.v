`ifdef __ICARUS__
    `ifndef INCLUDE_PARAMS
        `include "params.v"
    `endif
`endif

module fetch(
    input wire clk,
    input wire reset,

    //Interface with memory
    output reg [ `ADDR_SIZE : 0] addr_to_mem,
    output reg st_addr_to_mem,
    input wire data_from_mem,
    input wire int_data_from_mem,

    //Interface with pipeline
    output reg [`INSTR_SIZE : 0] instr,
    output reg [ `ADDR_SIZE : 0] PC,

    input wire is_flush,
    input wire [`INSTR_SIZE : 0] flush_addr,

    input wire is_stall
);

    reg [`ADDR_SIZE : 0] next_PC;

    always@(is_flush or flush_addr or is_stall or PC or reset) begin
        if(reset)
            next_PC = 0;
        else if(is_stall)
            next_PC = PC;
        else if(is_flush)
            next_PC = flush_addr;
        else
            next_PC = PC + 'd4;
    end

    always@(posedge(clk)) begin
        PC = next_PC;
    end

endmodule