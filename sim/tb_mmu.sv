`timescale 1 ns / 100 ps
`define D_D 10ps
module tb_mmu();

logic dig_clk, axi_clk, rstn;
logic rd_req;

logic [31:0] rd_addr;
axi_interface axi_intf();

assign axi_intf.m_axi_aclk = axi_clk;
assign axi_intf.m_axi_aresetn = rstn;

initial begin

    dig_clk = 1'b0;
    forever #1 dig_clk = ~dig_clk;

end

initial begin

    axi_clk = 1'b0;
    forever #0.4 axi_clk = ~axi_clk;

end


initial begin
    $dumpfile("mmu_tb.vcd"); // Name of the signal dump file
    $dumpvars(0, tb_mmu); // Signals to dump
    
    rstn = 1'b0;
    #5 rstn = 1'b1;

    #10000 $finish;

end

always @(posedge dig_clk, negedge rstn) begin
	if(!rstn) begin
		rd_req <= 1'b0;
		rd_addr <= 32'd0;
	end else begin
		if(((rd_addr[3:0] == 4'd10) | (rd_addr[3:0] == 4'd11)| (rd_addr[3:0] == 4'd12)| (rd_addr[3:0] == 4'd13)| (rd_addr[3:0] == 4'd14)) & (rd_addr < 2000) ) begin
			rd_req <= #(`D_D) 1'b1;
		end else if(rd_req == 1'b1)
			rd_req <= #(`D_D) 1'b0;

		rd_addr <= #(`D_D) rd_addr+1;
		end
end


mmu_top inst_mmu_top(
    .mmu_clk(dig_clk),
    .i_rstn(rstn),
    .rd_addr(rd_addr),
	.rd_req_reg(5'd0),
	.rd_valid_reg(),
	.rd_valid_func3(),
    .rd_data(),
    .rd_valid(),
    .rd_req(rd_req),
	.rd_req_func3(3'd0),

	.wr_addr(),
	.wr_done(),
	.wr_req(1'b0),
	.wr_req_reg(5'd0),
	.wr_done_reg(),
	.wr_data('d0),
	.m_axi_intf(axi_intf)
);


endmodule