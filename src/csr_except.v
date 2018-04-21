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
    input wire [`REG_DATA_SIZE : 0] wr_data,

    output wire [`REG_ADDR_SIZE : 0] rd_addr,
    output wire [`REG_DATA_SIZE : 0] rd_data,
    output wire wr_enable,
    output wire flush,
    output wire [`ADDR_SIZE : 0] flush_addr
);

    reg [31:0] csr_misa = 32'b01000000_00000000_00000001_00000000; 
    //mvendorid = 0
    //marchid = 0
    //mimpid = 0
    //mhartid = 0
    //mstatus = 0
    reg [31:0] csr_mtvec = 0;
    reg [31:0] csr_mepc;
    reg [31:0] csr_mcause;
    reg [31:0] csr_mtval;
    reg [31:0] csr_mscratch;

    assign flush = exception_valid;
    assign flush_addr = (exception_valid)? csr_mtvec : 0;

    always@(*) begin
        if(opcode == `OP_SYSTEM && funct == `F3_CSRRW) begin
            
        end
    end

endmodule