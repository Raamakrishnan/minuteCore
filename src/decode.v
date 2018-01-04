`ifdef __ICARUS__
    `ifndef INCLUDE_PARAMS
        `include "./src/def_params.v"
    `endif
`endif

module decode(
    input wire clk,
    input wire reset,

    //Interface pipeline in
    input wire [`ADDR_SIZE : 0] PC_in,
    input wire [`INSTR_SIZE : 0] instr_in,
    input wire pipeline_in_valid,

    //Interface pipeline out
    output reg [`ADDR_SIZE : 0] PC_out,
    output reg [`INSTR_SIZE : 0] instr_out,
    output reg pipeline_out_valid,
    output reg [`REG_DATA_SIZE : 0] op1,
    output reg [`REG_DATA_SIZE : 0] op2,

    //Interface RegFile
    //Readport 1
    output reg [`REG_ADDR_SIZE : 0] rs1_addr,
    input wire [`REG_DATA_SIZE : 0] rs1_data,
    //Readport 2
    output reg [`REG_ADDR_SIZE : 0] rs2_addr,
    input wire [`REG_DATA_SIZE : 0] rs2_data,

    input wire stall,
    input wire flush
);

    always@(*) begin
        rs1_addr = instr_in[4:0];
        rs2_addr = instr_in[4:0];
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
            instr_out <= instr_out;
            pipeline_out_valid <= pipeline_out_valid;
            `ifdef SIMULATE
                $display("%0d\tDECODE: Stall", $time);
            `endif
        end
        else if(pipeline_in_valid) begin
            PC_out <= PC_in;
            instr_out <= instr_in;
            op1 <= rs1_data;
            op2 <= rs2_data;
            pipeline_out_valid <= pipeline_in_valid;
            `ifdef SIMULATE
                $strobe("%0d\t************DECODE Firing************", $time);
                $strobe("%0d\tDECODE: PC: %h instr: %h op1: %h op2: %h", $time, PC_out, instr_out, op1, op2);
            `endif
        end
    end
endmodule // decode