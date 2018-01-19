`ifdef __ICARUS__
    `ifndef INCLUDE_PARAMS
        `include "./src/def_params.v"
    `endif
    `include "./src/fetch.v"
    `include "./src/decode.v"
    `include "./src/regfile.v"
    `include "./src/execute.v"
`endif

module minuteCore(
    input clk,
    input reset,
    //IMem interface
    output wire [ `ADDR_SIZE : 0] imem_rd_addr,
    output wire imem_rd_enable,
    input wire [`INSTR_SIZE : 0] imem_rd_data,
    input wire imem_rd_ready
);

    wire [`ADDR_SIZE : 0] PC_IF_ID;
    wire [`INSTR_SIZE : 0] instr_IF_ID;
    wire pipeline_valid_IF_ID;
    wire [`EX_WIDTH : 0] exception_IF_ID;
    wire exception_valid_IF_ID;
    wire flush_IF;
    wire [`INSTR_SIZE : 0] flush_addr_IF;
    wire stall_IF;

    fetch fetch(
        .clk(clk),
        .reset(reset),
        .mem_rd_addr(imem_rd_addr),
        .mem_rd_enable(imem_rd_enable),
        .mem_rd_data(imem_rd_data),
        .mem_rd_ready(imem_rd_ready),
        .instr(instr_IF_ID),
        .PC(PC_IF_ID),
        .exception(exception_IF_ID),
        .exception_valid(exception_valid_IF_ID),
        .pipeline_valid(pipeline_valid_IF_ID),
        .flush(flush_IF),
        .flush_addr(flush_addr_IF),
        .stall(stall_IF)
    );

    wire [`ADDR_SIZE : 0] PC_ID_EXE;
    `ifdef SIMULATE
    wire [`INSTR_SIZE : 0] instr_ID_EXE;
    `endif
    wire [`EX_WIDTH : 0] exception_ID_EXE;
    wire exception_valid_ID_EXE;
    wire pipeline_valid_ID_EXE;
    wire [4:0] opcode_ID_EXE;
    wire [2:0] funct_ID_EXE;
    wire variant_ID_EXE, nop_instr_ID_EXE;
    wire [`REG_DATA_SIZE : 0] op1_ID_EXE, op2_ID_EXE, offset_ID_EXE;
    wire [`REG_ADDR_SIZE : 0] rd_addr_ID_EXE;
    wire [`REG_ADDR_SIZE : 0] rs1_addr_ID_RF, rs2_addr_ID_RF;
    wire [`REG_DATA_SIZE : 0] rs1_data_ID_RF, rs2_data_ID_RF;
    wire stall_ID, flush_ID;

    decode decode(
        .clk(clk),
        .reset(reset),
        .PC_in(PC_IF_ID),
        .instr_in(instr_IF_ID),
        .exception_in(exception_IF_ID),
        .pipeline_in_valid(pipeline_valid_IF_ID),
        .PC_out(PC_ID_EXE),
        `ifdef SIMULATE .instr_out(instr_ID_EXE), `endif
        .exception_out(exception_ID_EXE),
        .exception_out_valid(exception_valid_ID_EXE),
        .pipeline_out_valid(pipeline_valid_ID_EXE),
        .opcode(opcode_ID_EXE),
        .funct(funct_ID_EXE),
        .variant(variant_ID_EXE),
        .op1(op1_ID_EXE),
        .op2(op2_ID_EXE),
        .rd_addr(rd_addr_ID_EXE),
        .offset(offset_ID_EXE),
        .nop_instr(nop_instr_ID_EXE),
        .rs1_addr(rs1_addr_ID_RF),
        .rs1_data(rs1_data_ID_RF),
        .rs2_addr(rs2_addr_ID_RF),
        .rs2_data(rs2_data_ID_RF),
        .stall(stall_ID),
        .flush(flush_ID)
    );

    regfile regfile(
        .clk(clk),
        .reset(reset),
        .rd_addr_1(rs1_addr_ID_RF),
        .rd_data_1(rs1_data_ID_RF),
        .rd_addr_2(rs2_addr_ID_RF),
        .rd_data_2(rs2_data_ID_RF)
    );

    execute execute(
        .clk(clk),
        .reset(reset),
        .PC_in(PC_ID_EXE),
        `ifdef SIMULATE instr_in(instr_ID_EXE), `endif
        .exception_in(exception_ID_EXE),
        .exception_in_valid(exception_valid_ID_EXE),
        .pipeline_in_valid(pipeline_valid_ID_EXE),
        .opcode_in(opcode_ID_EXE),
        .funct_in(funct_ID_EXE),
        .variant(variant_ID_EXE),
        .op1(op1_ID_EXE),
        .op2(op1_ID_EXE),
        .rd_addr_in(rd_addr_ID_EXE),
        .offset(offset_ID_EXE),
        .nop_instr_in(nop_instr_ID_EXE)
    );

endmodule // minuteCore