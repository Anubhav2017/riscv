module write_back(
    input i_clk,
    input i_rstn,
    input logic [37:0] wb_reg,

    output logic wr_enable,
    output logic [4:0] wr_address,
    output logic [31:0] wrdata
);

wire [31:0] result;
wire [4:0] rd;

assign rd = wb_reg[36:32];
assign result = wb_reg[31:0];


always @(negedge i_clk, negedge i_rstn) begin

    if(!i_rstn) begin
        wr_enable <= 1'b0;
        wr_address <= 5'd0;
        wrdata <= 32'd0;
    end else begin
        if(wb_reg[37] == 1'b1) begin
            wr_enable <= 1'b1;
            wr_address <= rd;
            wrdata <= result;
        end else begin
            wr_enable <= 1'b0;
            wr_address <= 5'd0;
            wrdata <= 32'd0;
        end
    end

end





endmodule