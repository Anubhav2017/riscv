module sync_fifo#(
    parameter FIFO_WIDTH = 32,
    parameter FIFO_DEPTH = 16
)(
    input logic i_clk,
    input logic i_rstn,

    input logic push,
    input logic pop,

    input logic [FIFO_WIDTH-1:0] push_data,
    output logic [FIFO_WIDTH-1:0]pop_data,

    output logic fifo_full,
    output logic fifo_empty
);

logic [FIFO_WIDTH-1:0] fifo_mem [FIFO_DEPTH];
logic [$clog2(FIFO_DEPTH):0] rd_ptr;
logic [$clog2(FIFO_DEPTH):0] wr_ptr;

assign fifo_empty = (rd_ptr == wr_ptr);
assign fifo_full = ((rd_ptr[$clog2(FIFO_DEPTH)-1:0] == wr_ptr[$clog2(FIFO_DEPTH)-1:0]) & (rd_ptr[$clog2(FIFO_DEPTH)] != wr_ptr[$clog2(FIFO_DEPTH)]));
assign pop_data = fifo_mem[rd_ptr[$clog2(FIFO_DEPTH)-1:0]];
integer i;

always @(posedge i_clk, negedge i_rstn) begin

    if(!i_rstn) begin
        fifo_mem <= '{FIFO_DEPTH{'{FIFO_WIDTH{1'b0}}}};
        rd_ptr <= {$clog2(FIFO_DEPTH)+1{1'b0}};
        wr_ptr <= {$clog2(FIFO_DEPTH)+1{1'b0}};
    end else begin
        if(push) begin
            if(!fifo_full) begin
                fifo_mem[wr_ptr[$clog2(FIFO_DEPTH)-1:0]] <= push_data;
                wr_ptr <= wr_ptr+1;
            end
        end else if(pop) begin
            if(!fifo_empty) begin
                rd_ptr <= rd_ptr+1;
            end
        end

    end

end


endmodule