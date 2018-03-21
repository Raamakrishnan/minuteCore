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
module fetch(
    input wire clk,
    input wire reset,

    //Interface with memory
    output wire [ `ADDR_SIZE : 0] mem_rd_addr,
    output wire mem_rd_enable,
    input wire [`INSTR_SIZE : 0] mem_rd_data,
    // input wire mem_rd_ready,

    //Interface with pipeline
    output wire [`INSTR_SIZE : 0] instr,
    output reg [ `ADDR_SIZE : 0] PC,
    output reg [`EX_WIDTH : 0] exception,
    output reg exception_valid,
    output reg pipeline_valid,

    input wire flush,
    input wire [`INSTR_SIZE : 0] flush_addr,

    input wire stall
);

    reg [`ADDR_SIZE : 0] next_PC;
    reg [`INSTR_SIZE : 0] rg_data_from_mem;
    reg [1:0] wait_rg;

    assign mem_rd_addr = next_PC;
    assign instr = mem_rd_data;
    assign mem_rd_enable = ~stall;
    // assign mem_rd_addr = next_PC;
    // always@(mem_rd_enable or mem_rd_ready or reset or next_PC or stall) begin
    //     if(reset) begin
    //         mem_valid <= 0;
    //     end
    //     else if(!mem_rd_enable) begin
    //         mem_rd_addr <= (stall)? mem_rd_addr : next_PC;
    //         mem_rd_enable <= 1;
    //         mem_valid <= 0;
    //     end
    //     else if(mem_rd_enable && mem_rd_ready) begin
    //         instr <= mem_rd_data;
    //         mem_valid <= 1;
    //     end
    // end

    always@(posedge(clk)) begin
        if(reset) begin
            PC <= 0;
            next_PC <= 0;
            pipeline_valid <= 0;
            wait_rg <= 1;
            exception_valid <= 0;
            `ifdef SIMULATE
                $display("%0d\tFETCH: Reset", $time);
            `endif
        end
        else if(flush) begin
            PC <= PC;
            //TODO: check for instruction address alignment
            next_PC <= flush_addr;
            pipeline_valid <= 0;
            exception_valid <= 0;
            wait_rg <= 1;
            `ifdef SIMULATE
                $display("%0d\tFETCH: Flush - Addr: %h", $time, flush_addr);
            `endif
        end
        else if(wait_rg == 'd1) begin
            wait_rg <= 'd2;
            // next_PC <= next_PC + 'd4;
        end
        else begin
            // instr <= mem_rd_data;
            pipeline_valid <= 1;
            if(stall) begin
                PC <= PC;
                next_PC <= next_PC;
                `ifdef SIMULATE
                    $display("%0d\tFETCH: Stall", $time);
                `endif
            end
            else begin
                if(next_PC[1:0] != 0) begin
                    exception <= `EX_INSTR_ADDR_MISALIGN;
                    exception_valid <= 1;
                end
                else begin
                    exception_valid <= 0;
                end
                // if(wait_rg == 'd2)
                //     wait_rg <= 0;
                // else begin
                    PC <= next_PC;
                    next_PC <= next_PC + 'd4;
                // end
                // instr <= mem_rd_data;
            end
            `ifdef SIMULATE
                $strobe("%0d\t**************FETCH Firing**************", $time);
                $strobe("%0d\tFETCH: PC: %h nextPC: %h instr: %h", $time, PC, next_PC, instr);
            `endif
        end
        // else begin
        //     pipeline_valid <= 0;
        // end
    end
endmodule