module direct_map_cache #(
    parameter BLOCK_SIZE = 4, //in bytes
    parameter CACHE_SIZE = 32, //in bytes
    parameter NUM_SET = CACHE_SIZE/BLOCK_SIZE // because direct mapping
) (
    input logic mmu_clk,
    input logic axi_clk,
    input logic i_rstn,
    
    input rd_req,
    input logic [31:0] rd_addr,
    input logic [4:0] rd_req_reg,
    input logic [2:0] rd_req_func3,
    output logic [31:0] rd_data,
    output logic rd_valid,
    output logic [4:0] rd_valid_reg,
    output logic [2:0] rd_valid_func3,


    input wr_req,
    input logic [2:0] wr_req_func3,
    input logic [31:0] wr_data,
    input logic [31:0] wr_addr,
    output logic wr_done,

    output logic axi_rd_rq,
    //input logic axi_rd_rq_ack,
    output logic [31:0] axi_rd_addr,
    input logic [31:0] axi_rd_data,
    input axi_rd_valid,
    input [31:0] axi_rd_valid_addr,
    output logic axi_rd_valid_ack,

    output logic axi_wr_rq,
    output logic [31:0] axi_wr_addr,
    output logic [31:0] axi_wr_data

);

logic [$clog2(NUM_SET)-1:0] rd_set_number;
logic [32-$clog2(NUM_SET)-2-1:0] rd_tag;

logic [$clog2(NUM_SET)-1:0] wr_set_number;
logic [32-$clog2(NUM_SET)-2-1:0] wr_tag;

logic [31:0] cache_mem [NUM_SET];
logic [32-$clog2(NUM_SET)-2-1:0] tag_arr [NUM_SET]; 
logic [NUM_SET-1:0] valid_arr;
logic [NUM_SET-1:0] dirty_bit_arr;

logic rd_hit, wr_hit;
logic [4:0] num_txn_pending;

logic axi_rd_valid_ack_prev;

logic [31:0] addr_fifo_rd_data;
logic [31:0] wr_data_fifo_write_data = wr_req ? wr_data : 32'd0;
logic [31:0] wr_data_fifo_read_data;

logic [31:0] cache_update_read_data;

logic [2:0] func3_fifo_wr_data = wr_req ? wr_req_func3 : rd_req_func3;
logic [2:0] func3_fifo_rd_data;

logic push,push_check, pop, fifo_full, fifo_full_pre, fifo_empty;

logic [$clog2(NUM_SET)-1:0] cache_update_set_number;
logic [32-$clog2(NUM_SET)-2-1:0] cache_update_tag_number;

logic rd_or_write;

logic match1, match2, match2_flopped;

assign match1 = (addr_fifo_rd_data[31:5] == tag_arr[addr_fifo_rd_data[4:2]]) & valid_arr[addr_fifo_rd_data[4:2]];

assign match2 = (addr_fifo_rd_data[31:2] == axi_rd_valid_addr[31:2]);

assign cache_update_read_data = cache_mem[cache_update_set_number];

always @(posedge mmu_clk)
    match2_flopped <= match2;

sync_fifo inst_sync_addr_fifo(
    .i_clk(mmu_clk),
    .i_rstn(i_rstn),
    .push(push),
    .pop(pop),
    .push_data(rd_addr),
    .pop_data(addr_fifo_rd_data),
    .fifo_empty(fifo_empty),
    .fifo_full(fifo_full)
);

sync_fifo inst_sync_wr_data_fifo(
    .i_clk(mmu_clk),
    .i_rstn(i_rstn),
    .push(push),
    .pop(pop),
    .push_data(wr_data_fifo_write_data),
    .pop_data(wr_data_fifo_read_data),
    .fifo_empty(),
    .fifo_full()
);

sync_fifo #(.FIFO_WIDTH(5))inst_sync_reg_fifo (
    .i_clk(mmu_clk),
    .i_rstn(i_rstn),
    .push(push),
    .pop(pop),
    .push_data(rd_req_reg),
    .pop_data(rd_valid_reg),
    .fifo_empty(),
    .fifo_full()
);

sync_fifo #(.FIFO_WIDTH(3))inst_sync_func3_fifo (
    .i_clk(mmu_clk),
    .i_rstn(i_rstn),
    .push(push),
    .pop(pop),
    .push_data(func3_fifo_wr_data),
    .pop_data(func3_fifo_rd_data),
    .fifo_empty(),
    .fifo_full()
);

