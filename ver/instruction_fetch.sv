module instruction_fetch #(
	parameter CACHE_SIZE = 128
)(
    input i_clk,
    input i_rstn,
    input [31:0] new_pc,
    input update_pc,


    output logic [31:0] pc,
    output [31:0] instruction,

    output instruction_valid,

	axi_interface.master m_axi_intf
);

logic [31:0] next_pc;

always_comb begin
    if(instruction_valid == 1'b0) 
        next_pc = pc;
    else begin
        if(update_pc ==1'b1)
            next_pc = new_pc;
        else
            next_pc = pc+4;
    end
end


always @(posedge i_clk, negedge i_rstn) begin

    if(!i_rstn)
        pc <= 32'd0;
    else
        pc <= next_pc;    

end

logic axi_rd_rq;
logic [31:0] axi_rd_addr;
logic [31:0] axi_rd_valid_addr;
logic axi_rd_valid;
logic [CACHE_SIZE-1:0][31:0] axi_rd_data;
logic axi_rd_valid_ack;

imem #(.CACHE_SIZE(CACHE_SIZE)) inst_imem(
    .addr(pc),
    .data(instruction),

    .axi_clk(m_axi_intf.m_axi_aclk),
    .mem_clk(i_clk),
    .i_rstn(i_rstn), 

    .instruction_valid(instruction_valid),

    .axi_rd_rq(axi_rd_rq),
    .axi_rd_addr(axi_rd_addr),

    .axi_rd_valid(axi_rd_valid),
    .axi_rd_valid_addr(axi_rd_valid_addr),
    .axi_rd_data(axi_rd_data),
    .axi_rd_valid_ack(axi_rd_valid_ack)
);




my_axi_master_sim_model # ( 
	.NUM_WORDS_IN_BLOCK(CACHE_SIZE)
) my_axi_master_inst (
    .axi_rd_rq(axi_rd_rq),
	.axi_rd_addr(axi_rd_addr),
    .axi_rd_data(axi_rd_data),
	.axi_rd_valid(axi_rd_valid),
	.axi_rd_valid_addr(axi_rd_valid_addr),
	.axi_rd_valid_ack(axi_rd_valid_ack),

    .axi_wr_rq(1'b0),
    .axi_wr_addr(32'd0),
    .axi_wr_data('d0),
	
	.M_AXI_ACLK(m_axi_intf.m_axi_aclk),
	.M_AXI_ARESETN(m_axi_intf.m_axi_aresetn),
	.M_AXI_AWID(m_axi_intf.m_axi_awid),
	.M_AXI_AWADDR(m_axi_intf.m_axi_awaddr),
	.M_AXI_AWLEN(m_axi_intf.m_axi_awlen),
	.M_AXI_AWSIZE(m_axi_intf.m_axi_awsize),
	.M_AXI_AWBURST(m_axi_intf.m_axi_awburst),
	.M_AXI_AWLOCK(m_axi_intf.m_axi_awlock),
	.M_AXI_AWCACHE(m_axi_intf.m_axi_awcache),
	.M_AXI_AWPROT(m_axi_intf.m_axi_awprot),
	.M_AXI_AWQOS(m_axi_intf.m_axi_awqos),
	.M_AXI_AWUSER(m_axi_intf.m_axi_awuser),
	.M_AXI_AWVALID(m_axi_intf.m_axi_awvalid),
	.M_AXI_AWREADY(m_axi_intf.m_axi_awready),
	.M_AXI_WDATA(m_axi_intf.m_axi_wdata),
	.M_AXI_WSTRB(m_axi_intf.m_axi_wstrb),
	.M_AXI_WLAST(m_axi_intf.m_axi_wlast),
	.M_AXI_WUSER(m_axi_intf.m_axi_wuser),
	.M_AXI_WVALID(m_axi_intf.m_axi_wvalid),
	.M_AXI_WREADY(m_axi_intf.m_axi_wready),
	.M_AXI_BID(m_axi_intf.m_axi_bid),
	.M_AXI_BRESP(m_axi_intf.m_axi_bresp),
	.M_AXI_BUSER(m_axi_intf.m_axi_buser),
	.M_AXI_BVALID(m_axi_intf.m_axi_bvalid),
	.M_AXI_BREADY(m_axi_intf.m_axi_bready),
	.M_AXI_ARID(m_axi_intf.m_axi_arid),
	.M_AXI_ARADDR(m_axi_intf.m_axi_araddr),
	.M_AXI_ARLEN(m_axi_intf.m_axi_arlen),
	.M_AXI_ARSIZE(m_axi_intf.m_axi_arsize),
	.M_AXI_ARBURST(m_axi_intf.m_axi_arburst),
	.M_AXI_ARLOCK(m_axi_intf.m_axi_arlock),
	.M_AXI_ARCACHE(m_axi_intf.m_axi_arcache),
	.M_AXI_ARPROT(m_axi_intf.m_axi_arprot),
	.M_AXI_ARQOS(m_axi_intf.m_axi_arqos),
	.M_AXI_ARUSER(m_axi_intf.m_axi_aruser),
	.M_AXI_ARVALID(m_axi_intf.m_axi_arvalid),
	.M_AXI_ARREADY(m_axi_intf.m_axi_arready),
	.M_AXI_RID(m_axi_intf.m_axi_rid),
	.M_AXI_RDATA(m_axi_intf.m_axi_rdata),
	.M_AXI_RRESP(m_axi_intf.m_axi_rresp),
	.M_AXI_RLAST(m_axi_intf.m_axi_rlast),
	.M_AXI_RUSER(m_axi_intf.m_axi_ruser),
	.M_AXI_RVALID(m_axi_intf.m_axi_rvalid),
	.M_AXI_RREADY(m_axi_intf.m_axi_rready)
);


endmodule