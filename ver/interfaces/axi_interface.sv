interface axi_interface #(
    	parameter C_M_AXI_BURST_LEN	= 16,
		// Thread ID Width
		parameter integer C_M_AXI_ID_WIDTH	= 1,
		// Width of Address Bus
		parameter integer C_M_AXI_ADDR_WIDTH	= 32,
		// Width of Data Bus
		parameter integer C_M_AXI_DATA_WIDTH	= 32,
		// Width of User Write Address Bus
		parameter integer C_M_AXI_AWUSER_WIDTH	= 1,
		// Width of User Read Address Bus
		parameter integer C_M_AXI_ARUSER_WIDTH	= 1,
		// Width of User Write Data Bus
		parameter integer C_M_AXI_WUSER_WIDTH	= 1,
		// Width of User Read Data Bus
		parameter integer C_M_AXI_RUSER_WIDTH	= 1,
		// Width of User Response Bus
		parameter integer C_M_AXI_BUSER_WIDTH	= 1
)();

    logic m_axi_aclk;
	logic m_axi_aresetn;
	logic [C_M_AXI_ID_WIDTH-1 : 0] m_axi_awid;
	logic [C_M_AXI_ADDR_WIDTH-1 : 0] m_axi_awaddr;
	logic [7 : 0] m_axi_awlen;
	logic [2 : 0] m_axi_awsize;
	logic [1 : 0] m_axi_awburst;
	logic  m_axi_awlock;
	logic [3 : 0] m_axi_awcache;
	logic [2 : 0] m_axi_awprot;
	logic [3 : 0] m_axi_awqos;
	logic [C_M_AXI_AWUSER_WIDTH-1 : 0] m_axi_awuser;
	logic  m_axi_awvalid;
	logic m_axi_awready;
	logic [C_M_AXI_DATA_WIDTH-1 : 0] m_axi_wdata;
	logic [C_M_AXI_DATA_WIDTH/8-1 : 0] m_axi_wstrb;
	logic  m_axi_wlast;
	logic [C_M_AXI_WUSER_WIDTH-1 : 0] m_axi_wuser;
	logic  m_axi_wvalid;
	logic m_axi_wready;
	logic[C_M_AXI_ID_WIDTH-1 : 0] m_axi_bid;
	logic[1 : 0] m_axi_bresp;
	logic[C_M_AXI_BUSER_WIDTH-1 : 0] m_axi_buser;
	logic m_axi_bvalid;
	logic  m_axi_bready;
	logic [C_M_AXI_ID_WIDTH-1 : 0] m_axi_arid;
	logic [C_M_AXI_ADDR_WIDTH-1 : 0] m_axi_araddr;
	logic [7 : 0] m_axi_arlen;
	logic [2 : 0] m_axi_arsize;
	logic [1 : 0] m_axi_arburst;
	logic  m_axi_arlock;
	logic [3 : 0] m_axi_arcache;
	logic [2 : 0] m_axi_arprot;
	logic [3 : 0] m_axi_arqos;
	logic [C_M_AXI_ARUSER_WIDTH-1 : 0] m_axi_aruser;
	logic  m_axi_arvalid;
	logic m_axi_arready;
	logic[C_M_AXI_ID_WIDTH-1 : 0] m_axi_rid;
	logic[C_M_AXI_DATA_WIDTH-1 : 0] m_axi_rdata;
	logic[1 : 0] m_axi_rresp;
	logic m_axi_rlast;
	logic[C_M_AXI_RUSER_WIDTH-1 : 0] m_axi_ruser;
	logic m_axi_rvalid;
	logic  m_axi_rready;

modport master (
	input   m_axi_aclk,
	input   m_axi_aresetn,
	output   m_axi_awid,
	output   m_axi_awaddr,
	output   m_axi_awlen,
	output   m_axi_awsize,
	output   m_axi_awburst,
	output   m_axi_awlock,
	output   m_axi_awcache,
	output   m_axi_awprot,
	output   m_axi_awqos,
	output   m_axi_awuser,
	output   m_axi_awvalid,
	input   m_axi_awready,
	output   m_axi_wdata,
	output   m_axi_wstrb,
	output   m_axi_wlast,
	output   m_axi_wuser,
	output   m_axi_wvalid,
	input   m_axi_wready,
	input   m_axi_bid,
	input   m_axi_bresp,
	input   m_axi_buser,
	input   m_axi_bvalid,
	output   m_axi_bready,
	output   m_axi_arid,
	output   m_axi_araddr,
	output   m_axi_arlen,
	output   m_axi_arsize,
	output   m_axi_arburst,
	output   m_axi_arlock,
	output   m_axi_arcache,
	output   m_axi_arprot,
	output   m_axi_arqos,
	output   m_axi_aruser,
	output   m_axi_arvalid,
	input   m_axi_arready,
	input   m_axi_rid,
	input   m_axi_rdata,
	input   m_axi_rresp,
	input   m_axi_rlast,
	input   m_axi_ruser,
	input   m_axi_rvalid,
	output   m_axi_rready
);

modport slave(

	output   m_axi_aclk,
	output   m_axi_aresetn,


	input   m_axi_awid,
	input   m_axi_awaddr,
	input   m_axi_awlen,
	input   m_axi_awsize,
	input   m_axi_awburst,
	input   m_axi_awlock,
	input   m_axi_awcache,
	input   m_axi_awprot,
	input   m_axi_awqos,
	input   m_axi_awuser,
	input   m_axi_awvalid,


	output   m_axi_awready,


	input   m_axi_wdata,
	input   m_axi_wstrb,
	input   m_axi_wlast,
	input   m_axi_wuser,
	input   m_axi_wvalid,


	output   m_axi_wready,
	output   m_axi_bid,
	output   m_axi_bresp,
	output   m_axi_buser,
	output   m_axi_bvalid,


	input   m_axi_bready,
	input   m_axi_arid,
	input   m_axi_araddr,
	input   m_axi_arlen,
	input   m_axi_arsize,
	input   m_axi_arburst,
	input   m_axi_arlock,
	input   m_axi_arcache,
	input   m_axi_arprot,
	input   m_axi_arqos,
	input   m_axi_aruser,
	input   m_axi_arvalid,


	output   m_axi_arready,
	output   m_axi_rid,
	output   m_axi_rdata,
	output   m_axi_rresp,
	output   m_axi_rlast,
	output   m_axi_ruser,
	output   m_axi_rvalid,

	input   m_axi_rready

);
endinterface