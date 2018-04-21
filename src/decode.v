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
`define DISPLAY(A) `ifdef SIMULATE $display("%0d\tDECODE: ",$time,A); `endif
module decode(
    input wire clk,
    input wire reset,

    //Interface pipeline in
    input wire [`ADDR_SIZE : 0] PC_in,
    input wire [`INSTR_SIZE : 0] instr_in,
    input wire [`EX_WIDTH : 0] exception_in,
    input wire exception_in_valid,
    input wire pipeline_in_valid,

    //Interface pipeline out
    output reg [`ADDR_SIZE : 0] PC_out,
    output reg [`INSTR_SIZE : 0] instr_out,
    output reg [`EX_WIDTH : 0] exception_out,
    output reg exception_out_valid,
    output reg pipeline_out_valid,
    output reg [4:0] opcode,
    output reg [2:0] funct,
    output reg variant,
    output reg [`REG_DATA_SIZE : 0] op1,
    output reg [`REG_DATA_SIZE : 0] op2,
    output reg [`REG_ADDR_SIZE : 0] rd_addr,
    output reg [`REG_DATA_SIZE : 0] offset,
    output reg nop_instr,

    //Interface RegFile
    //Readport 1
    output wire [`REG_ADDR_SIZE : 0] rs1_addr,
    input wire [`REG_DATA_SIZE : 0] rs1_data,
    //Readport 2
    output wire [`REG_ADDR_SIZE : 0] rs2_addr,
    input wire [`REG_DATA_SIZE : 0] rs2_data,

    input wire stall,
    input wire insert_nop,
    input wire flush
);

    reg [`EX_WIDTH : 0] exception_out_rg;
    reg exception_out_valid_rg;
    // reg [4:0] opcode_rg;
    // reg [2:0] funct_rg;
    reg variant_rg;
    reg [`REG_DATA_SIZE : 0] op1_rg;
    reg [`REG_DATA_SIZE : 0] op2_rg;
    // reg [`REG_ADDR_SIZE : 0] rd_addr_rg;
    reg [`REG_DATA_SIZE : 0] offset_rg;
    reg nop_instr_rg;

    wire [4:0] op = instr_in[6:2];
    wire [4:0] rd = instr_in[11:7];
    wire [2:0] f3 = instr_in[14:12];
    wire [4:0] rs1 = instr_in[19:15];
    wire [4:0] rs2 = instr_in[24:20];
    wire [6:0] f7 = instr_in[31:25];
    wire [31:0] imm_I = signExtend12(instr_in[31:20]);
    wire [31:0] imm_S = signExtend12({instr_in[31:25], instr_in[11:7]});
    wire [31:0] imm_B = signExtend13({instr_in[31], instr_in[7], instr_in[30:25], instr_in[11:8], 1'b0});
    wire [31:0] imm_U = {instr_in[31:12], 12'b0};
    wire [31:0] imm_J = signExtend21({instr_in[31], instr_in[19:12], instr_in[20], instr_in[30:21], 1'b0});

    assign rs1_addr = rs1;
    assign rs2_addr = rs2;

    //Instruction Decoding and Operand Fetch
    //TODO: check for illegal instructions
    always@(*) begin
        if(pipeline_in_valid) begin
            nop_instr_rg = 0;
            // opcode_rg = op;
            exception_out_rg = exception_in;
            exception_out_valid_rg = exception_in_valid;
            if(exception_in_valid == 0) begin
                if(instr_in[1:0] != 2'b11) begin
                    exception_out_rg = `EX_ILLEGAL_INSTR;
                    exception_out_valid_rg = 1;
                    // `DISPLAY("Illegal Instruction Exception")
                end
                //Integer Computational Instructions
                else if(op == `OP_IMM_ARITH) begin
                    if(instr_in[31:12] != 0) begin
                        // rd_addr_rg = rd;
                        // rs1_addr = rs1;
                        op1_rg = rs1_data;
                        op2_rg = imm_I;
                        // funct_rg = f3;
                        // variant_rg = f7[5];
                        // `DISPLAY("Immediate Arith")
                    end
                    else begin
                        nop_instr_rg = 1;
                        // `DISPLAY("NOP")
                    end
                end
                else if(op == `OP_LUI || op == `OP_AUIPC) begin
                    // rd_addr_rg = rd;
                    op2_rg = imm_U;
                    // `DISPLAY("LUI or AUIPC")
                end
                else if(op == `OP_ARITH) begin
                    // rd_addr_rg = rd;
                    // rs1_addr = rs1;
                    // rs2_addr = rs2;
                    op1_rg = rs1_data;
                    op2_rg = rs2_data;
                    // funct_rg = f3;
                    // variant_rg = f7[5];
                    // `DISPLAY("Arith")
                end
                // Control transfer instructions
                else if(op == `OP_JAL) begin
                    // rd_addr_rg = rd;
                    op2_rg = imm_J;
                    // `DISPLAY("JAL")
                end
                else if(op == `OP_JALR && f3 == 0) begin
                    // rd_addr_rg = rd;
                    // rs1_addr = rs1;
                    op1_rg = rs1_data;
                    op2_rg = imm_I;
                    // `DISPLAY("JALR")
                end
                else if(op == `OP_BRANCH) begin
                    // rs1_addr = rs1;
                    op1_rg = rs1_data;
                    // rs2_addr = rs2;
                    op2_rg = rs2_data;
                    offset_rg = imm_B;
                    // funct_rg = f3;
                    // `DISPLAY("Branch")
                end
                // Load Store Instructions
                else if(op == `OP_LOAD) begin
                    // rd_addr_rg = rd;
                    // rs1_addr = rs1;
                    op1_rg = rs1_data;
                    op2_rg = imm_I;
                    // funct_rg = f3;
                    // `DISPLAY("Load")
                end
                else if(op == `OP_STORE) begin
                    // rs1_addr = rs1;
                    op1_rg = rs1_data;
                    // rs2_addr = rs2;
                    op2_rg = rs2_data;
                    offset_rg = imm_S;
                    // funct_rg = f3;
                    // `DISPLAY("Store")
                end
                else if(op == `OP_FENCE) begin
                    nop_instr_rg = 1;
                    // `DISPLAY("Fence")
                end
                else if(op == `OP_SYSTEM) begin
                    if (f3 == `F3_CSRRW) begin
                        op1_rg = rs1_data;
                    end
                    else begin
                        exception_out_rg = `EX_ILLEGAL_INSTR;
                        exception_out_valid_rg = 1;
                    end
                end
                else begin
                    exception_out_rg = `EX_ILLEGAL_INSTR;
                    exception_out_valid_rg = 1;
                    // `DISPLAY("Illegal Instruction Exception")
                end
            end
        end
    end

    always @(posedge(clk)) begin
        if(reset || flush) begin
            pipeline_out_valid <= 0;
            `ifdef SIMULATE
                if(reset)
                    $display("%0d\tDECODE: Reset", $time);
                if(flush)
                    $display("%0d\tDECODE: Flush", $time);
            `endif
        end
        else if(stall) begin
            PC_out <= PC_out;
            pipeline_out_valid <= pipeline_out_valid;
            instr_out <= instr_out;
            `ifdef SIMULATE
                $display("%0d\tDECODE: Stall", $time);
            `endif
        end
        else if(insert_nop) begin
            insertNop;
            `ifdef SIMULATE
                $display("%0d\tDECODE: Insert NOP", $time);
            `endif
        end
        else if(pipeline_in_valid) begin
            advancePipeline;
            `ifdef SIMULATE
                printDebug;
                // $strobe("%0d\t************DECODE Firing************", $time);
                // $strobe("%0d\tDECODE: PC: %h instr: %h op1: %h op2: %h offset: %h rd: r%d", $time, PC_out, instr_out, op1, op2, offset, rd_addr);
                // $strobe("%0d\tDECODE: Exception: %d(valid %b) NOP:%b", $time, exception_out, exception_out_valid, nop_instr);
            `endif
        end
    end

    task insertNop;
    begin
        PC_out <= PC_out;
        instr_out <= 32'h00000013;
        pipeline_out_valid <= 1;
        exception_out_valid <= 0;
        opcode <= `OP_IMM_ARITH;
        funct <= 0;
        variant <= 0;
        op1 <= 0;
        op2 <= 0;
        rd_addr <= 0;
        offset <= 0;
        nop_instr <= 1;
    end
    endtask

    task advancePipeline;
    begin
        PC_out <= PC_in;
        instr_out <= instr_in;        
        pipeline_out_valid <= pipeline_in_valid;
        exception_out <= exception_out_rg;
        exception_out_valid <= exception_out_valid_rg;
        opcode <= op;
        funct <= f3;
        variant <= instr_in[30];
        op1 <= op1_rg;
        op2 <= op2_rg;
        rd_addr <= rd;
        offset <= offset_rg;
        nop_instr <= nop_instr_rg;
    end
    endtask

`ifdef SIMULATE
    task printDebug;
    begin
        $strobe("%0d\t************DECODE Firing************", $time);
        case (op)
            `OP_ARITH: `DISPLAY("OP: Arith")
            `OP_IMM_ARITH:
                if(!nop_instr_rg)
                    `DISPLAY("OP: Imm Arith")
                else
                    `DISPLAY("OP: NOP")
            `OP_AUIPC: `DISPLAY("OP: AUIPC")
            `OP_LUI: `DISPLAY("OP: LUI")
            `OP_BRANCH: `DISPLAY("OP: Branch")
            `OP_FENCE: `DISPLAY("OP: Fence")
            `OP_JAL: `DISPLAY("OP: JAL")
            `OP_JALR: `DISPLAY("OP: JALR")
            `OP_LOAD: `DISPLAY("OP: LOAD")
            `OP_STORE: `DISPLAY("OP: Store")
            `OP_SYSTEM: `DISPLAY("OP: System")
            default: `DISPLAY("OP: Unknown")
        endcase
        $strobe("%0d\tDECODE: PC: %h instr: %h op1: %h op2: %h offset: %h rd: r%d", $time, PC_out, instr_out, op1, op2, offset, rd_addr);
        $strobe("%0d\tDECODE: Exception: %d(valid %b)", $time, exception_out, exception_out_valid);
        end
    endtask
`endif

    function [31:0] signExtend12(input [11:0] in);
        signExtend12 = {{20{in[11]}}, in};
    endfunction

    function [31:0] signExtend13(input [12:0] in);
        signExtend13 = {{19{in[12]}}, in};
    endfunction

    function [31:0] signExtend21(input [20:0] in);
        signExtend21 = {{11{in[20]}}, in};
    endfunction

endmodule // decode