module instruction_decode(
    input i_clk,
    input i_rstn,
    input wire [63:0] instruction_reg,

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
logic [31:0] current_pc;

assign current_pc = instruction_reg[63:32];
assign opcode = instruction_reg[6:0];



logic [4:0] rs1, rs2,rd;
logic [2:0] func3;
logic [6:0] func7; 
logic [31:0] operand1, operand2;

logic [31:0] result;
logic [31:0] imm_b;
logic [31:0] imm_i;
logic [31:0] imm_u;
logic [31:0] imm_j;

logic write_bit;

logic stall;

assign read_addr1 = rs1;
assign read_addr2 = rs2;

assign rs1 = instruction_reg[19:15];
assign rs2 = instruction_reg[24:20];
assign rd = instruction_reg[11:7];

assign func3 = instruction_reg[14:12];
assign func7 = instruction_reg[31:25];

assign imm_b = {{19{instruction_reg[31]}},instruction_reg[31],instruction_reg[7],instruction_reg[30:25],instruction_reg[11:8],1'b0};
assign imm_u = {instruction_reg[31:12],12'd0};
assign imm_i = {{20{instruction_reg[31]}},instruction_reg[31:20]};
assign imm_j = {{12{instruction_reg[31]}},instruction_reg[19:12],instruction_reg[20],instruction_reg[30:21],1'b0};

always_comb begin

    if(opcode == 7'b0110111) begin //lui

        result = imm_u;
        update_pc = 1'b0;
        new_pc = 32'd0;
        operand1 = 32'd0;
        operand2 = 32'd0;
        
        if(stall == 1'b1)
            write_bit = 1'b0;
        else 
            write_bit = 1'b1;

    end else if(opcode == 7'b0010111) begin //auipc

        result = current_pc + imm_u;
        update_pc = 1'b0;
        new_pc = 32'd0;
        operand1 = 32'd0;
        operand2 = 32'd0;

        if(stall == 1'b1)
            write_bit = 1'b0;
        else 
            write_bit = 1'b1;

    end else if(opcode == 7'b1101111) begin //jal

        result = current_pc + 4;
        operand1 = 32'd0;
        operand2 = 32'd0;
        
        if(stall == 1'b1) begin
            write_bit = 1'b0;
            update_pc = 1'b0;
            new_pc = 32'd0;
        end else begin

            new_pc = current_pc+imm_j;
            update_pc = 1'b1;
            write_bit = 1'b1; 


        end

    end else if(opcode == 7'b1100111) begin //jalr

        operand2 = 32'd0;
        
        if((rs1 == wb_reg[36:32]) && (wb_reg[37]==1'b1)) /////data forwarding
            operand1 = wb_reg[31:0];
        else
            operand1 = read_data1;

        result = current_pc+4; 

        if(stall == 1'b1) begin
            write_bit = 1'b0;
            update_pc = 1'b0;
            new_pc = 32'd0;
        end else begin 
            write_bit = 1'b1;
            update_pc = 1'b1;
            new_pc = operand1+imm_i;

        end

    end else if(opcode == 7'b1100011) begin  ///B-TYPE

        write_bit =1'b0;
        result = 32'd0;
        
        if((rs1 == wb_reg[36:32]) && (wb_reg[37]==1'b1)) begin /////data forwarding
            operand1 = wb_reg[31:0];
        end else begin
            operand1 = read_data1;
        end

        if(rs2 == wb_reg[36:32] && (wb_reg[37] == 1'b1)) begin
            operand2 = wb_reg[31:0];
        end else begin
            operand2 = read_data2;
        end

        if(stall == 1'b1)
            update_pc = 1'b0;
        else begin

            case(func3)

                3'b000: begin //beq

                    if(operand1 == operand2)
                        update_pc = 1'b1;
                    else
                        update_pc = 1'b0;
                end

                3'b001: begin //bne

                    if(operand1 != operand2)
                        update_pc = 1'b1;
                    else
                        update_pc = 1'b0;
                end

                3'b100: begin //blt
                    if($signed(operand1) < $signed(operand2))
                        update_pc = 1'b1;
                    else
                        update_pc = 1'b0;
                end

                3'b101: begin //bge

                    if($signed(operand1) >= $signed(operand2))
                        update_pc = 1'b1;
                    else
                        update_pc = 1'b0;

                end


                3'b110: begin //bltu

                    if(operand1 < operand2)
                        update_pc = 1'b1;
                    else
                        update_pc = 1'b0;

                end 

                3'b111: begin //bgeu
                    if(operand1 >= operand2)
                        update_pc = 1'b1;
                    else
                        update_pc = 1'b0;

                end

                default:
                    update_pc = 1'b0;


            endcase
        end

        if(update_pc == 1'b1) begin
            new_pc = current_pc + imm_b;    
        end else
            new_pc = 32'd0;

    //end else if(opcode == 7'b0000011) begin //I-type 1

        

    end else if(opcode == 7'b0010011) begin //I-type 2
         
    
        operand2 = 32'd0;
        if(stall == 1'b1)
            write_bit = 1'b0;
        else 
            write_bit = 1'b1;

        if((rs1 == wb_reg[36:32]) && (wb_reg[37]==1'b1)) begin /////data forwarding
            operand1 = wb_reg[31:0];
        end else begin
            operand1 = read_data1;
        end

        new_pc = 32'd0;
        update_pc = 1'b0;

        case(func3)

            3'b000: begin //addi
                result = $signed(operand1) + $signed(imm_i);
            end

            3'b010: begin //slti

                result = ($signed(operand1) < $signed(imm_i) ? 32'd1 : 32'd0);

            end

            3'b011: begin //sltiu
                result = ((operand1) < (imm_i) ? 32'd1 : 32'd0);
            end

            3'b100: begin //xori

                result = operand1 ^ imm_i;

            end


            3'b110: begin //ori

                result = operand1 | imm_i;
            
            end 

            3'b111: begin //andi

                result = operand1 & imm_i;

            end
            
            default:
                result = 32'd0; 

        endcase

    end else if(opcode == 7'b0110011) begin  ////R-TYPE
        

        
        if(stall == 1'b1)
            write_bit = 1'b0;
        else 
            write_bit = 1'b1;

        if((rs1 == wb_reg[36:32]) && (wb_reg[37]==1'b1)) begin /////data forwarding
            operand1 = wb_reg[31:0];
        end else begin
            operand1 = read_data1;
        end

        if(rs2 == wb_reg[36:32] && (wb_reg[37] == 1'b1)) begin
            operand2 = wb_reg[31:0];
        end else begin
            operand2 = read_data2;
        end

        new_pc = 32'd0;
        update_pc = 1'b0;

        if(func3 == 3'b000) begin
            if(func7 == 6'd32) begin ///subtract

                result = $signed(operand1)-$signed(operand2);

            end else begin //add

                result = $signed(operand1)+$signed(operand2);

            end
        end else if(func3 == 3'b111) begin ///and
            result = operand1 & operand2;

        end else if(func3 == 3'b001) begin /// sll
            
            result = operand1 << operand2[4:0];
        
        end else if(func3 == 3'b010) begin //slt
            
            result = ($signed(operand1) < $signed(operand2)) ? 32'd1 : 32'd0;

        end else if(func3 == 3'b011) begin //sltu
            
            result = (operand1 < operand2) ? 32'd1 : 32'd0;

        end else if(func3 == 3'b100) begin //xor
            
            result = operand1 ^ operand2;
        
        end else if(func3 == 3'b101) begin 

            if(func7 == 7'd0) begin //srl
                result = operand1 >> operand2[4:0];

            end else if(func7 == 7'b0100000) begin //sra
                result = operand1 >>> operand2[4:0];

            end else
                result = 32'd0;

        end else begin // or
            
            result = operand1 | operand2;
        
        end

    
    end else begin
        result = 32'd0;
        operand1 = 32'd0;
        operand2 = 32'd0;
        write_bit = 1'b0;
        new_pc = 32'd0;
        update_pc = 1'b0;
    end

end

always @(posedge i_clk, negedge i_rstn) begin

    if(!i_rstn) begin

        wb_reg <= 38'd0;
        stall <= 1'b0;

    end else begin
        wb_reg <= {write_bit,rd,result};
        if(update_pc)
            stall <= 1'b1;
        else
            stall <= 1'b0;
    end

end

endmodule