`ifdef __ICARUS__
    `define SIMULATE
    `ifndef INCLUDE_PARAMS
        `include "./src/def_params.v"
    `endif
    `include "./src/minuteCore.v"
    `include "./src/imem.v"
    `include "./src/dmem.v"
`endif

`ifndef OUT_DIR
    `define OUT_DIR "./bin"
`endif

module tb_minuteCore();
    reg clk, reset;

    always #(5) clk=~clk;

    wire [ `ADDR_SIZE : 0] imem_rd_addr;
    wire imem_rd_enable;
    wire [`INSTR_SIZE : 0] imem_rd_data;
    wire imem_rd_ready;
    wire [`ADDR_SIZE : 0] dmem_addr;
    wire dmem_r_enable;
    wire dmem_w_enable;
    wire [1:0] dmem_w_size;
    wire [`INSTR_SIZE : 0] dmem_r_data;
    wire [`INSTR_SIZE : 0] dmem_w_data;
    wire dmem_ready;
    reg finish;
    wire halt;

    minuteCore minuteCore(
        .clk            (clk),
        .reset          (reset),
        .imem_rd_addr   (imem_rd_addr),
        .imem_rd_enable (imem_rd_enable),
        .imem_rd_data   (imem_rd_data),
        // .imem_rd_ready  (imem_rd_ready),
        .dmem_addr      (dmem_addr),
        .dmem_r_enable  (dmem_r_enable),
        .dmem_w_enable  (dmem_w_enable),
        .dmem_w_size    (dmem_w_size),
        .dmem_r_data    (dmem_r_data),
        .dmem_w_data    (dmem_w_data),
        .dmem_ready     (dmem_ready),
        .halt           (halt)
    );

    imem imem(
        .clk            (clk),
        .reset          (reset),
        .addr           (imem_rd_addr),
        .enable         (imem_rd_enable),
        .data           (imem_rd_data)
        // .ready          (imem_rd_ready)
    );

    dmem dmem(
        .clk            (clk),
        .reset          (reset),
        .addr           (dmem_addr),
        .r_enable       (dmem_r_enable),
        .w_enable       (dmem_w_enable),
        .w_size         (dmem_w_size),
        .r_data         (dmem_r_data),
        .w_data         (dmem_w_data),
        .ready          (dmem_ready),
        .finish         (halt)
    );

    initial begin
        $dumpfile("`OUT_DIR/wave.vcd");
        $dumpvars(0, tb_minuteCore);
    end

    initial begin
        clk = 1; reset = 1;
        #10 reset = 0;
        #10000 $display("Overflow");
        $finish();
    end

    always@(posedge(halt))
        $finish();

`ifdef SIMULATE
    always@(clk) begin
        if(clk)
            $display("\n");
    end
`endif

endmodule // tb_minuteCore