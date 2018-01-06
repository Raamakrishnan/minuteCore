`define INSTR_SIZE      31
`define ADDR_SIZE       31

`define REG_DATA_SIZE   31
`define REG_ADDR_SIZE   4
`define REG_SIZE        31

///////////////////////// Op Codes ///////////////////////
`define OP_LUI          5'b01101
`define OP_AUIPC        5'b00101
`define OP_JAL          5'b11011
`define OP_JALR         5'b11001
`define OP_BRANCH       5'b11000
`define OP_LOAD         5'b00000
`define OP_STORE        5'b01000
`define OP_IMM_ARITH    5'b00100
`define	OP_ARITH        5'b01100
`define OP_FENCE        5'b00011
`define OP_CSR          5'b11100

///////////////////////// funct3 codes ///////////////////
`define F3_JALR         3'b000
`define F3_BEQ          3'b000
`define F3_BNE          3'b001
`define F3_BLT          3'b100
`define F3_BGE          3'b101
`define F3_BLTU         3'b110
`define F3_BGEU         3'b111
`define F3_LB           3'b000
`define F3_LH           3'b001
`define F3_LW           3'b010
`define F3_LBU          3'b100
`define F3_LHW          3'b101
`define F#_SB           3'b000
`define F3_SH           3'b001
`define F#_SW           3'b010
`define F3_ADD_SUB      3'b000
`define F3_SLT_SLTI     3'b010
`define F3_SLTU_SLTIU   3'b011
`define F3_XOR_XORI     3'b100
`define F3_OR_ORI       3'b110
`define F3_AND_ANDI     3'b111
`define F3_SLL_SLLI     3'b001
`define F3_SR_SRI       3'b101
`define F3_ECALL        3'b000
`define F3_EBREAK       3'b000
`define F3_CSRRW        3'b001
`define F3_CSRRS        3'b010
`define F3_CSRRC        3'b011
`define F3_CSRRWI       3'b101
`define F3_CSRRSI       3'b110
`define F3_CSRRCI       3'b111
`define F3_FENCE        3'b000
`define	F3_FENCEI       3'b001
