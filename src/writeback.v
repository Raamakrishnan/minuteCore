`ifdef __ICARUS__
    `ifndef INCLUDE_PARAMS
        `include "./src/def_params.v"
    `endif
`endif
`define DISPLAY(A) `ifdef SIMULATE $display("%0d\tWRITEBACK: ",$time,A); `endif

module writeback(
    input wire clk,
    input wire reset,

    //interface pipeline in
    `ifdef SIMULATE
    input wire [`ADDR_SIZE : 0] PC,
    input wire [`INSTR_SIZE : 0] instr,
    `endif
    input wire [4:0] opcode,
    input wire nop_instr,
    input wire [`REG_DATA_SIZE : 0] result,
    input wire [`REG_ADDR_SIZE : 0] rd_addr,
    input wire exception_valid,
    input wire [`EX_WIDTH : 0] exception,
    input wire pipeline_valid,

    //RegFile interface
    output reg [`REG_ADDR_SIZE : 0] wr_addr,
    output reg [`REG_DATA_SIZE : 0] wr_data,
    output reg wr_enable
);

    always@(*) begin
        wr_enable = 0;
        if(pipeline_valid) begin
            if(exception_valid) begin
            end
            else begin
                if(!nop_instr) begin
                    if(opcode == `OP_IMM_ARITH || opcode == `OP_ARITH || opcode == `OP_LOAD 
                    || opcode == `OP_JAL || opcode == `OP_JALR || opcode == `OP_LUI || opcode == `OP_AUIPC) begin
                        wr_addr = rd_addr;
                        wr_data = result;
                        wr_enable = 1;
                    end
                end
            end
        end
    end

    always@(posedge(clk)) begin
        if(pipeline_valid) begin
`ifdef SIMULATE
            printDebug;
`endif
        end
    end

`ifdef SIMULATE
    task printDebug;
    begin
        $strobe("%0d\t************WRITEBACK Firing************", $time);
        case (opcode)
            `OP_ARITH: `DISPLAY("OP: Arith")
            `OP_IMM_ARITH:
                if(!nop_instr)
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
        $strobe("%0d\tWRITEBACK: PC: %h instr: %h result: %h rd: r%d", $time, PC, instr, result, rd_addr);
        $strobe("%0d\tWRITEBACK: Exception: %d(valid %b)", $time, exception, exception_valid);
        end
    endtask
`endif

endmodule // writeback