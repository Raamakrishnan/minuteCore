`ifdef __ICARUS__
    `ifndef INCLUDE_PARAMS
        `include "params.v"
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

    input wire stall,
    input wire flush
);

    reg rg_stall, rg_flush;

    always@(posedge(stall)) rg_stall <= 1;
    always@(posedge(flush)) begin
        rg_flush <= 1;
        $display("%0d\tDECODE: Flush", $time);
    end

    always @(posedge(clk)) begin
        if(reset || rg_flush) begin
            pipeline_out_valid <= 0;
        end
        else if(rg_stall) begin
            PC_out <= PC_out;
            instr_out <= instr_out;
            pipeline_out_valid <= pipeline_out_valid;
        end
        else if(pipeline_in_valid) begin
            PC_out <= PC_in;
            instr_out <= instr_in;
            pipeline_out_valid <= pipeline_in_valid;
        end
        rg_stall <= 0;
        rg_flush <= 0;
    end

`ifdef SIMULATE
    always@(posedge(clk)) begin
        if(pipeline_out_valid)
            $display("%0d\tDECODE: PC: %h instr: %h", $time, PC_out, instr_out);
    end
`endif


endmodule // decode