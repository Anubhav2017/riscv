module instruction_decode(
    input i_clk,
    input i_rstn,
    input wire [31:0] instruction_reg,
    input [31:0] current_pc,

    output logic [4:0] read_addr1, read_addr2,
    input [31:0] read_data1, read_data2,

    output logic [37:0] wb_reg,
    output logic [31:0] new_pc,
    output logic update_pc
);


//typedef enum {U_TYPE=7'b0110111, R_TYPE = 7'b0110011, J_TYPE=7'b1101111, I_TYPE=7'b0000011, S_TYPE=7'b0100011, B_TYPE=7'b1100011} opcode_type;

//typedef enum logic [6:0] {U_TYPE, R_TYPE, J_TYPE, I_TYPE, S_TYPE, B_TYPE} opcode_type;

//opcode_type opcode;

wire [6:0] opcode;

assign opcode = instruction_reg[6:0];



logic [4:0] rs1, rs2,rd;
logic [2:0] func3;
logic [6:0] func7; 
logic [31:0] operand1, operand2;
logic [31:0] result;
logic write_bit;

logic stall;

assign read_addr1 = rs1;
assign read_addr2 = rs2;

always_comb begin

    if(opcode == 7'b0110011) begin  ////R-TYPE
        
        func3 = instruction_reg[14:12];
        func7 = instruction_reg[31:25];
        rs1 = instruction_reg[19:15];
        rs2 = instruction_reg[24:20];
        rd = instruction_reg[11:7];

        
        if(stall == 1'b1)
            write_bit = 1'b0;
        else 
            write_bit = 1'b1;

        if((rs1 == wb_reg[36:32]) && (wb_reg[37]==1'b1)) begin /////data forwarding
            operand1 = wb_reg[31:0];
            operand2 = read_data2;
        end else if(rs2 == wb_reg[36:32] && (wb_reg[37] == 1'b1)) begin
            operand2 = wb_reg[31:0];
            operand1 = read_data1;
        end else begin
            operand1 = read_data1;
            operand2 = read_data2;
        end

        new_pc = 32'd0;
        update_pc = 1'b0;



        if(func3 == 3'b000) begin
            if(func7 == 6'd32) begin ///subtract

                result = operand1-operand2;

            end else begin //add

                result = operand1+operand2;

            end
        end else if(func3 == 3'b111) begin ///and
            result = operand1 & operand2;

        end else if(func3 == 3'b001) begin /// sll
            
            result = 32'd0; ///TODO
        
        end else if(func3 == 3'b010) begin //slt
            
            result = 32'd0; ///TODO

        end else if(func3 == 3'b011) begin //sltu
            
            result = 32'd0; ///TODO

        end else if(func3 == 3'b100) begin //xor
            
            result = operand1 ^ operand2;
        
        end else if(func3 == 3'b101) begin // srl
            
            result = 32'd0; ///TODO

        end else if(func3 == 3'b110) begin //sra
            
            result = 32'd0; ///TODO

        end else begin // or
            
            result = operand1 | operand2;
        
        end

    end else if(opcode == 7'b0110111) begin //lui

        rd = instruction_reg[11:7];
        result = {instruction_reg[31:12],12'd0};
        
        if(stall == 1'b1)
            write_bit = 1'b0;
        else 
            write_bit = 1'b1;

    end else if(opcode == 7'b0010111) begin //auipc

        rd = instruction_reg[11:7];
        result = current_pc + {instruction_reg[31:12],12'd0};

        if(stall == 1'b1)
            write_bit = 1'b0;
        else 
            write_bit = 1'b1;

    end else if(opcode == 7'b1100111) begin //jalr

        rd = instruction_reg[11:7];
        rs1 = instruction_reg[19:15];
        rs2 = 5'd0;
        
        if((rs1 == wb_reg[36:32]) && (wb_reg[37]==1'b1)) /////data forwarding
            operand1 = wb_reg[31:0];
        else
            operand1 = read_data1;

        new_pc = operand1+{20'b0,instruction_reg[31:20]}; ////TODO
        update_pc = 1'b1;
        write_bit = 1'b1;
        result = current_pc+1; 

        if(stall == 1'b1)
            write_bit = 1'b0;
        else 
            write_bit = 1'b1;

    end else if(opcode == 7'b1100011) begin  ///B-TYPE

        write_bit =1'b0;

    end else begin
        result = 32'd0;
        operand1 = 32'd0;
        operand2 = 32'd0;
        write_bit = 1'b0;
        new_pc = 32'd0;
        update_pc = 1'b0;
        rs1 = 5'd0;
        rs2 = 5'd0;
        rd = 5'd0; 
    end

end

always @(posedge i_clk, negedge i_rstn) begin

    if(!i_rstn) begin

        wb_reg <= 38'd0;
        stall <= 1'b0;

    end else begin
        wb_reg <= {write_bit,rd,result};
    end

end

endmodule