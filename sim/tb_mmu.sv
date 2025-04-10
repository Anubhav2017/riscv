`timescale 1 ns / 100 ps
`define D_D 10ps
module tb_mmu();

logic dig_clk, axi_clk, rstn;
logic rd_req;

logic [31:0] rd_addr;

initial begin

    dig_clk = 1'b0;
    forever #1 dig_clk = ~dig_clk;

end

initial begin

    axi_clk = 1'b0;
    forever #0.5 axi_clk = ~axi_clk;

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
		if((rd_addr[3:0] == 4'd10) & (rd_addr < 2000) ) begin
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
    .rd_data(),
    .rd_valid(),
    .rd_req(rd_req),

	.wr_addr(),
	.wr_done(),
	.wr_req(1'b0),
	.wr_data('d0),
	.m00_axi_aclk(axi_clk),
	.m00_axi_aresetn(rstn),
	.m00_axi_awid(),
	.m00_axi_awaddr(),
	.m00_axi_awlen(),
	.m00_axi_awsize(),
	.m00_axi_awburst(),
	.m00_axi_awlock(),
	.m00_axi_awcache(),
	.m00_axi_awprot(),
	.m00_axi_awqos(),
	.m00_axi_awuser(),
	.m00_axi_awvalid(),
	.m00_axi_awready('d0),
	.m00_axi_wdata(),
	.m00_axi_wstrb(),
	.m00_axi_wlast(),
	.m00_axi_wuser(),
	.m00_axi_wvalid(),
	.m00_axi_wready('d0),
	.m00_axi_bid('d0),
	.m00_axi_bresp('d0),
	.m00_axi_buser('d0),
	.m00_axi_bvalid('d0),
	.m00_axi_bready(),
	.m00_axi_arid(),
	.m00_axi_araddr(),
	.m00_axi_arlen(),
	.m00_axi_arsize(),
	.m00_axi_arburst(),
	.m00_axi_arlock(),
	.m00_axi_arcache(),
	.m00_axi_arprot(),
	.m00_axi_arqos(),
	.m00_axi_aruser(),
	.m00_axi_arvalid(),
	.m00_axi_arready('d0),
	.m00_axi_rid('d0),
	.m00_axi_rdata('d0),
	.m00_axi_rresp('d0),
	.m00_axi_rlast('d0),
	.m00_axi_ruser('d0),
	.m00_axi_rvalid('d0),
	.m00_axi_rready()
);


endmodule