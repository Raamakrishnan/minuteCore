`ifdef __ICARUS__
    `ifndef INCLUDE_PARAMS
        `include "params.v"
    `endif
`endif

module fetch(
    input wire clk,
    input wire reset,

    //Interface with memory
    output reg [ `ADDR_SIZE : 0] mem_rd_addr,
    output reg mem_rd_enable,
    input wire [`INSTR_SIZE : 0] mem_rd_data,
    input wire mem_rd_ready,

    //Interface with pipeline
    output reg [`INSTR_SIZE : 0] instr,
    output reg [ `ADDR_SIZE : 0] PC,
    output reg pipeline_valid,

    input wire flush,
    input wire [`INSTR_SIZE : 0] flush_addr,

    input wire stall
);

    reg [`ADDR_SIZE : 0] next_PC;
    reg [`INSTR_SIZE : 0] rg_data_from_mem;
    reg mem_valid;

    always@(flush or flush_addr or stall or PC or reset) begin
        if(reset)
            next_PC <= 0;
        else if(stall)
            next_PC <= PC;
        else if(flush)
            next_PC <= flush_addr;
        else
            next_PC <= PC + 'd4;
    end

    always@(mem_rd_enable or mem_rd_ready or reset or next_PC) begin
        if(reset) begin
            mem_valid <= 0;
        end
        else if(!mem_rd_enable) begin
            mem_rd_addr <= next_PC;
            mem_rd_enable <= 1;
        end
        else if(mem_rd_enable && mem_rd_ready) begin
            rg_data_from_mem <= mem_rd_data;
            mem_valid <= 1;
        end
    end

    always@(posedge(clk)) begin
        if(reset) begin
            PC <= 0;
            pipeline_valid <= 0;
            mem_rd_enable <= 0;
        end
        else if(mem_valid) begin
            PC <= next_PC;
            instr <= rg_data_from_mem;
            pipeline_valid <= 1;
            mem_rd_enable <= 0;
        end
    end

`ifdef SIMULATE
    initial $monitor("%0d\tFETCH: clk: %b reset: %b mem_rd_enable: %b mem_rd_ready: %b PC: %h nextPC: %h instr: %h", $time, clk, reset, mem_rd_enable, mem_rd_ready, PC, next_PC, instr);
`endif

endmodule