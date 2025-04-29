module imem #(
    parameter CACHE_SIZE = 1024  //number of words/instructions
)(

    input [31:0] addr,
    output [31:0] data,

    input logic axi_clk,
    input logic mem_clk,
    input logic i_rstn,

    output logic instruction_valid,

    output logic axi_rd_rq,
    output logic [31:0] axi_rd_addr,

    input logic axi_rd_valid,
    input [31:0] axi_rd_valid_addr,
    input logic [CACHE_SIZE-1:0][31:0] axi_rd_data,
    output logic axi_rd_valid_ack

);

logic valid;
logic [31-$clog2(CACHE_SIZE*4):0] tag;
logic [CACHE_SIZE-1:0][31:0] instruction_cache ;

logic prev_instruction_valid;


assign instruction_valid = (addr[31:$clog2(CACHE_SIZE*4)] == tag) & valid;

assign data = instruction_cache[addr[$clog2(CACHE_SIZE*4)-1:2]];

logic mem_clk_sync1, mem_clk_sync2;

always @(posedge axi_clk) begin
    mem_clk_sync1 <=  #(`D_D) mem_clk;
    mem_clk_sync2 <=  #(`D_D) mem_clk_sync1;
end


assign axi_rd_rq = (~mem_clk_sync2) & mem_clk_sync1 & (prev_instruction_valid & ~instruction_valid);

assign axi_rd_addr = {addr[31:$clog2(CACHE_SIZE*4)],{$clog2(CACHE_SIZE*4){1'b0}}};

always @(posedge mem_clk, negedge i_rstn) begin

    if(!i_rstn) begin
        valid <= 1'b0;
        tag <= {32-$clog2(CACHE_SIZE*4){1'b0}};
        instruction_cache <= '{CACHE_SIZE{32'd0}};
        prev_instruction_valid <= 1'b1;
    end else begin

        prev_instruction_valid <= instruction_valid;

        if(axi_rd_valid_ack) begin
            axi_rd_valid_ack <= 1'b0;
        end else begin
            if(axi_rd_valid) begin
                axi_rd_valid_ack <= 1'b1;
                instruction_cache <= axi_rd_data;
                tag <= axi_rd_valid_addr[31:$clog2(CACHE_SIZE*4)];
                valid <= 1'b1; 
            end
        end
    end

end
//initial begin
//    $readmemb("../ver/instruction_mem.txt",instruction_mem);
//end


//assign data = instruction_mem[addr];




endmodule