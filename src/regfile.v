`ifdef __ICARUS__
    `ifndef INCLUDE_PARAMS
        `include "./src/def_params.v"
    `endif
`endif

module regfile(
    input wire clk,
    input wire reset,

    //Read port 1
    input wire [`REG_ADDR_SIZE : 0] rd_addr_1,
    // input wire rd_enable_1,
    output reg [`REG_DATA_SIZE : 0] rd_data_1,
    // output reg rd_data_valid_1,

    //Read port 2
    input wire [`REG_ADDR_SIZE : 0] rd_addr_2,
    // input wire rd_enable_2,
    output reg [`REG_DATA_SIZE : 0] rd_data_2,
    // output reg rd_data_valid_2,

    //Write port
    input wire [`REG_ADDR_SIZE : 0] wr_addr,
    input wire [`REG_DATA_SIZE : 0] wr_data,
    input wire wr_enable
);

    reg [`REG_DATA_SIZE : 0] mem [`REG_SIZE : 1];

    integer i;                 //iterator
    always@(posedge(clk)) begin
        if(reset) begin
            for (i = 1; i < 32 ; i++ ) begin
                mem [i] <= 0;
            end
            `ifdef SIMULATE
                $display("%0d\tREGFILE: Reset", $time);
            `endif
        end
        else if(wr_enable && wr_addr != 0) begin
            mem[wr_addr] <= wr_data;
        end
    end

    always@(negedge(clk)) begin
        rd_data_1 <= rd_addr_1 + 'h1000;
        rd_data_2 <= rd_addr_2 + 'h2000;
    end

endmodule // regfile