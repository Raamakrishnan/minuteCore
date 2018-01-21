`ifdef __ICARUS__
    `define SIMULATE
    `ifndef INCLUDE_PARAMS
        `include "./src/def_params.v"
    `endif
    `include "./src/minuteCore.v"
    `include "./src/imem.v"
`endif

module tb_minuteCore();
    reg clk, reset;

    always #(5) clk=~clk;

    wire [ `ADDR_SIZE : 0] imem_rd_addr;
    wire imem_rd_enable;
    wire [`INSTR_SIZE : 0] imem_rd_data;
    wire imem_rd_ready;

    minuteCore minuteCore(
        .clk            (clk),
        .reset          (reset),
        .imem_rd_addr   (imem_rd_addr),
        .imem_rd_enable (imem_rd_enable),
        .imem_rd_data   (imem_rd_data),
        .imem_rd_ready  (imem_rd_ready)
    );

    imem imem(
        .clk            (clk),
        .reset          (reset),
        .addr           (imem_rd_addr),
        .enable         (imem_rd_enable),
        .data           (imem_rd_data),
        .ready          (imem_rd_ready)
    );

    initial begin
        $dumpfile("./bin/wave.vcd");
        $dumpvars(0, tb_minuteCore);
    end

    initial begin
        clk = 1; reset = 1;
        #10 reset = 0;
        #100 $finish();
    end

`ifdef SIMULATE
    always@(clk) begin
        if(clk)
            $display("\n");
    end
`endif

endmodule // tb_minuteCore