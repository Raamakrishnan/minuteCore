`ifdef __ICARUS__
    `define SIMULATE
    `ifndef INCLUDE_PARAMS
        `include "params.v"
    `endif
    `include "fetch.v"
`endif

module tb_fetch;
    reg clk;
    reg reset;
    wire [`ADDR_SIZE : 0] PC;
    wire [`ADDR_SIZE : 0] addr;
    wire en;
    reg [`INSTR_SIZE : 0] data;
    reg strobe;
    fetch fetch
        (
        .reset(reset),
        .clk (clk),
        .PC(PC),
        .mem_rd_enable(en),
        .mem_rd_addr(addr),
        .mem_rd_ready(strobe),
        .mem_rd_data(data)
        );

    always #(5) clk=~clk;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_fetch);
    end

    initial begin
        reset=1;    clk=0; strobe=0;
        #7 reset = 0;   
        // repeat(5) begin
        //     @(posedge(en)); data = 'h8000; strobe = 1;
        //     #2 strobe = 0;
        // end
        #50 $finish();
    end

    always@(posedge(en)) begin
        data = addr + 'h8000; strobe = 1;
        #2 strobe = 0;
    end

endmodule