`ifdef __ICARUS__
    `ifndef INCLUDE_PARAMS
        `include "./src/def_params.v"
    `endif
`endif
`ifdef MODEL_TECH
    `ifndef INCLUDE_PARAMS
        `include "def_params.v"
    `endif
`endif
`define DISPLAY(A) `ifdef SIMULATE $display("%0d\tCSR_EXCEPT: ",$time,A); `endif

module csr_except(
    input wire clk,
    input wire [`ADDR_SIZE : 0] PC,
    input wire [`INSTR_SIZE : 0] instr,
    input wire exception_valid,
    input wire [`EX_WIDTH : 0] exception,
    input wire [`REG_DATA_SIZE : 0] wr_data,

    output wire [`REG_ADDR_SIZE : 0] rd_addr,
    output reg [`REG_DATA_SIZE : 0] rd_data,
    output wire rd_enable,
    output wire flush,
    output wire [`ADDR_SIZE : 0] flush_addr
);

    wire [4:0] opcode = instr[6:2];
    wire [2:0] funct = instr[14:12];
    wire [11:0] csr_addr = instr[31:20];
    wire [`REG_ADDR_SIZE : 0] rs1 = instr[19:15];
    assign rd_addr = instr[11:7];
    reg valid = 0;
    reg [31:0] tmp; 

    reg [31:0] csr_misa = 32'b01000000_00000000_00000001_00000000; 
    //mvendorid = 0
    //marchid = 0
    //mimpid = 0
    //mhartid = 0
    //mstatus = 0
    reg [31:0] csr_mtvec = 0;
    reg [31:0] csr_mepc = 0;
    reg [31:0] csr_mcause = 0;
    reg [31:0] csr_mtval = 0;
    reg [31:0] csr_mscratch = 0;

    assign flush = exception_valid;
    assign flush_addr = (exception_valid)? csr_mtvec : 0;

    always@(*) begin
        if(!exception_valid) begin
            if(opcode == `OP_SYSTEM && funct == `F3_CSRRW) begin
                case(csr_addr)
                `CSR_MISA:      rd_data = csr_misa;
                `CSR_MTVEC:     rd_data = csr_mtvec;
                `CSR_MEPC:      rd_data = csr_mepc;
                `CSR_MCAUSE:    rd_data = csr_mcause;
                `CSR_MTVAL:     rd_data = csr_mtval;
                `CSR_MSCRATCH:  rd_data = csr_mscratch;
                default:        rd_data = 0;
                endcase
            end
        end
        // else begin
        //     case(exception)
        //         `EX_INSTR_ADDR_MISALIGN:    
        //         `EX_ILLEGAL_INSTR:
        //     endcase
        // end
    end

    always@(posedge(clk)) begin
        if(!exception_valid) begin
            if(opcode == `OP_SYSTEM && funct == `F3_CSRRW && rs1 != 0) begin
                case(csr_addr)
                // `CSR_MISA:      csr_misa <= wr_data;
                `CSR_MTVEC:     csr_mtvec <= wr_data & 2'b00;
                `CSR_MEPC:      csr_mepc <= wr_data & 2'b00;
                `CSR_MCAUSE:    csr_mcause <= wr_data;
                `CSR_MTVAL:     csr_mtval <= wr_data;
                `CSR_MSCRATCH:  csr_mscratch <= wr_data;
                endcase
            end
        end
        else begin
            csr_mcause <= exception;
            csr_mepc <= PC & 2'b0;
            case(exception)
                `EX_INSTR_ADDR_MISALIGN:    csr_mtval <= PC;
                `EX_ILLEGAL_INSTR:          csr_mtval <= instr;
                default:                    csr_mtval <= 0;
            endcase
        end
    end

`ifdef SIMULATE
    always@(posedge(clk)) begin
        if(opcode == `OP_SYSTEM) begin
            $display("%0d\t************CSR_EXCEPT Firing************", $time);
            case(funct)
                `F3_CSRRW: `DISPLAY("Op: SYSTEM\tFunct: CSRRW")
                default: `DISPLAY("Op: SYSTEM\tFunct: Unknown")
            endcase
            $display("%0d\tDECODE: PC: %h instr: %h rs1: r%d wr_data: %h rd_addr: r%d, rd_data: %h", $time, PC, instr, rs1, wr_data, rd_addr, rd_data);
            case(csr_addr)
                `CSR_MISA:      `DISPLAY("CSR: MISA")
                `CSR_MTVEC:     `DISPLAY("CSR: MTVEC")
                `CSR_MEPC:      `DISPLAY("CSR: MEPC")
                `CSR_MCAUSE:    `DISPLAY("CSR: MCAUSE")
                `CSR_MTVAL:     `DISPLAY("CSR: MTVAL")
                `CSR_MSCRATCH:  `DISPLAY("CSR: MSCRATCH")
                default: `DISPLAY("CSR: Unknown")
            endcase
        end
    end
`endif

endmodule