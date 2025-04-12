`timescale 1 ns / 1 ps
`define D_D 10ps

module tb_riscv_top();

logic cpu_clk_aon,axi_clk, rst;


axi_interface axi_intf();

assign axi_intf.m_axi_aclk = axi_clk;
assign axi_intf.m_axi_aresetn = ~rst;


initial begin

    cpu_clk_aon = 1'b0;
    forever #1 cpu_clk_aon = ~cpu_clk_aon;

end


initial begin

    axi_clk = 1'b0;
    forever #0.5 axi_clk = ~axi_clk;

end


initial begin
   $dumpfile("riscv_top.vcd"); // Name of the signal dump file
    $dumpvars(0, tb_riscv_top); // Signals to dump
    rst = 1'b1;
    #10 rst = 1'b0;

 

    #10000 $finish;

end


riscv_top inst_riscv(
    .cpu_clk_aon(cpu_clk_aon),
    .m_axi_intf(axi_intf),
    .rst(rst)
);


endmodule