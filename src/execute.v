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
`define DISPLAY(A) `ifdef SIMULATE $display("%0d\tEXECUTE: ",$time,A); `endif
module execute(
    input clk,
    input reset,

    //Interface pipeline in
    input wire [`ADDR_SIZE : 0] PC_in,
    `ifdef SIMULATE
    input wire [`INSTR_SIZE : 0] instr_in,
    `endif
    input wire [`EX_WIDTH : 0] exception_in,
    input wire exception_in_valid,
    input wire pipeline_in_valid,
    input wire [4:0] opcode_in,
    input wire [2:0] funct_in,
    input wire variant,
    input wire [`REG_DATA_SIZE : 0] op1,
    input wire [`REG_DATA_SIZE : 0] op2,
    input wire [`REG_ADDR_SIZE : 0] rd_addr_in,
    input wire [`REG_DATA_SIZE : 0] offset,
    input wire nop_instr_in,

    `ifdef SIMULATE
    output reg [`ADDR_SIZE : 0] PC_out,
    output reg [`INSTR_SIZE : 0] instr_out,
    `endif
    output reg [4:0] opcode_out,
    output reg [2:0] funct_out,
    output reg nop_instr_out,
    output reg [`EX_WIDTH : 0] exception_out,
    output reg exception_out_valid,
    output reg pipeline_out_valid,
    output reg [`REG_DATA_SIZE : 0] result,
    output reg [`ADDR_SIZE : 0] addr,
    output reg [`REG_ADDR_SIZE : 0] rd_addr_out,
    output reg flush_out,
    output reg [`ADDR_SIZE : 0] flush_addr,
    output reg halt,

    input wire stall,
    input wire flush_in
);

    reg exception_out_valid_rg, flush_out_rg, nop_instr_rg;
    reg [`EX_WIDTH : 0] exception_out_rg;
    reg [`REG_DATA_SIZE : 0] result_rg;
    reg [`ADDR_SIZE : 0] flush_addr_rg;
    reg [`ADDR_SIZE : 0] addr_rg;
    reg halt_rg;

    always @(*) begin
        flush_out = 0;        
        if(pipeline_in_valid) begin
            exception_out_rg = exception_in;
            exception_out_valid_rg = exception_in_valid;
            halt_rg = 0;
            if(exception_in_valid == 0 && nop_instr_in == 0) begin
                if(opcode_in == `OP_IMM_ARITH || opcode_in == `OP_ARITH) begin
                    if(funct_in == `F3_ADD_SUB && opcode_in == `OP_ARITH) begin
                        if(variant == 0)        //ADD
                            result_rg = $signed(op1) + $signed(op2);
                        else                    //SUB
                            result_rg = $signed(op1) - $signed(op2);
                    end
                    else if(opcode_in == `OP_IMM_ARITH) begin
                        result_rg = $signed(op1) + $signed(op2);
                    end
                    else if(funct_in == `F3_SLT_SLTI) begin
                        result_rg = (op1 < op2);
                    end
                    else if(funct_in == `F3_SLTU_SLTIU) begin
                        result_rg = (op1 < op2);
                    end
                    else if(funct_in == `F3_XOR_XORI) begin
                        result_rg = (op1 ^ op2);
                    end
                    else if(funct_in == `F3_OR_ORI) begin
                        result_rg = (op1 | op2);
                    end
                    else if(funct_in == `F3_AND_ANDI) begin
                        result_rg = (op1 & op2);
                    end
                    else if(funct_in == `F3_SLL_SLLI) begin
                        result_rg = op1 << op2[4:0];
                    end
                    else if(funct_in == `F3_SR_SRI) begin
                        if(variant == 0)        //SRL
                            result_rg = op1 >> op2[4:0];
                        else
                            result_rg = op1 >>> op2[4:0];
                    end
                end
                else if(opcode_in == `OP_LUI) begin
                    result_rg = op2;
                end
                else if(opcode_in == `OP_AUIPC) begin
                    result_rg = (PC_in + op2) & 12'b0;
                end
                else if(opcode_in == `OP_JAL) begin
                    result_rg = PC_in + 'd4;
                    flush_out = 1;
                    flush_addr = PC_in + op2;
                    halt_rg = (op2 == 0)? 1:0;
                end
                else if(opcode_in == `OP_JALR) begin
                    result_rg = PC_in + 'd4;
                    flush_out = 1;
                    flush_addr = (op1 + op2) & 1'b0;
                end
                else if(opcode_in == `OP_BRANCH) begin
                    flush_addr = PC_in + offset;
                    case (funct_in)
                        `F3_BEQ:  flush_out = (op1 == op2);
                        `F3_BNE:  flush_out = (op1 != op2);
                        `F3_BLTU:  flush_out = (op1 < op2);
                        `F3_BLT: flush_out = ($signed(op1) < $signed(op2));
                        `F3_BGEU:  flush_out = (op1 >= op2);
                        `F3_BGE: flush_out = ($signed(op1) >= $signed(op2));
                        default:  flush_out = 0;
                    endcase
                end
                else if(opcode_in == `OP_LOAD) begin
                    addr_rg = op1 + op2;
                end
                else if(opcode_in == `OP_STORE) begin
                    result_rg = op2;
                    addr_rg = op1 + offset;
                end
            end
        end
    end

    always @(posedge(clk)) begin
        if(reset || flush_in) begin
            pipeline_out_valid <= 0;
            halt <= 0;
            `ifdef SIMULATE
                if(reset)
                    $display("%0d\tEXECUTE: Reset", $time);
                if(flush_in)
                    $display("%0d\tEXECUTE: Flush", $time);
            `endif
        end
        else if(stall) begin
            pipeline_out_valid <= pipeline_out_valid;
            `ifdef SIMULATE
                PC_out <= PC_out;
                instr_out <= instr_out;
                $display("%0d\tEXECUTE: Stall", $time);
            `endif
        end
        else if(pipeline_in_valid) begin
            advancePipeline;
            `ifdef SIMULATE
                PC_out <= PC_in;
                instr_out <= instr_in;
                printDebug;
            `endif
        end
    end

    task advancePipeline;
        begin
            pipeline_out_valid <= pipeline_in_valid;
            opcode_out <= opcode_in;
            rd_addr_out <= rd_addr_in;
            funct_out <= funct_in;
            exception_out <= exception_out_rg;
            exception_out_valid <= exception_out_valid_rg;
            result <= result_rg;
            nop_instr_out <= nop_instr_in;
            addr <= addr_rg;
            // flush_out <= flush_out_rg;
            // flush_addr <= flush_addr_rg;
            halt <= halt_rg;
        end
    endtask

`ifdef SIMULATE
    task printDebug;
    begin
        $strobe("%0d\t************EXECUTE Firing************", $time);
        case (opcode_in)
            `OP_ARITH: `DISPLAY("OP: Arith")
            `OP_IMM_ARITH:
                if(!nop_instr_in)
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
            default: `DISPLAY("OP: Unknown")
        endcase
        $strobe("%0d\tEXECUTE: PC: %h instr: %h result: %h addr: %h rd: r%d", $time, PC_out, instr_out, result, addr, rd_addr_out);
        $strobe("%0d\tEXECUTE: Exception: %d(valid %b) Halt: %b", $time, exception_out, exception_out_valid, halt);
        $strobe("%0d\tEXECUTE: Flush: %h(valid %b)", $time, flush_addr, flush_out);
    end
    endtask
`endif

endmodule // execute