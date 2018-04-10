`ifdef __ICARUS__
    `ifndef INCLUDE_PARAMS
        `include "./src/def_params.v"
    `endif
`endif
`ifdef MODEL_TECH
    `ifndef INCLUDE_PARAMS
        `include "def_params.v"
    `endif
`endif
`define DISPLAY(A) `ifdef SIMULATE $display("%0d\tCSR_EXCEPT: ",$time,A); `endif

module csr_except(
    input wire exception_valid,
    input wire [`EX_WIDTH : 0] exception,
    input wire [4:0] opcode,
    input wire [2:0] funct,
    input wire [11:0] csr_addr,

    output wire [`REG_ADDR_SIZE : 0] wr_addr,
    output wire [`REG_DATA_SIZE : 0] wr_data,
    output wire wr_enable
);
endmodule