module data_mem(

    input wr,
    input i_clk, i_rstn,
    input [4:0] rdaddr1, rdaddr2, wraddr,
    input [31:0] wrdata,
    output [31:0] rdata1, rdata2

);



logic [31:0] regbank [32];

assign rdata1 = regbank[rdaddr1];
assign rdata2 = regbank[rdaddr2];
integer i;
always @(posedge i_clk, negedge i_rstn) begin
    if(!i_rstn) begin
        for(i=0;i<32;i++)
            regbank[i] <= i;
    end else begin
        if(wr) begin
            regbank[wraddr] <= wrdata;
        end

    end
end

endmodule