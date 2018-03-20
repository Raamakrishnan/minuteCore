`ifdef __ICARUS__
    `ifndef INCLUDE_PARAMS
        `include "./src/def_params.v"
        `include "./src/sp_ram.v"
    `endif
`endif

module dmem(
    input wire clk,
    input wire reset,
    input wire [`ADDR_SIZE : 0] addr,
    input wire r_enable,
    input wire w_enable,
    input wire [1:0] w_size,
    output wire [`INSTR_SIZE : 0] r_data,
    input wire [`INSTR_SIZE : 0] w_data,
    output reg ready
`ifdef SIMULATE
    ,input wire finish
`endif
);

//     reg [`INSTR_SIZE : 0] mem [0 : 16];
    
//     wire [`INSTR_SIZE : 0] q = mem[addr[`ADDR_SIZE : 2]];  

// `ifdef SIMULATE
//     initial begin
//         $readmemh("./bin/dmem.hex", mem);
//     end
// `endif

//     always@(posedge(clk)) begin
//         ready <= 0;
//         if(r_enable) begin
//             r_data <= q;
//             ready <= 1;
//         end
//         else if(w_enable) begin
//             mem[addr[`ADDR_SIZE : 2]] <= w_data;
//         end
//         `ifdef SIMULATE
//         printDebug;
//         `endif
//     end

    wire [`ADDR_SIZE - 2 : 0] r_addr0, r_addr1, r_addr2, r_addr3;
    wire [7:0] w_data0, w_data1, w_data2, w_data3;
    wire w_enable0, w_enable1, w_enable2, w_enable3;
    wire [7:0] r_data0, r_data1, r_data2, r_data3;
    wire [`ADDR_SIZE : 2] pre_addr = addr[`ADDR_SIZE : 2];
    wire [`ADDR_SIZE : 2] next_addr = addr[`ADDR_SIZE : 2] + 1;
    wire [1:0] sel = addr[1:0];
    wire wb0, wb1, wb2, wb3;

sp_ram #(.INIT_FILE("dmem.0.txt"), .OUT_FILE("dmem.0.out.txt")) mem0(
    .clk(clk),
    .addr(r_addr0[5:0]),
    .data(w_data0),
    .we(w_enable0),
    .q(r_data0)
`ifdef SIMULATE
    ,.finish(finish)
`endif
);

sp_ram #(.INIT_FILE("dmem.1.txt"), .OUT_FILE("dmem.1.out.txt")) mem1(
    .clk(clk),
    .addr(r_addr1[5:0]),
    .data(w_data1),
    .we(w_enable1),
    .q(r_data1)
`ifdef SIMULATE
    ,.finish(finish)
`endif
);

sp_ram #(.INIT_FILE("dmem.2.txt"), .OUT_FILE("dmem.2.out.txt")) mem2(
    .clk(clk),
    .addr(r_addr2[5:0]),
    .data(w_data2),
    .we(w_enable2),
    .q(r_data2)
`ifdef SIMULATE
    ,.finish(finish)
`endif
);

sp_ram #(.INIT_FILE("dmem.3.txt"), .OUT_FILE("dmem.3.out.txt")) mem3(
    .clk(clk),
    .addr(r_addr3[5:0]),
    .data(w_data3),
    .we(w_enable3),
    .q(r_data3)
`ifdef SIMULATE
    ,.finish(finish)
`endif
);

    assign r_data = (sel == 'b00)? {r_data3, r_data2, r_data1, r_data0} :
                 ((sel == 'b01)? {r_data0, r_data3, r_data2, r_data1} :
                 ((sel == 'b10)? {r_data1, r_data0, r_data3, r_data2} :
                 {r_data2, r_data1, r_data0, r_data3}));

    assign r_addr0 = addr_mux(sel, pre_addr, next_addr, next_addr, next_addr);
    assign r_addr1 = addr_mux(sel, pre_addr, pre_addr, next_addr, next_addr);
    assign r_addr2 = addr_mux(sel, pre_addr, pre_addr, pre_addr, next_addr);
    assign r_addr3 = pre_addr;

    assign w_data0 = w_data_mux(sel, w_data[7:0], w_data[31:24], w_data[23:16], w_data[15:8]);
    assign w_data1 = w_data_mux(sel, w_data[15:8], w_data[7:0], w_data[31:24], w_data[23:16]);
    assign w_data2 = w_data_mux(sel, w_data[23:16], w_data[15:8], w_data[7:0], w_data[31:24]);
    assign w_data3 = w_data_mux(sel, w_data[31:24], w_data[23:16], w_data[15:8], w_data[7:0]);

    assign wb0 = w_enable;
    assign wb1 = (w_size == 'b01 || w_size == 'b10)? w_enable : 0;
    assign wb2 = (w_size == 'b10)? w_enable : 0;
    assign wb3 = (w_size == 'b10)? w_enable : 0;

    assign w_enable0 = w_enable_mux(sel, wb0, wb3, wb2, wb1);
    assign w_enable1 = w_enable_mux(sel, wb1, wb0, wb3, wb2);
    assign w_enable2 = w_enable_mux(sel, wb2, wb1, wb0, wb3);
    assign w_enable3 = w_enable_mux(sel, wb3, wb2, wb1, wb0);

    function [`ADDR_SIZE - 2 : 0] addr_mux(
        input [1:0] select, 
        input [`ADDR_SIZE : 2] in0, 
        input [`ADDR_SIZE : 2] in1,
        input [`ADDR_SIZE : 2] in2,
        input [`ADDR_SIZE : 2] in3
    );
    begin
        case (select)
            'b00:   addr_mux = in0;
            'b01:   addr_mux = in1;
            'b10:   addr_mux = in2;
            'b11:   addr_mux = in3;
        endcase
    end
    endfunction

    function [7:0] w_data_mux (
        input [1:0] select,
        input [7:0] in0,
        input [7:0] in1,
        input [7:0] in2,
        input [7:0] in3
    );
    begin
        case (select)
            'b00:   w_data_mux = in0;
            'b01:   w_data_mux = in1;
            'b10:   w_data_mux = in2;
            'b11:   w_data_mux = in3;
        endcase
    end
    endfunction

    function w_enable_mux (
        input [1:0] select,
        input in0,
        input in1,
        input in2,
        input in3
    );
    begin
        case (select)
            'b00: w_enable_mux = in0;
            'b01: w_enable_mux = in1;
            'b10: w_enable_mux = in2;
            'b11: w_enable_mux = in3;
        endcase
    end
    endfunction

    always@(posedge(clk)) begin
        ready <= 0;
        if(r_enable)
            ready <= 1;
    end

`ifdef SIMULATE
    // always@(posedge(finish)) begin
    //     $writememh("./bin/dmem_out.hex", mem);
    // end

    always@(posedge(clk))
    begin
        if(r_enable) begin
            $strobe("%0d\tDMEM: Read - Addr: %h Data: %h", $time, addr, r_data);
        end
        else if(w_enable) begin
            $strobe("%0d\tDMEM: Write - Addr: %h Data: %h", $time, addr, w_data);
        end
    end
`endif

endmodule // dmem