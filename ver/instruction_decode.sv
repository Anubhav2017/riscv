module instruction_decode(
    input cpu_clk_aon,
    input i_rstn,
    input wire [64:0] instruction_reg,

    output logic [4:0] read_addr1, read_addr2,
    input [31:0] read_data1, read_data2,

    output logic [37:0] wb_reg,
    output logic [31:0] new_pc,
    output logic update_pc,

    output logic cpu_stall_final,

    output mmu_wr_req,
    output logic [31:0] mmu_wr_data,
    output logic [31:0] mmu_wr_addr,
    output logic [2:0] mmu_wr_req_func3,
	input logic mmu_wr_done,

    output mmu_rd_req,
    output logic [4:0] mmu_rd_req_reg,
    output logic [2:0] mmu_rd_req_func3,
    output logic [31:0] mmu_rd_addr,
    input logic [31:0] mmu_rd_data,
    input logic mmu_rd_valid,
    input logic [4:0] mmu_rd_valid_reg,
    input logic [2:0] mmu_rd_valid_func3

);


//typedef enum {U_TYPE=7'b0110111, R_TYPE = 7'b0110011, J_TYPE=7'b1101111, I_TYPE=7'b0000011, S_TYPE=7'b0100011, B_TYPE=7'b1100011} opcode_type;

//typedef enum logic [6:0] {U_TYPE, R_TYPE, J_TYPE, I_TYPE, S_TYPE, B_TYPE} opcode_type;

//opcode_type opcode;

wire [6:0] opcode;
logic [31:0] current_pc;
logic instruction_valid;


assign instruction_valid = instruction_reg[64];
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
logic [31:0] imm_s;

logic write_bit;


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
assign imm_s = {{20{instruction_reg[31]}},instruction_reg[31:25],instruction_reg[11:7]};

logic hash_table [32];
logic cpu_stall_ext, cpu_stall;

always @(posedge cpu_clk_aon) begin
    cpu_stall_ext <= #(`D_D) cpu_stall;
end

assign cpu_stall_final = cpu_stall | cpu_stall_ext; 

