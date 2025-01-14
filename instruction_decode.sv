module instruction_decode(
    input i_clk,
    input i_rstn,
    input wire [31:0] instruction_reg,

    output logic [4:0] read_addr1, read_addr2,
    input [31:0] read_data1, read_data2,

    output logic [63:0] wb_reg
);


//typedef enum {U_TYPE=7'b0110111, R_TYPE = 7'b0110011, J_TYPE=7'b1101111, I_TYPE=7'b0000011, S_TYPE=7'b0100011, B_TYPE=7'b1100011} opcode_type;

//typedef enum logic [6:0] {U_TYPE, R_TYPE, J_TYPE, I_TYPE, S_TYPE, B_TYPE} opcode_type;

//opcode_type opcode;

wire [6:0] opcode;

assign opcode = instruction_reg[6:0];


///R TYPE
wire [4:0] rs1, rs2,rd;
logic [31:0] operand1, operand2;

assign func3 = instruction_reg[14:12];
assign func7 = instruction_reg[31:25];
assign rs1 = instruction_reg[19:15];
assign rs2 = instruction_reg[24:20];
assign rd = instruction_reg[11:7];

logic [31:0] result;

always_comb begin

    if(opcode == 7'b0110011) begin
        
        read_addr1 = rs1;
        read_addr2 = rs2;

        if((rs1 == wb_reg[43:39])) begin /////data forwarding
            operand1 = wb_reg[31:0];
            operand2 = read_data2;
        end else if(rs2 == wb_reg[43:39]) begin
            operand2 = wb_reg[31:0];
            operand1 = read_data1;
        end else begin
            operand1 = read_data1;
            operand2 = read_data2;
        end


        if(func3 == 3'b000) begin
            if(func7 == 6'd32) begin ///subtract

                result = operand1-operand2;

            end else begin //add

                result = operand1+operand2;

            end

        end
    end else begin
        read_addr1 = 5'd0;
        read_addr2 = 5'd0;
        result = 32'd0;
        operand1 = 32'd0;
        operand2 = 32'd0;
    end

end

always @(posedge i_clk, negedge i_rstn) begin

    if(!i_rstn) begin

        wb_reg <= 64'd0;

    end else begin
        wb_reg <= {instruction_reg,result};
    end

end

endmodule