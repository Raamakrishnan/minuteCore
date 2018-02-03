`ifdef __ICARUS__
    `ifndef INCLUDE_PARAMS
        `include "./src/def_params.v"
    `endif
`endif

module dmem(
    input wire clk,
    input wire reset,
    input wire [`ADDR_SIZE : 0] addr,
    input wire r_enable,
    input wire w_enable,
    output reg [`INSTR_SIZE : 0] r_data,
    input wire [`INSTR_SIZE : 0] w_data,
    output reg ready
`ifdef SIMULATE
    ,input wire finish
`endif
);

    reg [`INSTR_SIZE : 0] mem [0 : 16];
    
    wire [`INSTR_SIZE : 0] q = mem[addr[`ADDR_SIZE : 2]];  

`ifdef SIMULATE
    initial begin
        $readmemh("./bin/dmem.hex", mem);
    end
`endif

    always@(posedge(clk)) begin
        ready <= 0;
        if(r_enable) begin
            r_data <= q;
            ready <= 1;
        end
        else if(w_enable) begin
            mem[addr[`ADDR_SIZE : 2]] <= w_data;
        end
        `ifdef SIMULATE
        printDebug;
        `endif
    end

`ifdef SIMULATE
    always@(posedge(finish)) begin
        $writememh("./bin/dmem_out.hex", mem);
    end

    task printDebug;
    begin
        if(r_enable) begin
            $strobe("%0d\tDMEM: Read - Addr: %h Data: %h", $time, addr, r_data);            
        end
        else if(w_enable) begin
            $strobe("%0d\tDMEM: Write - Addr: %h Data: %h", $time, addr, w_data);            
        end
    end
    endtask
`endif

endmodule // dmem