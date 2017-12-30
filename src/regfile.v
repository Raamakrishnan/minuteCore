`ifdef __ICARUS__
    `ifndef INCLUDE_PARAMS
        `include "./src/params.v"
    `endif
`endif

module regfile(
    input wire clk,
    input wire reset,

    //Read port 1
    input wire [`REG_ADDR_SIZE : 1] rd_addr_1,
    input wire rd_enable_1,
    output reg [`REG_DATA_SIZE : 1] rd_data_1,
    output reg rd_data_valid_1,

    //Read port 2
    input wire [`REG_ADDR_SIZE : 1] rd_addr_2,
    input wire rd_enable_2,
    output reg [`REG_DATA_SIZE : 1] rd_data_2,
    output reg rd_data_valid_2,

    //Write port
    input wire [`REG_ADDR_SIZE : 1] wr_addr,
    input wire [`REG_DATA_SIZE : 1] wr_data,
    input wire wr_enable
);

    reg [`REG_DATA_SIZE : 1] mem [`REG_SIZE : 1];

    reg [`REG_ADDR_SIZE : 1] i;                 //iterator
    always@(negedge(clk)) begin
        if(reset) begin
            for (i = 0; i < 32 ; i++ ) begin
                mem[i] <= 0;
            end
            rd_data_valid_1 <= 0;
            rd_data_valid_2 <= 0;
        end
        else begin
            if(rd_enable_1) begin
                rd_data_1 <= (rd_addr_1 != 0)? mem[rd_addr_1] : 0;
                rd_data_valid_1 <= 1;
            end
            if(rd_enable_2) begin
                rd_data_2 <= (rd_addr_2 != 0)? mem[rd_addr_2] : 0;
                rd_data_valid_2 <= 1;
            end
        end
    end

    always@(posedge(clk)) begin
        if(!reset && wr_enable && wr_addr != 0) begin
            mem[wr_addr] <= wr_data;
        end
    end

endmodule // regfile