module riscv_top(

    input logic cpu_clk_aon,
    input logic rst,

    axi_interface.master m_axi_intf

);
/* verilator lint_off WIDTHTRUNC */
logic i_rstn;

assign i_rstn = ~rst;

wire [31:0] instruction;
logic [63:0] instruction_reg;
logic [31:0] pc, new_pc;
logic update_pc;

logic mmu_wr_req;
logic [2:0] mmu_wr_req_func3;
logic [31:0] mmu_wr_data;
logic [31:0] mmu_wr_addr;
logic mmu_wr_done;
logic [4:0] mmu_wr_done_reg;

logic mmu_rd_req;
logic [4:0] mmu_rd_req_reg;
logic [2:0] mmu_rd_req_func3;
logic [31:0] mmu_rd_addr;
logic [31:0] mmu_rd_data;
logic mmu_rd_valid;
logic [4:0] mmu_rd_valid_reg;
logic [2:0] mmu_rd_valid_func3;


logic cpu_stall;

logic cpu_clk_gated;

assign cpu_clk_gated = cpu_clk_aon & (~cpu_stall);

instruction_fetch u_if(
    .i_clk(cpu_clk_gated),
    .i_rstn(i_rstn),
    .instruction(instruction),
    .pc(pc),
    .new_pc(new_pc),
    .update_pc(update_pc)
);

always @(posedge cpu_clk_gated, negedge i_rstn) begin

    if(!i_rstn)
        instruction_reg <= #(`D_D) 64'd0;
    else
        instruction_reg <= #(`D_D) {pc,instruction};

end

wire [4:0] read_addr1, read_addr2, wraddr;
wire [31:0] read_data1, read_data2, wrdata;
wire wr_enable;


logic [37:0] wb_reg;

data_mem u_data_mem(
    .wr(wr_enable),
    .i_clk(cpu_clk_aon), 
    .i_rstn(i_rstn),
    .rdaddr1(read_addr1), 
    .rdaddr2(read_addr2), 
    .wraddr(wraddr),
    .wrdata(wrdata),
    .rdata1(read_data1), 
    .rdata2(read_data2)
);

instruction_decode u_id(
    .cpu_clk_aon(cpu_clk_aon),
    .i_rstn(i_rstn),
    .instruction_reg(instruction_reg),
    .read_addr1(read_addr1), 
    .read_addr2(read_addr2),
    .read_data1(read_data1), 
    .read_data2(read_data2),
    .wb_reg(wb_reg),
    .new_pc(new_pc),
    .update_pc(update_pc),
    .cpu_stall_final(cpu_stall),

    .mmu_wr_req(mmu_wr_req),
    .mmu_wr_req_func3(mmu_wr_req_func3),
    .mmu_wr_data(mmu_wr_data),
    .mmu_wr_addr(mmu_wr_addr),
    .mmu_wr_done(mmu_wr_done),

    .mmu_rd_req_reg(mmu_rd_req_reg),
    .mmu_rd_req_func3(mmu_rd_req_func3),
    .mmu_rd_req(mmu_rd_req),
    .mmu_rd_addr(mmu_rd_addr),
    .mmu_rd_data(mmu_rd_data),
    .mmu_rd_valid(mmu_rd_valid),
    .mmu_rd_valid_reg(mmu_rd_valid_reg),
    .mmu_rd_valid_func3(mmu_rd_valid_func3)
);


write_back u_write_back(
    .i_clk(cpu_clk_aon),
    .i_rstn(i_rstn),
    .wb_reg(wb_reg),
    .wr_enable(wr_enable),
    .wr_address(wraddr),
    .wrdata(wrdata)
);


mmu_top inst_mmu_top(

    .mmu_clk(cpu_clk_aon),
    .i_rstn(i_rstn),
    .m_axi_intf(m_axi_intf),
    
    .wr_req(mmu_wr_req),
    .wr_req_func3(mmu_wr_req_func3),
    .wr_data(mmu_wr_data),
	.wr_addr(mmu_wr_addr),
	.wr_done(mmu_wr_done),

    .rd_req(mmu_rd_req),
    .rd_addr(mmu_rd_addr),
    .rd_data(mmu_rd_data),
    .rd_valid(mmu_rd_valid),
    .rd_req_reg(mmu_rd_req_reg),
    .rd_req_func3(mmu_rd_req_func3),
    .rd_valid_reg(mmu_rd_valid_reg),
    .rd_valid_func3(mmu_rd_valid_func3)

);

`ifdef FPGA
ila_wb inst_ila (
	.clk(i_clk), // input wire clk
	.probe0(pc), // input wire [31:0]  probe0  
	.probe1(wraddr), // input wire [4:0]  probe1 
	.probe2(wr_enable) // input wire [0:0]  probe2
);
`endif

endmodule