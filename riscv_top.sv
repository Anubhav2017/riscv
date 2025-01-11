module riscv_top(

    input logic i_clk,
    input logic i_rstn

);

wire [31:0] instruction;
logic [31:0] instruction_reg;

instruction_fetch inst_if(
    .i_clk(i_clk),
    .i_rstn(i_rstn),
    .instruction(instruction)
);

always @(posedge i_clk, negedge i_rstn) begin

    if(!i_rstn)
        instruction_reg <= 32'd0;
    else
        instruction_reg <= instruction;

end

endmodule