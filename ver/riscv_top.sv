module riscv_top(

    input logic i_clk,
    input logic i_rstn

);

wire [31:0] instruction;
logic [31:0] instruction_reg;
logic [31:0] pc, new_pc;
logic update_pc;

wire [31:0] regbank [32];

instruction_fetch u_if(
    .i_clk(i_clk),
    .i_rstn(i_rstn),
    .instruction(instruction),
    .pc(pc),
    .new_pc(new_pc),
    .update_pc(update_pc)
);

always @(posedge i_clk, negedge i_rstn) begin

    if(!i_rstn)
        instruction_reg <= 32'd0;
    else
        instruction_reg <= instruction;

end

wire [5:0] read_addr1, read_addr2, wraddr;
wire [31:0] read_data1, read_data2, wrdata;
wire wr_enable;


logic [37:0] wb_reg;

data_mem u_data_mem(
    .wr(wr_enable),
    .i_clk(i_clk), 
    .i_rstn(i_rstn),
    .rdaddr1(read_addr1), 
    .rdaddr2(read_addr2), 
    .wraddr(wraddr),
    .wrdata(wrdata),
    .rdata1(read_data1), 
    .rdata2(read_data2)
);

instruction_decode u_id(
    .i_clk(i_clk),
    .i_rstn(i_rstn),
    .instruction_reg(instruction_reg),
    .current_pc(pc),
    .read_addr1(read_addr1), 
    .read_addr2(read_addr2),
    .read_data1(read_data1), 
    .read_data2(read_data2),
    .wb_reg(wb_reg),
    .new_pc(new_pc),
    .update_pc(update_pc)
);


write_back u_write_back(
    .i_clk(i_clk),
    .i_rstn(i_rstn),
    .wb_reg(wb_reg),
    .wr_enable(wr_enable),
    .wr_address(wraddr),
    .wrdata(wrdata)
);


endmodule