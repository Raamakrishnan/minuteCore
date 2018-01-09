`ifdef __ICARUS__
    `define SIMULATE
    `ifndef INCLUDE_PARAMS
        `include "./src/def_params.v"
    `endif
    `include "./src/fetch.v"
    `include "./src/decode.v"
    `include "./src/regfile.v"
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
    wire [`EX_WIDTH : 0] excep;
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
        .flush_addr     (faddr),
        .excep          (excep)
    );

    wire [`REG_ADDR_SIZE : 0] rs1_addr;
    wire rs1_enable;
    wire [`REG_DATA_SIZE : 0] rs1_data;
    wire [`REG_ADDR_SIZE : 0] rs2_addr;
    wire rs2_enable;
    wire [`REG_DATA_SIZE : 0] rs2_data;

    decode decode
    (
        .clk                (clk),
        .reset              (reset),
        .PC_in              (PC_f_d),
        .instr_in           (instr_f_d),
        .pipeline_in_valid  (pipe_valid),

        //Interface Regfile
        .rs1_addr(rs1_addr),
        .rs1_data(rs1_data),
        .rs2_addr(rs2_addr),
        .rs2_data(rs2_data),

        .stall              (stall),
        .flush              (flush)
    );

    regfile regfile
    (
        .clk        (clk),
        .reset      (reset),

        .rd_addr_1(rs1_addr),
        .rd_data_1(rs1_data),
        .rd_addr_2(rs2_addr),
        .rd_data_2(rs2_data)
    );

    always #(5) clk=~clk;

    initial begin
        $dumpfile("./bin/wave.vcd");
        $dumpvars(0, tb);
    end

    initial begin
        reset=1;    clk=1; strobe=0; stall=0; flush =0; faddr = 0;
        #10 reset = 0;
        // repeat(1) begin
        //     #40 stall = 1;
        //     #10 stall = 0;
        // end
        // #50 faddr = 'd4;
        // flush = 1;
        // #10 flush = 0;
        #100 $finish();
    end

    always@(posedge(en)) begin
        #5 data = addr + 'h8000; strobe = 1;
        #5 strobe = 0;
    end

    always@(posedge(clk)) $display("************************\n");

endmodule