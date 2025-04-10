module mmu_top #(

		parameter integer C_M00_AXI_BURST_LEN	= 16,
		// Thread ID Width
		parameter integer C_M00_AXI_ID_WIDTH	= 1,
		// Width of Address Bus
		parameter integer C_M00_AXI_ADDR_WIDTH	= 32,
		// Width of Data Bus
		parameter integer C_M00_AXI_DATA_WIDTH	= 32,
		// Width of User Write Address Bus
		parameter integer C_M00_AXI_AWUSER_WIDTH	= 1,
		// Width of User Read Address Bus
		parameter integer C_M00_AXI_ARUSER_WIDTH	= 1,
		// Width of User Write Data Bus
		parameter integer C_M00_AXI_WUSER_WIDTH	= 1,
		// Width of User Read Data Bus
		parameter integer C_M00_AXI_RUSER_WIDTH	= 1,
		// Width of User Response Bus
		parameter integer C_M00_AXI_BUSER_WIDTH	= 1
)(


    input wr_req,
    input logic [31:0] wr_data,
	input logic [31:0] wr_addr,
	output logic wr_done,

    input rd_req,
    input logic [31:0] rd_addr,
    output logic [31:0] rd_data,
    output logic rd_valid,

    input logic mmu_clk,
    input logic i_rstn,

    //AXI PORTS
	input wire  m00_axi_aclk,
	input wire  m00_axi_aresetn,
	output wire [C_M00_AXI_ID_WIDTH-1 : 0] m00_axi_awid,
	output wire [C_M00_AXI_ADDR_WIDTH-1 : 0] m00_axi_awaddr,
	output wire [7 : 0] m00_axi_awlen,
	output wire [2 : 0] m00_axi_awsize,
	output wire [1 : 0] m00_axi_awburst,
	output wire  m00_axi_awlock,
	output wire [3 : 0] m00_axi_awcache,
	output wire [2 : 0] m00_axi_awprot,
	output wire [3 : 0] m00_axi_awqos,
	output wire [C_M00_AXI_AWUSER_WIDTH-1 : 0] m00_axi_awuser,
	output wire  m00_axi_awvalid,
	input wire  m00_axi_awready,
	output wire [C_M00_AXI_DATA_WIDTH-1 : 0] m00_axi_wdata,
	output wire [C_M00_AXI_DATA_WIDTH/8-1 : 0] m00_axi_wstrb,
	output wire  m00_axi_wlast,
	output wire [C_M00_AXI_WUSER_WIDTH-1 : 0] m00_axi_wuser,
	output wire  m00_axi_wvalid,
	input wire  m00_axi_wready,
	input wire [C_M00_AXI_ID_WIDTH-1 : 0] m00_axi_bid,
	input wire [1 : 0] m00_axi_bresp,
	input wire [C_M00_AXI_BUSER_WIDTH-1 : 0] m00_axi_buser,
	input wire  m00_axi_bvalid,
	output wire  m00_axi_bready,
	output wire [C_M00_AXI_ID_WIDTH-1 : 0] m00_axi_arid,
	output wire [C_M00_AXI_ADDR_WIDTH-1 : 0] m00_axi_araddr,
	output wire [7 : 0] m00_axi_arlen,
	output wire [2 : 0] m00_axi_arsize,
	output wire [1 : 0] m00_axi_arburst,
	output wire  m00_axi_arlock,
	output wire [3 : 0] m00_axi_arcache,
	output wire [2 : 0] m00_axi_arprot,
	output wire [3 : 0] m00_axi_arqos,
	output wire [C_M00_AXI_ARUSER_WIDTH-1 : 0] m00_axi_aruser,
	output wire  m00_axi_arvalid,
	input wire  m00_axi_arready,
	input wire [C_M00_AXI_ID_WIDTH-1 : 0] m00_axi_rid,
	input wire [C_M00_AXI_DATA_WIDTH-1 : 0] m00_axi_rdata,
	input wire [1 : 0] m00_axi_rresp,
	input wire  m00_axi_rlast,
	input wire [C_M00_AXI_RUSER_WIDTH-1 : 0] m00_axi_ruser,
	input wire  m00_axi_rvalid,
	output wire  m00_axi_rready

);
logic axi_id;

logic axi_rd_rq;
logic axi_rd_rq_ack;
logic [31:0] axi_rd_addr;
logic [31:0] axi_rd_data;
logic axi_rd_valid;
logic axi_rd_valid_ack;

logic axi_wr_rq;
logic axi_wr_rq_ack;
logic [31:0] axi_wr_data;
logic [31:0] axi_wr_addr;
logic axi_wr_done;
logic axi_wr_done_ack;

