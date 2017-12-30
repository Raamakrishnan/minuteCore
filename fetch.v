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
    reg rg_flush;
    reg rg_stall;

    always@(posedge(flush)) begin
        rg_flush <= 1;
        $display("%0d\tFETCH: Flush - Addr: %h", $time, flush_addr);
    end
    always@(posedge(stall)) rg_stall <= 1;

    always@(mem_rd_enable or mem_rd_ready or reset or next_PC or rg_flush) begin
        if(reset || rg_flush) begin
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
            next_PC <= 0;
            pipeline_valid <= 0;
            mem_rd_enable <= 0;
        end
        else if(rg_flush) begin
            PC <= PC;
            next_PC <= flush_addr;
            pipeline_valid <= 0;
            mem_rd_enable <= 0;
        end
        else if(mem_valid) begin
            instr <= rg_data_from_mem;
            pipeline_valid <= 1;
            mem_rd_enable <= 0;
            if(rg_stall) begin
                PC <= PC;
                next_PC <= next_PC;
            end
            else begin
                PC <= next_PC;
                next_PC <= next_PC + 'd4;
            end
        end
        else begin
            pipeline_valid <= 0;
        end
        rg_flush <= 0;
        rg_stall <= 0;
    end

`ifdef SIMULATE
    always@(posedge(clk)) begin
        if(pipeline_valid)
            $display("%0d\tFETCH: PC: %h nextPC: %h instr: %h", $time, PC, next_PC, instr);
    end

`endif

endmodule