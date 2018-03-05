`ifdef __ICARUS__
    `ifndef INCLUDE_PARAMS
        `include "./src/def_params.v"
    `endif
`endif

module hazard_detect(
    input wire [`REG_ADDR_SIZE : 0] rs1,
    input wire [`REG_ADDR_SIZE : 0] rs2,
    input wire [`REG_ADDR_SIZE : 0] rd_ID,
    input wire rd_ID_valid,
    input wire [`REG_ADDR_SIZE : 0] rd_EXE,
    input wire rd_EXE_valid,
    input wire [`REG_ADDR_SIZE : 0] rd_MEM,
    input wire rd_MEM_valid,
    input wire [`REG_ADDR_SIZE : 0] rd_WB,
    input wire rd_WB_valid,
    output reg stall
);

    wire rs1_stall = (rs1 != 0 && ((rd_EXE_valid && rd_EXE == rs1) || (rd_MEM_valid && rd_MEM == rs1)))? 1 : 0;
    wire rs2_stall = (rs2 != 0 && ((rd_EXE_valid && rd_EXE == rs2) || (rd_MEM_valid && rd_MEM == rs2)))? 1 : 0;
    
    always@(*) begin
        stall = 0;
        if(rs1_stall || rs2_stall)
            stall = 0;
    end

endmodule // hazard_detect