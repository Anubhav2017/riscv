module mmu_top
(

    input wr_req,
    input logic [31:0] wr_data,
	input logic [31:0] wr_addr,
	input logic [2:0] wr_req_func3,
	output logic wr_done,

    input rd_req,
    input logic [31:0] rd_addr,
    output logic [31:0] rd_data,
	input logic [4:0] rd_req_reg,
	input logic [2:0] rd_req_func3,
	output logic [4:0] rd_valid_reg,
	output logic [2:0] rd_valid_func3,
    output logic rd_valid,

    input logic mmu_clk,
    input logic i_rstn,

    //AXI PORTS
	axi_interface.master m_axi_intf
);
logic axi_id;

logic axi_rd_rq;
//logic axi_rd_rq_ack;
logic [31:0] axi_rd_addr;
logic [31:0] axi_rd_data;
logic axi_rd_valid;
logic [31:0] axi_rd_valid_addr;
logic axi_rd_valid_ack;

logic axi_wr_rq;
logic [31:0] axi_wr_data;
logic [31:0] axi_wr_addr;

direct_map_cache inst_direct_map_cache(
    .mmu_clk(mmu_clk),
	.axi_clk(m_axi_intf.m_axi_aclk),
    .i_rstn(i_rstn),
    .rd_req(rd_req),
	.rd_req_reg(rd_req_reg),
	.rd_req_func3(rd_req_func3),
    .rd_data(rd_data),
    .rd_valid(rd_valid),
	.rd_valid_reg(rd_valid_reg),
	.rd_valid_func3(rd_valid_func3),
	.rd_addr(rd_addr),

	.wr_data(wr_data),
    .wr_req(wr_req),
	.wr_req_func3(wr_req_func3),
	.wr_addr(wr_addr),
	.wr_done(wr_done),

	//AXI PORTS
    .axi_rd_rq(axi_rd_rq),
	.axi_rd_addr(axi_rd_addr),
    .axi_rd_data(axi_rd_data),
	.axi_rd_valid(axi_rd_valid),
	.axi_rd_valid_addr(axi_rd_valid_addr),
	//.axi_rd_rq_ack(axi_rd_rq_ack),
	.axi_rd_valid_ack(axi_rd_valid_ack),

    .axi_wr_rq(axi_wr_rq),
    .axi_wr_addr(axi_wr_addr),
    .axi_wr_data(axi_wr_data)

);




my_axi_master_sim_model # ( 
	.C_M_AXI_BURST_LEN(1)
) my_axi_master_inst (
    .axi_rd_rq(axi_rd_rq),
	.axi_rd_addr(axi_rd_addr),
    .axi_rd_data({axi_rd_data}),
	.axi_rd_valid(axi_rd_valid),
	.axi_rd_valid_addr(axi_rd_valid_addr),
	.axi_rd_valid_ack(axi_rd_valid_ack),

    .axi_wr_rq(axi_wr_rq),
    .axi_wr_addr(axi_wr_addr),
    .axi_wr_data({axi_wr_data}),
	
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