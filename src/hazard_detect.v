`ifdef __ICARUS__
    `ifndef INCLUDE_PARAMS
        `include "./src/def_params.v"
    `endif
`endif

module hazard_detect(
    input wire [`REG_ADDR_SIZE : 0] rs1,
    input wire [`REG_ADDR_SIZE : 0] rs2,
    input wire [`REG_ADDR_SIZE : 0] rd_EXE,
    input wire [`REG_ADDR_SIZE : 0] rd_MEM,
    input wire [`REG_ADDR_SIZE : 0] rd_WB,
    output reg stall
);

    wire rs1_stall = (rd_EXE == rs1 || rd_MEM == rs1 || rd_WB == rs1)? 1 : 0;
    wire rs2_stall = (rd_EXE == rs2 || rd_MEM == rs2 || rd_WB == rs2)? 1 : 0;
    
    always@(*) begin
        stall = 0;
        if(rs1_stall || rs2_stall)
         stall = 0;
    end

endmodule // hazard_detect