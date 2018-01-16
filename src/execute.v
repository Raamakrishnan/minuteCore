`ifdef __ICARUS__
    `ifndef INCLUDE_PARAMS
        `include "./src/def_params.v"
    `endif
`endif

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
    input wire [2:0] funct,
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
    output reg opcode_out,
    output reg nop_instr_out,
    output reg [`EX_WIDTH : 0] exception_out,
    output reg exception_out_valid,
    output reg pipeline_out_valid,
    output reg result,
    output reg rd_addr_out,
    output reg flush_out,
    output reg flush_addr,

    input wire stall,
    input wire flush_in
);

    always @(*) begin
        if(pipeline_in_valid) begin
            exception_out = exception_in;
            exception_out_valid = exception_in_valid;
            flush_out = 0;
            if(exception_in_valid == 0 && nop_instr_in == 0) begin
                if(opcode_in == `OP_IMM_ARITH || opcode_in == `OP_ARITH) begin
                    if(funct == `F3_ADD_SUB) begin
                        if(variant == 0)        //ADD
                            result = op1 + op2;
                        else                    //SUB
                            result = op1 - op2;
                    end
                    else if(funct == `F3_SLT_SLTI) begin
                        result = (op1 < op2);
                    end
                    else if(funct == `F3_SLTU_SLTIU) begin
                        result = (op1 < op2);
                    end
                    else if(funct == `F3_XOR_XORI) begin
                        result = (op1 ^ op2);
                    end
                    else if(funct == `F3_OR_ORI) begin
                        result = (op1 | op2);
                    end
                    else if(funct == `F3_AND_ANDI) begin
                        result = (op1 & op2);
                    end
                    else if(funct == `F3_SLL_SLLI) begin
                        result = op1 << op2[4:0];
                    end
                    else if(funct == `F3_SR_SRI) begin
                        if(variant == 0)        //SRL
                            result = op1 >> op2[4:0];
                        else
                            result = op1 >>> op2[4:0];
                    end
                end
                else if(opcode_in == `OP_JAL) begin
                    result = PC_in + 'd4;
                    flush_out = 1;
                    flush_addr = PC_in + op2;
                end
                else if(opcode_in == `OP_JALR) begin
                    result = PC_in + 'd4;
                    flush_out = 1;
                    flush_addr = (op1 + op2) & 1'b0;
                end
            end
        end
    end

    always @(posedge(clk)) begin
        if(reset || flush_in) begin
            pipeline_out_valid <= 0;
            `ifdef SIMULATE
                if(reset)
                    $display("%0d\tEXECUTE: Reset", $time);
                if(flush_in)
                    $display("%0d\tEXECUTE: Flush", $time);
            `endif
        end
        else if(stall) begin
            pipeline_out_valid <= pipeline_out_valid;
            opcode_out <= opcode_out;
            rd_addr_out <= rd_addr_in;
            `ifdef SIMULATE
                PC_out <= PC_out;
                instr_out <= instr_out;
                $display("%0d\tEXECUTE: Stall", $time);
            `endif
        end
        else if(pipeline_in_valid) begin
            pipeline_out_valid <= pipeline_in_valid;
            opcode_out <= opcode_out;
            rd_addr_out <= rd_addr_in;
            `ifdef SIMULATE
                PC_out <= PC_in;
                instr_out <= instr_in;
                $strobe("%0d\t************EXECUTE Firing************", $time);
                $strobe("%0d\tEXECUTE: PC: %h instr: %h", $time, PC_out, instr_out);
            `endif
        end
    end

endmodule // execute