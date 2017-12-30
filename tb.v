`ifdef __ICARUS__
    `define SIMULATE
    `ifndef INCLUDE_PARAMS
        `include "params.v"
    `endif
    `include "fetch.v"
    `include "decode.v"
`endif

module tb;
    reg clk;
    reg reset;
    wire [`ADDR_SIZE : 0] PC_f_d;
    wire [`INSTR_SIZE : 0] instr_f_d;
    wire pipe_valid;
    wire en;
    reg stall, flush;
    reg [`INSTR_SIZE : 0] faddr;
    wire [`ADDR_SIZE : 0] addr;
    reg [`INSTR_SIZE : 0] data;
    reg strobe;
    fetch fetch
    (
        .reset          (reset),
        .clk            (clk),
        .PC             (PC_f_d),
        .instr          (instr_f_d),
        .pipeline_valid (pipe_valid),
        .mem_rd_enable  (en),
        .mem_rd_addr    (addr),
        .mem_rd_ready   (strobe),
        .mem_rd_data    (data),
        .stall          (stall),
        .flush          (flush),
        .flush_addr     (faddr)
    );

    decode decode
    (
        .clk                (clk),
        .reset              (reset),
        .PC_in              (PC_f_d),
        .instr_in           (instr_f_d),
        .pipeline_in_valid  (pipe_valid),
        .stall              (stall),
        .flush              (flush)
    );
    always #(5) clk=~clk;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb);
    end

    initial begin
        reset=1;    clk=1; strobe=0; stall=0; flush =0; faddr = 0;
        #7 reset = 0;
        // repeat(1) begin
        //     #40 stall = 1;
        //     #2 stall = 0;
        // end
        #50 faddr = 'd4;
        flush = 1;
        #2 flush = 0;
        #50 $finish();
    end

    always@(posedge(en)) begin
        #5 data = addr + 'h8000; strobe = 1;
        #2 strobe = 0;
    end

    always@(posedge(clk)) $display("************************\n");

endmodule