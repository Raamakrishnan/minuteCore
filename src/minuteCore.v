`ifdef __ICARUS__
    `ifndef INCLUDE_PARAMS
        `include "./src/def_params.v"
    `endif
    `include "./src/fetch.v"
    `include "./src/decode.v"
    `include "./src/regfile.v"
    `include "./src/execute.v"
    `include "./src/memory.v"
    `include "./src/writeback.v"
`endif

module minuteCore(
    input clk,
    input reset,
    //IMem interface
    output wire [ `ADDR_SIZE : 0] imem_rd_addr,
    output wire imem_rd_enable,
    input wire [`INSTR_SIZE : 0] imem_rd_data,
    input wire imem_rd_ready,
    //DMem interface
    output wire [`ADDR_SIZE : 0] dmem_addr,
    output wire dmem_r_enable,
    output wire dmem_w_enable,
    output wire [1:0] dmem_w_size,
    input wire [`INSTR_SIZE : 0] dmem_r_data,
    output wire [`INSTR_SIZE : 0] dmem_w_data,
    input wire dmem_ready,
    //halt
    output wire halt
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
        .clk                    (clk),
        .reset                  (reset),
        .mem_rd_addr            (imem_rd_addr),
        .mem_rd_enable          (imem_rd_enable),
        .mem_rd_data            (imem_rd_data),
        .mem_rd_ready           (imem_rd_ready),
        .instr                  (instr_IF_ID),
        .PC                     (PC_IF_ID),
        .exception              (exception_IF_ID),
        .exception_valid        (exception_valid_IF_ID),
        .pipeline_valid         (pipeline_valid_IF_ID),
        .flush                  (flush_IF),
        .flush_addr             (flush_addr_IF),
        .stall                  (stall_IF)
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
        .clk                (clk),
        .reset              (reset),
        .PC_in              (PC_IF_ID),
        .instr_in           (instr_IF_ID),
        .exception_in       (exception_IF_ID),
        .exception_in_valid (exception_valid_IF_ID),
        .pipeline_in_valid  (pipeline_valid_IF_ID),
        .PC_out             (PC_ID_EXE),
