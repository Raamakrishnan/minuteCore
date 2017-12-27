`ifdef __ICARUS__
    `ifndef INCLUDE_PARAMS
        `include "params.v"
    `endif
`endif
`include "fetch.v"

module tb_fetch;
reg clk;
reg reset;
wire [`ADDR_SIZE : 0] PC;
fetch fetch
(
  .reset(reset),
  .clk (clk),
  .PC(PC)
);

always #(5) clk=~clk;

initial begin
    $dumpfile("tb_fetch.vcd");
    $dumpvars(0, tb_fetch);
end

initial begin
    reset<=1'b1;    clk<=1'b0;
    #10 reset <= 0;
    #100 $finish();
end

initial $monitor("%0d\tclk: %b reset: %b PC: %h", $time, clk, reset, PC);

endmodule