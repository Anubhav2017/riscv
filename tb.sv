module tb();

logic clk, rstn;


initial begin

    clk = 1'b0;

    forever #1 clk = ~clk;

end

initial begin
   $dumpfile("signals.vcd"); // Name of the signal dump file
    $dumpvars(0, tb); // Signals to dump
    rstn = 1'b0;
    #10 rstn = 1'b1;

 

    #1000 $finish;

end


riscv_top inst_riscv(
    .i_clk(clk),
    .i_rstn(rstn)
);


endmodule