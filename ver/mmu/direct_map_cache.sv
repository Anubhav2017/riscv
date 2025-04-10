module direct_map_cache #(
    parameter BLOCK_SIZE = 4, //in bytes
    parameter CACHE_SIZE = 32, //in bytes
    parameter NUM_SET = CACHE_SIZE/BLOCK_SIZE // because direct mapping
) (
    input logic i_clk,
    input logic i_rstn,
    
    input rd_req,
    input logic [31:0] rd_addr,

    output logic [31:0] rd_data,
    output logic rd_valid,


    input wr_req,
    input logic [31:0] wr_data,
    input logic [31:0] wr_addr,
    output logic wr_done,

    output logic axi_rd_rq,
    input logic axi_rd_rq_ack,
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


logic [31:0] fifo_wr_data;
logic [31:0] fifo_rd_data;
logic push, pop, fifo_full, fifo_empty;

logic [$clog2(NUM_SET)-1:0] cache_update_set_number;
logic [32-$clog2(NUM_SET)-2-1:0] cache_update_tag_number;

sync_fifo inst_sync_fifo(
    .i_clk(i_clk),
    .i_rstn(i_rstn),
    .push(push),
    .pop(pop),
    .push_data(fifo_wr_data),
    .pop_data(fifo_rd_data),
    .fifo_empty(fifo_empty),
    .fifo_full(fifo_full)
);


assign rd_set_number = rd_addr[4:2];
assign rd_tag = rd_addr[31:5];

always_comb begin

    rd_hit = valid_arr[rd_set_number] & (tag_arr[rd_set_number] == rd_tag);
    axi_rd_addr = {rd_addr[31:2],2'b0};

    wr_hit = valid_arr[wr_set_number] & (tag_arr[wr_set_number] == wr_tag);
    axi_wr_addr = {wr_addr[31:2],2'b0};

end

always @(posedge i_clk, negedge i_rstn) begin

    if(!i_rstn) begin
        axi_rd_rq <= 1'b0;
        axi_id <= 1'b0;

    end else begin
        if(rd_req & !rd_hit) begin
            if(!fifo_full) begin
                axi_rd_rq <= 1'b1;
                fifo_wr_data <= rd_addr;
                push <= 1'b1;
            end
        end else begin
            push <= 1'b0;
            if(axi_rd_rq_ack)
                axi_rd_rq <= 1'b0;
        end

    end

end

assign pop = axi_rd_valid & !prev_axi_rd_valid;
assign cache_update_set_number = fifo_rd_data[4:2];
assign cache_update_tag_number = fifo_rd_data[31:5];

logic prev_axi_rd_valid;
always @(posedge i_clk, negedge i_rstn) begin
    if(!i_rstn) begin
        valid_arr <= 8'd0;
        cache_mem <= '{NUM_SET{32'd0}};
        tag_arr <= '{NUM_SET{27'd0}};
        rd_data <= 32'd0;
        rd_valid <= 1'b0;
        num_rd_pending <= 5'd0;
    end else begin


        if(rd_req) begin
            
            if(rd_hit) begin
                rd_data <= cache_mem[rd_set_number];
                rd_valid <= 1'b1;
            end else begin
                if(!fifo_full)
                    num_rd_pending <= num_rd_pending +1;

            end
        end

        prev_axi_rd_valid <= axi_rd_valid;

        if(num_rd_pending > 0) begin

                if(axi_rd_valid & !prev_axi_rd_valid) begin
                    rd_data <= axi_rd_data;
                    rd_valid <= 1'b1;
                    num_rd_pending <= num_rd_pending-1;
                    axi_rd_valid_ack <= 1'b1;
                    cache_mem[cache_update_set_number] <= axi_rd_data;
                    tag_arr[cache_update_set_number] <= cache_update_tag_number;
                    valid_arr[cache_update_set_number] <= 1'b1;
                end else begin
                    rd_data <= 32'd0;
                    rd_valid <= 1'b0;

                end
        end

        if(!axi_rd_valid)
            axi_rd_valid_ack <= 1'b0;
        

    end

end




endmodule