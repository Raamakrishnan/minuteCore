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
`define DISPLAY(A) `ifdef SIMULATE $display("%0d\tMEMORY: ",$time,A); `endif

module memory(
    input wire clk,
    input wire reset,

    //interface pipeline in
    input wire [`ADDR_SIZE : 0] PC_in,
    input wire [`INSTR_SIZE : 0] instr_in,
    input wire [4:0] opcode_in,
    input wire [2:0] funct_in,
    input wire nop_instr_in,
    input wire [`EX_WIDTH : 0] exception_in,
    input wire exception_in_valid,
    input wire pipeline_in_valid,
    input wire [`REG_DATA_SIZE : 0] result_in,
    input wire [`ADDR_SIZE : 0] addr,
    input wire [`REG_ADDR_SIZE : 0] rd_addr_in,
    input wire halt_in,

    //Interface pipeline out
    output reg [`ADDR_SIZE : 0] PC_out,
    output reg [`INSTR_SIZE : 0] instr_out,
    output reg [4:0] opcode_out,
    output reg [2:0] funct_out,
    output reg nop_instr_out,
    output reg [`REG_DATA_SIZE : 0] result_out,
    output reg [`REG_ADDR_SIZE : 0] rd_addr_out,
    output reg pipeline_out_valid,
    output reg [`EX_WIDTH : 0] exception_out,
    output reg exception_out_valid,
    output reg halt_out,

    //Interface dmem
    output reg [`ADDR_SIZE : 0] mem_addr,
    output reg [`INSTR_SIZE : 0 ] mem_wr_data,
    output reg mem_wr_enable,
    output reg [1:0] mem_wr_size,
    input wire [`INSTR_SIZE : 0 ] mem_rd_data,
    output reg mem_rd_enable,
    input wire mem_rd_ready,

    input wire flush,
    input wire stall_in,
    output reg stall_out
);

    reg [`EX_WIDTH : 0] exception_out_rg;
    reg exception_out_valid_rg;
    reg rg_wait;

    // reg loaded;

    always@(*) begin
        if(pipeline_in_valid) begin
            mem_rd_enable = 0;
            exception_out_valid_rg = 0;
            if(exception_in_valid) begin
                exception_out_valid_rg = exception_in_valid;
                exception_out_rg = exception_in;
            end
            else if(opcode_in == `OP_LOAD) begin
                mem_addr = addr;
                mem_rd_enable = 1;
            end
            else if(opcode_in == `OP_STORE) begin
                // mem_wr_enable = 1;
            end
            else begin

            end
        end
    end

    always@(mem_rd_enable, mem_rd_ready, rg_wait, reset) begin
        stall_out = 0;
        if(mem_rd_enable && !rg_wait)  stall_out = 1;
        else if(mem_rd_ready && rg_wait)  stall_out = 0;
    end

    always@(posedge(clk)) begin
        if(reset || flush) begin
            pipeline_out_valid <= 0;
            mem_wr_enable <= 0;
            mem_rd_enable <= 0;
            rg_wait <= 0;
            // loaded <= 0;
`ifdef SIMULATE
            if(reset) begin `DISPLAY("Reset") end
            if(flush) begin `DISPLAY("Flush") end
`endif
        end
        else if(stall_in) begin
            pipeline_out_valid <= pipeline_out_valid;
`ifdef SIMULATE
            `DISPLAY("Stall")
`endif
        end
        else if(pipeline_in_valid) begin
            mem_wr_enable <= 0;
            if(opcode_in == `OP_LOAD) begin
                if(mem_rd_enable && mem_rd_ready && rg_wait) begin
                    result_out <= adjustSize(mem_rd_data, funct_in);
                    rg_wait <= 0;
                    advancePipeline;
                end
                else begin
`ifdef SIMULATE
                    `DISPLAY("OP: Load")
                    `DISPLAY("Stalling for DMEM")
`endif
                    rg_wait <= 1;
                end
            end
            else if(opcode_in == `OP_STORE) begin
                mem_addr <= addr;
                mem_wr_data <= result_in;
                mem_wr_enable <= 1;
                mem_wr_size <= funct_in[1:0];
                result_out <= result_in;
                advancePipeline;
            end
            else begin
                result_out <= result_in;
                advancePipeline;
            end
        end
    end

    task advancePipeline;
    begin
        PC_out <= PC_in;
        instr_out <= instr_in;
        `ifdef SIMULATE 
        printDebug; 
        `endif
        opcode_out <= opcode_in;
        funct_out <= funct_in;
        pipeline_out_valid <= pipeline_in_valid;
        rd_addr_out <= rd_addr_in;
        nop_instr_out <= nop_instr_in;
        exception_out <= exception_out_rg;
        exception_out_valid <= exception_out_valid_rg;
        halt_out <= halt_in;
    end
    endtask

    function [31:0] adjustSize(input [31:0] data, input [2:0] width);
        case (width)
            3'b000: adjustSize = {{24{data[7]}}, data[7:0]};
            3'b001: adjustSize = {{16{data[15]}}, data[15:0]};
            3'b010: adjustSize = data;
            3'b100: adjustSize = {{24{3'b0}}, data[7:0]};
            3'b101: adjustSize = {{16{1'b0}}, data[15:0]};
        endcase
    endfunction

`ifdef SIMULATE
    task printDebug;
    begin
        $strobe("%0d\t************MEMORY Firing************", $time);
        if(nop_instr_in)
            `DISPLAY("OP: NOP")
        else begin
            case (opcode_in)
                `OP_LOAD:   `DISPLAY("OP: LOAD")
                `OP_STORE:  `DISPLAY("OP: STORE")
                default:    `DISPLAY("OP: Unkown")
            endcase
        end
        $strobe("%0d\tMEMORY: PC: %h instr: %h result: %h rd: r%d", $time, PC_out, instr_out, result_out, rd_addr_out);
        $strobe("%0d\tMEMORY: Exception: %d(valid %b)", $time, exception_out, exception_out_valid);
    end
    endtask
`endif

endmodule // memory