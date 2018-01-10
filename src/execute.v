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
    input wire [`EX_WIDTH : 0] excep_in,
    input wire pipeline_in_valid,
    input wire [4:0] opcode,
    input wire [2:0] funct,
    input wire variant,
    input wire [`REG_DATA_SIZE : 0] op1,
    input wire [`REG_DATA_SIZE : 0] op2,
    input wire [`REG_ADDR_SIZE : 0] rd_addr,
    input wire [`REG_DATA_SIZE : 0] offset,
    input wire nop_instr,

    `ifdef SIMULATE
    output reg [`ADDR_SIZE : 0] PC_out,
    output reg [`INSTR_SIZE : 0] instr_out,
    `endif
    output reg pipeline_out_valid,

    input wire stall,
    input wire flush
);

    always @(posedge(clk)) begin
        if(reset || flush) begin
            pipeline_out_valid <= 0;
            `ifdef SIMULATE
                if(reset)
                    $display("%0d\tEXECUTE: Reset", $time);
                if(flush)
                    $display("%0d\tEXECUTE: Flush", $time);
            `endif
        end
        else if(stall) begin
            pipeline_out_valid <= pipeline_out_valid;
            `ifdef SIMULATE
                PC_out <= PC_in;
                instr_out <= instr_in;
                $display("%0d\tEXECUTE: Stall", $time);
            `endif
        end
        else if(pipeline_in_valid) begin
            pipeline_out_valid <= pipeline_in_valid;
            `ifdef SIMULATE
                PC_out <= PC_in;
                instr_out <= instr_in;
                $strobe("%0d\t************EXECUTE Firing************", $time);
                $strobe("%0d\tEXECUTE: PC: %h instr: %h", $time, PC_out, instr_out);
            `endif
        end
    end

endmodule // execute