direct_map_cache inst_direct_map_cache(
    .i_clk(mmu_clk),
    .i_rstn(i_rstn),
    .rd_req(rd_req),
    .rd_data(rd_data),
    .rd_valid(rd_valid),
	.rd_addr(rd_addr),

	.wr_data(wr_data),
    .wr_req(wr_req),
	.wr_addr(wr_addr),
	.wr_done(wr_done),

	//AXI PORTS
    .axi_rd_rq(axi_rd_rq),
	.axi_rd_addr(axi_rd_addr),
    .axi_rd_data(axi_rd_data),
	.axi_rd_valid(axi_rd_valid),
	.axi_rd_rq_ack(axi_rd_rq_ack),
	.axi_rd_valid_ack(axi_rd_valid_ack),

    .axi_wr_rq(axi_wr_rq),
    .axi_wr_addr(axi_wr_addr),
    .axi_wr_data(axi_wr_data),
    .axi_wr_done(axi_wr_done),
	.axi_wr_rq_ack(axi_wr_rq_ack),
	.axi_wr_done_ack(axi_wr_done_ack),



	.axi_id(axi_id)
);




my_axi_master_sim_model # ( 
	.C_M_AXI_BURST_LEN(1)
) my_axi_master_inst (
    .axi_rd_rq(axi_rd_rq),
	.axi_rd_addr(axi_rd_addr),
    .axi_rd_data({axi_rd_data}),
	.axi_rd_valid(axi_rd_valid),
	.axi_rd_rq_ack(axi_rd_rq_ack),
	.axi_rd_valid_ack(axi_rd_valid_ack),

    .axi_wr_rq(axi_wr_rq),
    .axi_wr_addr(axi_wr_addr),
    .axi_wr_data({axi_wr_data}),
    .axi_wr_done(axi_wr_done),
	.axi_wr_rq_ack(axi_wr_rq_ack),
	.axi_wr_done_ack(axi_wr_done_ack),
	
	.M_AXI_ACLK(m00_axi_aclk),
	.M_AXI_ARESETN(m00_axi_aresetn),
	.M_AXI_AWID(m00_axi_awid),
	.M_AXI_AWADDR(m00_axi_awaddr),
	.M_AXI_AWLEN(m00_axi_awlen),
	.M_AXI_AWSIZE(m00_axi_awsize),
	.M_AXI_AWBURST(m00_axi_awburst),
	.M_AXI_AWLOCK(m00_axi_awlock),
	.M_AXI_AWCACHE(m00_axi_awcache),
	.M_AXI_AWPROT(m00_axi_awprot),
	.M_AXI_AWQOS(m00_axi_awqos),
	.M_AXI_AWUSER(m00_axi_awuser),
	.M_AXI_AWVALID(m00_axi_awvalid),
	.M_AXI_AWREADY(m00_axi_awready),
	.M_AXI_WDATA(m00_axi_wdata),
	.M_AXI_WSTRB(m00_axi_wstrb),
	.M_AXI_WLAST(m00_axi_wlast),
	.M_AXI_WUSER(m00_axi_wuser),
	.M_AXI_WVALID(m00_axi_wvalid),
	.M_AXI_WREADY(m00_axi_wready),
	.M_AXI_BID(m00_axi_bid),
	.M_AXI_BRESP(m00_axi_bresp),
	.M_AXI_BUSER(m00_axi_buser),
	.M_AXI_BVALID(m00_axi_bvalid),
	.M_AXI_BREADY(m00_axi_bready),
	.M_AXI_ARID(m00_axi_arid),
	.M_AXI_ARADDR(m00_axi_araddr),
	.M_AXI_ARLEN(m00_axi_arlen),
	.M_AXI_ARSIZE(m00_axi_arsize),
	.M_AXI_ARBURST(m00_axi_arburst),
	.M_AXI_ARLOCK(m00_axi_arlock),
	.M_AXI_ARCACHE(m00_axi_arcache),
	.M_AXI_ARPROT(m00_axi_arprot),
	.M_AXI_ARQOS(m00_axi_arqos),
	.M_AXI_ARUSER(m00_axi_aruser),
	.M_AXI_ARVALID(m00_axi_arvalid),
	.M_AXI_ARREADY(m00_axi_arready),
	.M_AXI_RID(m00_axi_rid),
	.M_AXI_RDATA(m00_axi_rdata),
	.M_AXI_RRESP(m00_axi_rresp),
	.M_AXI_RLAST(m00_axi_rlast),
	.M_AXI_RUSER(m00_axi_ruser),
	.M_AXI_RVALID(m00_axi_rvalid),
	.M_AXI_RREADY(m00_axi_rready)
);




endmodule