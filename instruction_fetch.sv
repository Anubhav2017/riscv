module instruction_fetch(
    input i_clk,
    input i_rstn,

    output [31:0] instruction
);

logic [9:0] pc;
wire [9:0] next_pc;

assign next_pc = pc+4;


always @(posedge i_clk, negedge i_rstn) begin

    if(!i_rstn)
        pc <= 10'd0;
    else
        pc <= next_pc;    

end


imem inst_imem(
    .addr(pc),
    .data(instruction)
);






endmodule