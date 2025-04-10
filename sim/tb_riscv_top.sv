module tb_riscv_top();

logic clk, rst;


initial begin

    clk = 1'b0;

    forever #1 clk = ~clk;

end

initial begin
   $dumpfile("riscv_top.vcd"); // Name of the signal dump file
    $dumpvars(0, tb_riscv_top); // Signals to dump
    rst = 1'b1;
    #10 rst = 1'b0;

 

    #1000 $finish;

end


riscv_top inst_riscv(
    .i_clk(clk),
    .rst(rst)
);


endmodule