sync_fifo #(.FIFO_WIDTH(1))inst_sync_rd_or_wr_fifo (
    .i_clk(mmu_clk),
    .i_rstn(i_rstn),
    .push(push),
    .pop(pop),
    .push_data(wr_req),
    .pop_data(rd_or_write),
    .fifo_empty(),
    .fifo_full()
);
assign rd_set_number = rd_addr[4:2];
assign rd_tag = rd_addr[31:5];

always_comb begin

    rd_hit = valid_arr[rd_set_number] & (tag_arr[rd_set_number] == rd_tag);
    axi_rd_addr = {rd_addr[31:2],2'b0};

    wr_hit = valid_arr[wr_set_number] & (tag_arr[wr_set_number] == wr_tag);
    axi_wr_addr = wr_hit ? {wr_addr[31:2],2'd0} : {tag_arr[cache_update_set_number],cache_update_set_number,2'd0};
    axi_wr_data = wr_hit ? wr_data : cache_mem[cache_update_set_number];

end

logic mmu_clk_sync1, mmu_clk_sync2;

always @(posedge axi_clk) begin
    mmu_clk_sync1 <=  #(`D_D) mmu_clk;
    mmu_clk_sync2 <=  #(`D_D) mmu_clk_sync1;
end


logic axi_rd_rq_pre; 

assign axi_rd_rq = (~mmu_clk_sync2) & mmu_clk_sync1 & rd_req & !fifo_full & !rd_hit;
assign axi_wr_rq = (~mmu_clk_sync2) & mmu_clk_sync1 & ((axi_rd_valid & match2 & !match1 & dirty_bit_arr[cache_update_set_number]) | (wr_hit & dirty_bit_arr[wr_addr[4:2]]) | (wr_req & dirty_bit_arr[wr_addr[4:2]] & (wr_req_func3 == 3'b010)));

always @(posedge axi_clk)
    axi_rd_rq <= #(`D_D) axi_rd_rq_pre;


assign pop = (axi_rd_valid_ack & rd_or_write & match2_flopped) | (axi_rd_valid_ack & !rd_or_write & !rd_hit & match2_flopped) | (match1 & rd_or_write & !axi_rd_valid) | (match1 & !rd_or_write & !rd_hit & !axi_rd_valid);

assign push = (rd_req & !rd_hit & !(fifo_full)) | (wr_req & !wr_hit & (wr_req_func3 != 3'b010));

//assign fifo_wr_data =  rd_addr;
assign cache_update_set_number = addr_fifo_rd_data[4:2];
assign cache_update_tag_number = addr_fifo_rd_data[31:5];

always @(posedge mmu_clk, negedge i_rstn) begin

    if(!i_rstn) begin
        num_txn_pending <= 5'd0;
    end else begin
        if(push & !pop)
            num_txn_pending <= #(`D_D) num_txn_pending +1;
        else if(pop & !push)
            num_txn_pending <= #(`D_D) num_txn_pending-1;
    end 

end

always @(posedge mmu_clk, negedge i_rstn) begin
    if(!i_rstn) begin
        valid_arr <= '{NUM_SET{1'b0}};
        cache_mem <= '{NUM_SET{32'd0}};
        tag_arr <= '{NUM_SET{27'd0}};
        dirty_bit_arr <= '{NUM_SET{1'b0}};
        rd_data <= 32'd0;
        rd_valid <= 1'b0;
        axi_rd_valid_ack_prev <= 1'b0;
    end else begin

        axi_rd_valid_ack_prev <= axi_rd_valid_ack;


        if(rd_req & rd_hit) begin
            
            rd_data <= cache_mem[rd_set_number];
            rd_valid <= 1'b1;
            wr_done <= 1'b0;


            if(axi_rd_valid_ack)
                axi_rd_valid_ack <= 1'b0;
        
        end else if((wr_req & wr_hit) | (wr_req & (wr_req_func3 == 3'b010))) begin

            cache_mem[wr_addr[4:2]] <= wr_data;
            wr_done <= 1'b1;
            dirty_bit_arr[wr_addr[4:2]] <= 1'b1;

            if(axi_rd_valid_ack)
                axi_rd_valid_ack <= 1'b0;

            rd_valid <= 1'b0;

        end else begin

            if(axi_rd_valid_ack) begin
                axi_rd_valid_ack <= 1'b0;
                
            end else begin /// do everything when axi_rd_valid_ack is low in previous cycle and axi_rd_valid_ack becomes high in current cycle(for axi_rd_valid case). if axi_rd_valid is low cases 7,8 are dealt


                if(axi_rd_valid) begin
                    if(!match2) begin ///case1

                        axi_rd_valid_ack <= 1'b1;
                        wr_done <= 1'b0;
                        rd_valid <= 1'b0;

                    end else if(match2 & match1) begin

                        axi_rd_valid_ack <= 1'b1;

                        if(rd_or_write) begin /// case2
                            
                            if(func3_fifo_rd_data == 3'b000) begin //sb

                                cache_mem[cache_update_set_number] <=  {cache_update_read_data[31:8],wr_data_fifo_read_data[7:0]};
                                dirty_bit_arr[cache_update_set_number] <= 1'b1;

                            end else if(func3_fifo_rd_data == 3'b001) begin //sh

                                cache_mem[cache_update_set_number] <=  {cache_update_read_data[31:16],wr_data_fifo_read_data[15:0]};
                                dirty_bit_arr[cache_update_set_number] <= 1'b1;

                            end else if(func3_fifo_rd_data == 3'b010) begin //sw

                                cache_mem[cache_update_set_number] <= wr_data_fifo_read_data[31:0];
                                dirty_bit_arr[cache_update_set_number] <= 1'b1;

                            end

                            wr_done <= 1'b1;
                            rd_valid <= 1'b0;

                            

                        end else begin // case 3

                            rd_valid <= 1'b1;
                            rd_data <= cache_mem[cache_update_set_number];
                            rd_valid_func3 <= func3_fifo_rd_data;
                            wr_done <= 1'b0;

                        end


                    end else begin //match2 and no match1
                        axi_rd_valid_ack <= 1'b1;

                        if(rd_or_write) begin //case 4


                            valid_arr[cache_update_set_number] <= 1'b1;
                            
                            if(func3_fifo_rd_data == 3'b000) begin //sb

                                cache_mem[cache_update_set_number] <=  {axi_rd_data[31:8],wr_data_fifo_read_data[7:0]};
                                dirty_bit_arr[cache_update_set_number] <= 1'b1;

                            end else if(func3_fifo_rd_data == 3'b001) begin //sh

                                cache_mem[cache_update_set_number] <=  {axi_rd_data[31:16],wr_data_fifo_read_data[15:0]};
                                dirty_bit_arr[cache_update_set_number] <= 1'b1;

                            end else if(func3_fifo_rd_data == 3'b010) begin //sw

                                cache_mem[cache_update_set_number] <= wr_data_fifo_read_data[31:0];
                                dirty_bit_arr[cache_update_set_number] <= 1'b1;

                            end

                            wr_done <= 1'b1;
                            rd_valid <= 1'b0;
                            
                        end else begin

                            cache_mem[cache_update_set_number] <= axi_rd_data;
                            valid_arr[cache_update_set_number] <= 1'b0;
                            tag_arr[cache_update_set_number] <= cache_update_tag_number;
                            dirty_bit_arr[cache_update_set_number] <= 1'b0;
                            rd_valid <= 1'b1;
                            rd_data <= axi_rd_data;

                            wr_done <= 1'b0;

                        end

                    end

                end else begin  /// no axi_rd_valid

                    if(match1) begin

                        if(rd_or_write) begin // case 8
                            rd_valid <= 1'b1;
                            rd_data <= cache_mem[cache_update_set_number];
                            wr_done <= 1'b0;

                        end else begin // case 7

                            rd_valid <= 1'b0;
                            
                            if(func3_fifo_rd_data == 3'b000) begin //sb

                                cache_mem[cache_update_set_number] <=  {cache_update_read_data[31:8],wr_data_fifo_read_data[7:0]};
                                dirty_bit_arr[cache_update_set_number] <= 1'b1;

                            end else if(func3_fifo_rd_data == 3'b001) begin //sh

                                cache_mem[cache_update_set_number] <=  {cache_update_read_data[31:16],wr_data_fifo_read_data[15:0]};
                                dirty_bit_arr[cache_update_set_number] <= 1'b1;

                            end else if(func3_fifo_rd_data == 3'b010) begin //sw

                                cache_mem[cache_update_set_number] <= cache_update_read_data[31:0];
                                dirty_bit_arr[cache_update_set_number] <= 1'b1;

                            end

                            wr_done <= 1'b1;

                        end
                        
                    end else begin
                        rd_valid <= 1'b0;
                        wr_done <= 1'b0;
                        rd_data <= 32'd0;
                        
                    end


                end

                

            end
        end
        

    end

end





endmodule