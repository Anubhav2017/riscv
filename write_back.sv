module write_back(
    input i_clk,
    input i_rstn,
    input logic [63:0] wb_reg,

    output logic wr_enable,
    output logic [4:0] wr_address,
    output logic [31:0] wrdata
);

wire [31:0] result, instruction;

assign instruction = wb_reg[63:32];
assign result = wb_reg[31:0];

wire [6:0] opcode;

assign opcode = instruction[6:0];

///R TYPE
wire [4:0] rs1, rs2,rd;
assign func3 = instruction[14:12];
assign func7 = instruction[31:25];
assign rs1 = instruction[19:15];
assign rs2 = instruction[24:20];
assign rd = instruction[11:7];

always @(negedge i_clk, negedge i_rstn) begin

    if(!i_rstn) begin
        wr_enable <= 1'b0;
        wr_address <= 5'd0;
        wrdata <= 32'd0;
    end else begin
        if(opcode == 7'b0110011) begin
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