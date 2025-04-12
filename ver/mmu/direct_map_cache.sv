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
    input logic [31:0] wr_data,
    input logic [31:0] wr_addr,
    output logic wr_done,

    output logic axi_rd_rq,
    //input logic axi_rd_rq_ack,
    output logic [31:0] axi_rd_addr,
    input logic [31:0] axi_rd_data,
    input axi_rd_valid,
    output logic axi_rd_valid_ack,

    output logic axi_wr_rq,
    input logic axi_wr_rq_ack,

    output logic [31:0] axi_wr_addr,
    output logic [31:0] axi_wr_data,
    input axi_wr_done,
    output logic axi_wr_done_ack,

    output logic axi_id

);

logic [$clog2(NUM_SET)-1:0] rd_set_number;
logic [32-$clog2(NUM_SET)-2-1:0] rd_tag;

logic [$clog2(NUM_SET)-1:0] wr_set_number;
logic [32-$clog2(NUM_SET)-2-1:0] wr_tag;

logic [31:0] cache_mem [NUM_SET];
logic [32-$clog2(NUM_SET)-2-1:0] tag_arr [NUM_SET]; 
logic [NUM_SET-1:0] valid_arr;

logic rd_hit, wr_hit;
logic [4:0] num_rd_pending;

logic axi_rd_valid_ack_prev;

logic [31:0] fifo_rd_data;
logic push,push_check, pop, fifo_full, fifo_full_pre, fifo_empty;

logic [$clog2(NUM_SET)-1:0] cache_update_set_number;
logic [32-$clog2(NUM_SET)-2-1:0] cache_update_tag_number;

sync_fifo inst_sync_rd_addr_fifo(
    .i_clk(mmu_clk),
    .i_rstn(i_rstn),
    .push(push),
    .pop(pop),
    .push_data(rd_addr),
    .pop_data(fifo_rd_data),
    .fifo_empty(fifo_empty),
    .fifo_full(fifo_full)
);

sync_fifo #(.FIFO_WIDTH(5))inst_sync_rd_reg_fifo (
    .i_clk(mmu_clk),
    .i_rstn(i_rstn),
    .push(push),
    .pop(pop),
    .push_data(rd_req_reg),
    .pop_data(rd_valid_reg),
    .fifo_empty(),
    .fifo_full()
);

sync_fifo #(.FIFO_WIDTH(3))inst_sync_rd_func3_fifo (
    .i_clk(mmu_clk),
    .i_rstn(i_rstn),
    .push(push),
    .pop(pop),
    .push_data(rd_req_func3),
    .pop_data(rd_valid_func3),
    .fifo_empty(),
    .fifo_full()
);

assign rd_set_number = rd_addr[4:2];
assign rd_tag = rd_addr[31:5];

always_comb begin

    rd_hit = valid_arr[rd_set_number] & (tag_arr[rd_set_number] == rd_tag);
    axi_rd_addr = {rd_addr[31:2],2'b0};

    wr_hit = valid_arr[wr_set_number] & (tag_arr[wr_set_number] == wr_tag);
    axi_wr_addr = {wr_addr[31:2],2'b0};

end

logic mmu_clk_sync1, mmu_clk_sync2;

always @(posedge axi_clk) begin
    mmu_clk_sync1 <=  #(`D_D) mmu_clk;
    mmu_clk_sync2 <=  #(`D_D) mmu_clk_sync1;
end


logic axi_rd_rq_pre; 

assign axi_rd_rq = (~mmu_clk_sync2) & mmu_clk_sync1 & rd_req & !fifo_full;

always @(posedge axi_clk)
    axi_rd_rq <= #(`D_D) axi_rd_rq_pre;
//always @(posedge axi_clk, negedge i_rstn) begin
//
//    if(!i_rstn) begin
//        axi_rd_rq <= 1'b0;
//    end else begin
//        if(axi_rd_rq_ack & axi_rd_rq)
//            axi_rd_rq <= 1'b0;
//        else begin
//
//            if(rd_req & !rd_hit) begin
//                if(!fifo_full) begin
//                    axi_rd_rq <= 1'b1;
//                end
//            end
//
//        end
//    end
//end


assign pop = axi_rd_valid_ack_prev & !axi_rd_valid_ack;

assign push = (rd_req & !rd_hit & !(fifo_full));

//assign fifo_wr_data =  rd_addr;
assign cache_update_set_number = fifo_rd_data[4:2];
assign cache_update_tag_number = fifo_rd_data[31:5];

always @(posedge mmu_clk, negedge i_rstn) begin

    if(!i_rstn) begin
        num_rd_pending <= 5'd0;
    end else begin
        if(push & !pop)
            num_rd_pending <= num_rd_pending +1;
        else if(pop & !push)
            num_rd_pending <= num_rd_pending-1;
    end 

end

always @(posedge mmu_clk, negedge i_rstn) begin
    if(!i_rstn) begin
        valid_arr <= 8'd0;
        cache_mem <= '{NUM_SET{32'd0}};
        tag_arr <= '{NUM_SET{27'd0}};
        rd_data <= 32'd0;
        rd_valid <= 1'b0;
        num_rd_pending <= 5'd0;
        axi_rd_valid_ack_prev <= 1'b0;
    end else begin

        axi_rd_valid_ack_prev <= axi_rd_valid_ack;


        if(rd_req & rd_hit) begin
            
            rd_data <= cache_mem[rd_set_number];
            rd_valid <= 1'b1;


            if(axi_rd_valid_ack)
                axi_rd_valid_ack <= 1'b0;

        end else begin

            if(axi_rd_valid_ack) begin
                axi_rd_valid_ack <= 1'b0;
                rd_valid <= 1'b0;

            end else begin

                if(num_rd_pending > 0) begin

                        if(axi_rd_valid) begin
                            rd_data <= axi_rd_data;
                            rd_valid <= 1'b1;
                            axi_rd_valid_ack <= 1'b1;
                            cache_mem[cache_update_set_number] <= axi_rd_data;
                            tag_arr[cache_update_set_number] <= cache_update_tag_number;
                            valid_arr[cache_update_set_number] <= 1'b1;

                        end else begin
                            rd_data <= 32'd0;
                            rd_valid <= 1'b0;

                        end
                
                end else 
                    rd_valid <= 1'b0;

            end
        end
        

    end

end





endmodule