`ifdef SIMULATE 
        .instr_out          (instr_ID_EXE),
`endif
        .exception_out      (exception_ID_EXE),
        .exception_out_valid(exception_valid_ID_EXE),
        .pipeline_out_valid (pipeline_valid_ID_EXE),
        .opcode             (opcode_ID_EXE),
        .funct              (funct_ID_EXE),
        .variant            (variant_ID_EXE),
        .op1                (op1_ID_EXE),
        .op2                (op2_ID_EXE),
        .rd_addr            (rd_addr_ID_EXE),
        .offset             (offset_ID_EXE),
        .nop_instr          (nop_instr_ID_EXE),
        .rs1_addr           (rs1_addr_ID_RF),
        .rs1_data           (rs1_data_ID_RF),
        .rs2_addr           (rs2_addr_ID_RF),
        .rs2_data           (rs2_data_ID_RF),
        .stall              (stall_ID),
        .flush              (flush_ID)
    );

    wire [`REG_ADDR_SIZE : 0] wr_addr_WB_RF;
    wire [`REG_DATA_SIZE : 0] wr_data_WB_RF;
    wire wr_enable_WB_RF;

    regfile regfile(
        .clk        (clk),
        .reset      (reset),
        .rd_addr_1  (rs1_addr_ID_RF),
        .rd_data_1  (rs1_data_ID_RF),
        .rd_addr_2  (rs2_addr_ID_RF),
        .rd_data_2  (rs2_data_ID_RF),
        .wr_addr    (wr_addr_WB_RF),
        .wr_data    (wr_data_WB_RF),
        .wr_enable  (wr_enable_WB_RF)
    );

    wire [`ADDR_SIZE : 0] PC_EXE_MEM;
    wire [`INSTR_SIZE : 0] instr_EXE_MEM;
    wire nop_instr_EXE_MEM;
    wire [4:0] opcode_EXE_MEM;
    wire [2:0] funct_EXE_MEM;
    wire [`EX_WIDTH : 0] exception_EXE_MEM;
    wire exception_valid_EXE_MEM;
    wire [`REG_DATA_SIZE : 0] result_EXE_MEM;
    wire [`ADDR_SIZE : 0] addr_EXE_MEM;
    wire flush_out_EXE;
    wire [`ADDR_SIZE : 0] flush_addr_out_EXE;
    wire [`REG_ADDR_SIZE : 0] rd_addr_EXE_MEM;
    wire pipeline_valid_EXE_MEM;
    wire halt_EXE_MEM;
    wire stall_EXE;

    execute execute(
        .clk                (clk),
        .reset              (reset),
        .PC_in              (PC_ID_EXE),
`ifdef SIMULATE 
        .instr_in           (instr_ID_EXE),
`endif
        .exception_in       (exception_ID_EXE),
        .exception_in_valid (exception_valid_ID_EXE),
        .pipeline_in_valid  (pipeline_valid_ID_EXE),
        .opcode_in          (opcode_ID_EXE),
        .funct_in           (funct_ID_EXE),
        .variant            (variant_ID_EXE),
        .op1                (op1_ID_EXE),
        .op2                (op2_ID_EXE),
        .rd_addr_in         (rd_addr_ID_EXE),
        .offset             (offset_ID_EXE),
        .nop_instr_in       (nop_instr_ID_EXE),
`ifdef SIMULATE
        .PC_out             (PC_EXE_MEM),
        .instr_out          (instr_EXE_MEM),
`endif
        .opcode_out         (opcode_EXE_MEM),
        .funct_out          (funct_EXE_MEM),
        .nop_instr_out      (nop_instr_EXE_MEM),
        .exception_out      (exception_EXE_MEM),
        .exception_out_valid(exception_valid_EXE_MEM),
        .pipeline_out_valid (pipeline_valid_EXE_MEM),
        .result             (result_EXE_MEM),
        .addr               (addr_EXE_MEM),
        .rd_addr_out        (rd_addr_EXE_MEM),
        .flush_out          (flush_out_EXE),
        .flush_addr         (flush_addr_out_EXE),
        .halt               (halt_EXE_MEM),
        .stall              (stall_EXE)
    );

    wire stall_MEM_out;
    wire [`ADDR_SIZE : 0] PC_MEM_WB;
    wire [`INSTR_SIZE : 0] instr_MEM_WB;
    wire [4:0] opcode_MEM_WB;
    wire nop_instr_MEM_WB;
    wire [`REG_DATA_SIZE : 0] result_MEM_WB;
    wire [`REG_ADDR_SIZE : 0] rd_addr_MEM_WB;
    wire exception_valid_MEM_WB;
    wire [`EX_WIDTH : 0] exception_MEM_WB;
    wire pipeline_valid_MEM_WB;
    wire halt_MEM_WB;

    memory memory(
        .clk                (clk),
        .reset              (reset),
`ifdef SIMULATE
        .PC_in              (PC_EXE_MEM),
        .instr_in           (instr_EXE_MEM),
`endif
        .opcode_in          (opcode_EXE_MEM),
        .funct_in           (funct_EXE_MEM),
        .nop_instr_in       (nop_instr_EXE_MEM),
        .exception_in       (exception_EXE_MEM),
        .exception_in_valid (exception_valid_EXE_MEM),
        .pipeline_in_valid  (pipeline_valid_EXE_MEM),
        .result_in          (result_EXE_MEM),
        .addr               (addr_EXE_MEM),
        .rd_addr_in         (rd_addr_EXE_MEM),
        .halt_in            (halt_EXE_MEM),
`ifdef SIMULATE
        .PC_out             (PC_MEM_WB),
        .instr_out          (instr_MEM_WB),
`endif
        .opcode_out         (opcode_MEM_WB),
        .nop_instr_out      (nop_instr_MEM_WB),
        .result_out         (result_MEM_WB),
        .rd_addr_out        (rd_addr_MEM_WB),
        .exception_out_valid(exception_valid_MEM_WB),
        .exception_out      (exception_MEM_WB),
        .halt_out           (halt_MEM_WB),
        .pipeline_out_valid (pipeline_valid_MEM_WB),
        .mem_addr           (dmem_addr),
        .mem_wr_data        (dmem_w_data),
        .mem_wr_enable      (dmem_w_enable),
        .mem_wr_size        (dmem_w_size),
        .mem_rd_data        (dmem_r_data),
        .mem_rd_enable      (dmem_r_enable),
        .mem_rd_ready       (dmem_ready),
        .stall_out          (stall_MEM_out)
    );

    assign stall_IF = stall_MEM_out;
    assign stall_ID = stall_MEM_out;
    assign stall_EXE = stall_MEM_out;

    writeback writeback(
        .clk                (clk),
        .reset              (reset),
`ifdef SIMULATE
        .PC                 (PC_MEM_WB),
        .instr              (instr_MEM_WB),
`endif
        .opcode             (opcode_MEM_WB),
        .nop_instr          (nop_instr_MEM_WB),
        .result             (result_MEM_WB),
        .rd_addr            (rd_addr_MEM_WB),
        .exception_valid    (exception_valid_MEM_WB),
        .exception          (exception_MEM_WB),
        .halt_in            (halt_MEM_WB),
        .pipeline_valid     (pipeline_valid_MEM_WB),
        .halt_out           (halt),
        .wr_addr            (wr_addr_WB_RF),
        .wr_data            (wr_data_WB_RF),
        .wr_enable          (wr_enable_WB_RF)
    );

endmodule // minuteCore