always_comb begin

    update_pc = 1'b0;
    result = 32'd0;
    new_pc =  32'd0;
    operand1 = 32'd0;
    operand2 = 32'd0;
    write_bit = 1'b0;

    mmu_rd_req = 1'b0;
    mmu_rd_addr = 32'd0;
    mmu_rd_req_reg = 5'd0;
    mmu_rd_req_func3 = 3'd0;

    mmu_wr_addr = 32'd0;
    mmu_wr_data = 32'd0;
    mmu_wr_req = 1'b0;
    mmu_wr_req_func3 = 3'd0;

    cpu_stall= 1'b0;

    if(mmu_rd_valid) begin
        cpu_stall = 1'b1;
    end 
    
    if(opcode == 7'b0110111) begin //lui

        result = imm_u;
        
        if (instruction_valid) 
            write_bit = 1'b1;

    end else if(opcode == 7'b0010111) begin //auipc

        result = current_pc + imm_u;

        if (instruction_valid) 
            write_bit = 1'b1;

    end else if(opcode == 7'b1101111) begin //jal

        result = current_pc + 4;
        
        if(instruction_valid) begin
            new_pc = current_pc+imm_j;
            update_pc = 1'b1;
            write_bit = 1'b1; 
        end

    end else if(opcode == 7'b1100111) begin //jalr

        if(hash_table[rs1]==1'b1) begin
            cpu_stall = 1'b1;
            write_bit = 1'b0;

        end
        
        
        if((rs1 == wb_reg[36:32]) && (wb_reg[37]==1'b1)) /////data forwarding
            operand1 = wb_reg[31:0];
        else
            operand1 = read_data1;

        result = current_pc+4; 

        if(instruction_valid) begin
            write_bit = 1'b1;
            update_pc = 1'b1;
            new_pc = operand1+imm_i;

        end
        

    end else if(opcode == 7'b1100011) begin  ///B-TYPE

        if( (hash_table[rs1]==1'b1) | (hash_table[rs2]==1'b1) ) begin
            cpu_stall = 1'b1;
        end
        
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

        if(instruction_valid) begin

            case(func3)

                3'b000: begin //beq

                    if(operand1 == operand2)
                        update_pc = 1'b1;
                end

                3'b001: begin //bne

                    if(operand1 != operand2)
                        update_pc = 1'b1;
                end

                3'b100: begin //blt
                    if($signed(operand1) < $signed(operand2))
                        update_pc = 1'b1;
                end

                3'b101: begin //bge

                    if($signed(operand1) >= $signed(operand2))
                        update_pc = 1'b1;

                end


                3'b110: begin //bltu

                    if(operand1 < operand2)
                        update_pc = 1'b1;

                end 

                3'b111: begin //bgeu
                    if(operand1 >= operand2)
                        update_pc = 1'b1;

                end

                default:
                    update_pc = 1'b0;


            endcase
        end

        if(update_pc == 1'b1) begin
            new_pc = current_pc + imm_b;    
        end

        

    end else if(opcode == 7'b0000011) begin //I-type 1


        if((hash_table[rs1]==1'b1) | (hash_table[rs2]==1'b1)) begin
            cpu_stall = 1'b1;
        end
        
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

        if(instruction_valid) begin

            case(func3)

                3'b000: begin ///lb
                    mmu_rd_addr = operand1 + $signed(imm_i);
                    mmu_rd_req_reg = rd;
                    mmu_rd_req = 1'b1;
                    mmu_rd_req_func3 = 3'b000;

                end

                3'b001: begin ///lh

                    mmu_rd_addr = operand1 + $signed(imm_i);
                    mmu_rd_req_reg = rd;
                    mmu_rd_req = 1'b1;
                    mmu_rd_req_func3 = 3'b001;

                end

                3'b010: begin  ///lw

                    mmu_rd_addr = operand1 + $signed(imm_i);
                    mmu_rd_req_reg = rd;
                    mmu_rd_req = 1'b1;
                    mmu_rd_req_func3 = 3'b010;
                end

                3'b100: begin  ///lbu

                    mmu_rd_addr = operand1 + $signed(imm_i);
                    mmu_rd_req_reg = rd;
                    mmu_rd_req = 1'b1;
                    mmu_rd_req_func3 = 3'b100;

                end

                3'b101: begin  ///lhu

                    mmu_rd_addr = operand1 + $signed(imm_i);
                    mmu_rd_req_reg = rd;
                    mmu_rd_req = 1'b1;
                    mmu_rd_req_func3 = 3'b101;

                end


                default: begin
                    mmu_rd_addr = 32'd0;
                    mmu_rd_req_reg = 5'd0;
                    mmu_rd_req = 1'b0;

                end

            endcase

        end

    end else if(opcode == 7'b0100011) begin //S-Type

        if((hash_table[rs1]==1'b1) | (hash_table[rs2]==1'b1)) begin
            cpu_stall = 1'b1;
        end
        
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

        if(instruction_valid) begin

            case(func3)

                3'b000: begin ///sb
                    mmu_wr_addr = operand1 + $signed(imm_s);
                    mmu_wr_req = 1'b1;
                    mmu_wr_req_func3 = 3'b000;
                    mmu_wr_data = operand2;

                end

                3'b001: begin ///sh

                    mmu_wr_addr = operand1 + $signed(imm_s);
                    mmu_wr_req = 1'b1;
                    mmu_wr_req_func3 = 3'b001;
                    mmu_wr_data = operand2;

                end

                3'b010: begin  ///sw

                    mmu_wr_addr = operand1 + $signed(imm_s);
                    mmu_wr_req = 1'b1;
                    mmu_wr_req_func3 = 3'b010;
                    mmu_wr_data = operand2;
                end


                default: begin
                    mmu_wr_addr = 32'd0;
                    mmu_wr_req = 1'b0;
                    mmu_wr_req_func3 = 3'd0;
                    mmu_wr_data = 32'd0;

                end

            endcase

        end
        
        

    end else if(opcode == 7'b0010011) begin //I-type 2
         
        if(hash_table[rs1]==1'b1) begin
            cpu_stall = 1'b1;
        end 
        
        if(instruction_valid == 1'b0)
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
        

        if( (hash_table[rs1]==1'b1) | (hash_table[rs2]==1'b1) ) begin
            cpu_stall = 1'b1;
        end

        if(instruction_valid == 1'b0)
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
            if(func7 == 7'd32) begin ///subtract

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

always @(posedge cpu_clk_aon, negedge i_rstn) begin

    if(!i_rstn) begin

        wb_reg <= 38'd0;

    end else begin
        if(cpu_stall == 1'b1) begin
            if(mmu_rd_valid) begin
                if(mmu_rd_valid_func3 == 3'b000)
                    wb_reg <= {1'b1,mmu_rd_valid_reg,{24{mmu_rd_data[7]}},mmu_rd_data[7:0]};
                else if(mmu_rd_valid_func3 == 3'b001)
                    wb_reg <= {1'b1,mmu_rd_valid_reg,{16{mmu_rd_data[15]}},mmu_rd_data[15:0]};
                else if(mmu_rd_valid_func3 == 3'b010)
                    wb_reg <= {1'b1,mmu_rd_valid_reg,mmu_rd_data};
                else if(mmu_rd_valid_func3 == 3'b100)
                    wb_reg <= {1'b1,mmu_rd_valid_reg,24'd0,mmu_rd_data[7:0]};
                else if(mmu_rd_valid_func3 == 3'b101)
                    wb_reg <= {1'b1,mmu_rd_valid_reg,16'd0,mmu_rd_data[15:0]};
                else
                    wb_reg <= 38'd0;

            end

        end else begin
            wb_reg <= {write_bit,rd,result};
        end
    end

end

always @(posedge cpu_clk_aon, negedge i_rstn) begin
    if(!i_rstn) begin
        hash_table <= '{32{1'b0}};
    end else begin
        if(mmu_rd_req) begin
            hash_table[rd] <= 1'b1;
        end else if(mmu_rd_valid) begin
            hash_table[mmu_rd_valid_reg] <= 1'b0;
        end
    end
end

endmodule