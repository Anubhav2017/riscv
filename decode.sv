module instruction_decode(

    input i_clk,
    input i_rstn,
    input [31:0] instruction_reg
);

wire [6:0] opcode;

assign opcode = instruction_reg[31:25];




endmodule