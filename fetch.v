`include "params.v"

module fetch(
    input wire clk,
    input wire reset,

    //Interface with memory
    output reg [ `ADDR_SIZE : 0] addr_to_mem,
    input wire data_from_mem,

    //Interface with pipeline
    output wire [`INSTR_SIZE : 0] instr,
    output wire [ `ADDR_SIZE : 0] PC
);

    reg [`ADDR_SIZE : 0] PC_reg;
    reg [`ADDR_SIZE : 0] next_PC_reg;

endmodule