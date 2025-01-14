module instruction_fetch(
    input i_clk,
    input i_rstn,
    input [31:0] new_pc,
    input update_pc,


    output logic [31:0] pc,
    output [31:0] instruction
);

logic [31:0] next_pc;

always_comb begin
    if(update_pc ==1'b1)
        next_pc = new_pc;
    else
        next_pc = pc+1;
end


always @(posedge i_clk, negedge i_rstn) begin

    if(!i_rstn)
        pc <= 32'd0;
    else
        pc <= next_pc;    

end


imem inst_imem(
    .addr(pc),
    .data(instruction)
);






endmodule