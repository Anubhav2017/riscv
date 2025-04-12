
	module my_axi_master_sim_model #
	(

		// Burst Length. Supports 1, 2, 4, 8, 16, 32, 64, 128, 256 burst lengths
		parameter C_M_AXI_BURST_LEN	= 16,
		// Thread ID Width
		parameter integer C_M_AXI_ID_WIDTH	= 1,
		// Width of Address Bus
		parameter integer C_M_AXI_ADDR_WIDTH	= 32,
		// Width of Data Bus
		parameter integer C_M_AXI_DATA_WIDTH	= 32,
		// Width of User Write Address Bus
		parameter integer C_M_AXI_AWUSER_WIDTH	= 1,
		// Width of User Read Address Bus
		parameter integer C_M_AXI_ARUSER_WIDTH	= 1,
		// Width of User Write Data Bus
		parameter integer C_M_AXI_WUSER_WIDTH	= 1,
		// Width of User Read Data Bus
		parameter integer C_M_AXI_RUSER_WIDTH	= 1,
		// Width of User Response Bus
		parameter integer C_M_AXI_BUSER_WIDTH	= 1
	)
	(
		// Initiate AXI transactions
		input wire  axi_wr_rq,
		output logic axi_wr_rq_ack,
        input wire [C_M_AXI_ADDR_WIDTH-1:0] axi_wr_addr,
		input logic [C_M_AXI_DATA_WIDTH-1:0] axi_wr_data[C_M_AXI_BURST_LEN],
		output logic axi_wr_done,
		input axi_wr_done_ack,

	    output logic [C_M_AXI_DATA_WIDTH-1:0] axi_rd_data[C_M_AXI_BURST_LEN],
        input wire axi_rd_rq,
		//output logic axi_rd_rq_ack,
        input wire [C_M_AXI_ADDR_WIDTH-1:0] axi_rd_addr,
		output axi_rd_valid,
		input axi_rd_valid_ack,
		
        // Global Clock Signal.
		input wire  M_AXI_ACLK,
		// Global Reset Singal. This Signal is Active Low
		input wire  M_AXI_ARESETN,
		// Master Interface Write Address ID
		output wire [C_M_AXI_ID_WIDTH-1 : 0] M_AXI_AWID,
		// Master Interface Write Address
		output wire [C_M_AXI_ADDR_WIDTH-1 : 0] M_AXI_AWADDR,
		// Burst length. The burst length gives the exact number of transfers in a burst
		output wire [7 : 0] M_AXI_AWLEN,
		// Burst size. This signal indicates the size of each transfer in the burst
		output wire [2 : 0] M_AXI_AWSIZE,
		// Burst type. The burst type and the size information, 
    // determine how the address for each transfer within the burst is calculated.
		output wire [1 : 0] M_AXI_AWBURST,
		// Lock type. Provides additional information about the
    // atomic characteristics of the transfer.
		output wire  M_AXI_AWLOCK,
		// Memory type. This signal indicates how transactions
    // are required to progress through a system.
		output wire [3 : 0] M_AXI_AWCACHE,
		// Protection type. This signal indicates the privilege
    // and security level of the transaction, and whether
    // the transaction is a data access or an instruction access.
		output wire [2 : 0] M_AXI_AWPROT,
		// Quality of Service, QoS identifier sent for each write transaction.
		output wire [3 : 0] M_AXI_AWQOS,
		// Optional User-defined signal in the write address channel.
		output wire [C_M_AXI_AWUSER_WIDTH-1 : 0] M_AXI_AWUSER,
		// Write address valid. This signal indicates that
    // the channel is signaling valid write address and control information.
		output reg  M_AXI_AWVALID,
		// Write address ready. This signal indicates that
    // the slave is ready to accept an address and associated control signals
		input wire  M_AXI_AWREADY,
		// Master Interface Write Data.
		output reg [C_M_AXI_DATA_WIDTH-1 : 0] M_AXI_WDATA,
		// Write strobes. This signal indicates which byte
    // lanes hold valid data. There is one write strobe
    // bit for each eight bits of the write data bus.
		output reg [C_M_AXI_DATA_WIDTH/8-1 : 0] M_AXI_WSTRB,
		// Write last. This signal indicates the last transfer in a write burst.
		output reg  M_AXI_WLAST,
		// Optional User-defined signal in the write data channel.
		output wire [C_M_AXI_WUSER_WIDTH-1 : 0] M_AXI_WUSER,
		// Write valid. This signal indicates that valid write
    // data and strobes are available
		output reg  M_AXI_WVALID,
		// Write ready. This signal indicates that the slave
    // can accept the write data.
		input wire  M_AXI_WREADY,
		// Master Interface Write Response.
		input wire [C_M_AXI_ID_WIDTH-1 : 0] M_AXI_BID,
		// Write response. This signal indicates the status of the write transaction.
		input wire [1 : 0] M_AXI_BRESP,
		// Optional User-defined signal in the write response channel
		input wire [C_M_AXI_BUSER_WIDTH-1 : 0] M_AXI_BUSER,
		// Write response valid. This signal indicates that the
    // channel is signaling a valid write response.
		input wire  M_AXI_BVALID,
		// Response ready. This signal indicates that the master
    // can accept a write response.
		output reg  M_AXI_BREADY,
		// Master Interface Read Address.
		output wire [C_M_AXI_ID_WIDTH-1 : 0] M_AXI_ARID,
		// Read address. This signal indicates the initial
    // address of a read burst transaction.
		output reg [C_M_AXI_ADDR_WIDTH-1 : 0] M_AXI_ARADDR,
		// Burst length. The burst length gives the exact number of transfers in a burst
		output wire [7 : 0] M_AXI_ARLEN,
		// Burst size. This signal indicates the size of each transfer in the burst
		output wire [2 : 0] M_AXI_ARSIZE,
		// Burst type. The burst type and the size information, 
    // determine how the address for each transfer within the burst is calculated.
		output wire [1 : 0] M_AXI_ARBURST,
		// Lock type. Provides additional information about the
    // atomic characteristics of the transfer.
		output wire  M_AXI_ARLOCK,
		// Memory type. This signal indicates how transactions
    // are required to progress through a system.
		output wire [3 : 0] M_AXI_ARCACHE,
		// Protection type. This signal indicates the privilege
    // and security level of the transaction, and whether
    // the transaction is a data access or an instruction access.
		output wire [2 : 0] M_AXI_ARPROT,
		// Quality of Service, QoS identifier sent for each read transaction
		output wire [3 : 0] M_AXI_ARQOS,
		// Optional User-defined signal in the read address channel.
		output wire [C_M_AXI_ARUSER_WIDTH-1 : 0] M_AXI_ARUSER,
		// Write address valid. This signal indicates that
    // the channel is signaling valid read address and control information
		output reg  M_AXI_ARVALID,
		// Read address ready. This signal indicates that
    // the slave is ready to accept an address and associated control signals
		input wire  M_AXI_ARREADY,
		// Read ID tag. This signal is the identification tag
    // for the read data group of signals generated by the slave.
		input wire [C_M_AXI_ID_WIDTH-1 : 0] M_AXI_RID,
		// Master Read Data
		input wire [C_M_AXI_DATA_WIDTH-1 : 0] M_AXI_RDATA,
		// Read response. This signal indicates the status of the read transfer
		input wire [1 : 0] M_AXI_RRESP,
		// Read last. This signal indicates the last transfer in a read burst
		input wire  M_AXI_RLAST,
		// Optional User-defined signal in the read address channel.
		input wire [C_M_AXI_RUSER_WIDTH-1 : 0] M_AXI_RUSER,
		// Read valid. This signal indicates that the channel
    // is signaling the required read data.
		input wire  M_AXI_RVALID,
		// Read ready. This signal indicates that the master can
    // accept the read data and response information.
		output reg  M_AXI_RREADY
	);



    logic [31:0] memory [5000];
	logic axi_rd_valid_pre;
	logic axi_wr_done_pre;

	logic axi_rd_rq_prev;
	logic axi_wr_rq_prev;


	assign M_AXI_WSTRB = 4'hF;

	assign M_AXI_ARBURST = 2'b01;
	assign M_AXI_ARCACHE = 4'd0;
	assign M_AXI_ARID = 1'b0;
	assign M_AXI_AWLEN = C_M_AXI_BURST_LEN-1;
	assign M_AXI_ARLEN = C_M_AXI_BURST_LEN-1;
	assign M_AXI_ARLOCK = 1'b0;
	assign M_AXI_ARPROT = 3'b0;

	assign M_AXI_ARQOS = 4'b0;
	assign M_AXI_ARSIZE = 3'b010;
	assign M_AXI_AWSIZE = 3'b010;
	assign M_AXI_ARUSER = 1'b0;
	assign M_AXI_AWBURST = 2'b01;
	assign M_AXI_AWCACHE = 4'b0;
	assign M_AXI_AWID = 1'b0;
	assign M_AXI_AWLOCK = 1'b0;
	assign M_AXI_AWPROT = 3'b0;
	assign M_AXI_AWQOS = 4'b0;
	assign M_AXI_AWUSER = 1'b0;


genvar gvar;
logic [3:0] read_tracker;
logic [10:0] read_time_counter[16];
logic run_read_time_counter[16];
logic [31:0] rd_addr_lat[16];

logic [31:0] rd_addr_pre_final [16];
logic [31:0] rd_addr_final;
logic [15:0] read_time_counter_timeout;

logic [3:0] write_tracker;
logic [10:0] write_time_counter[16];
logic run_write_time_counter[16];
logic [31:0] wr_addr_lat[16];
logic [31:0] wr_data_lat[16];

logic [31:0] wr_addr_pre_final [16];
logic [31:0] wr_data_pre_final [16];
logic [31:0] wr_addr_final;
logic [31:0] wr_data_final;
logic [15:0] write_time_counter_timeout;
always_comb begin
	rd_addr_final = 32'd0;
	wr_addr_final = 32'd0;
	wr_data_final = 32'd0;
	for(int j=0; j<16; j++) begin
		if(rd_addr_pre_final[j] != 32'd0)
			rd_addr_final = rd_addr_pre_final[j];
		
		if(wr_addr_pre_final[j] != 32'd0)
			wr_addr_final = wr_addr_pre_final[j];
		
		if(wr_data_pre_final[j] != 32'd0)
			wr_data_final = wr_data_pre_final[j];
	end
end



generate
	for(gvar=0; gvar<16; gvar=gvar+1) begin

    	always @(posedge M_AXI_ACLK, negedge M_AXI_ARESETN) begin
    	    if(!M_AXI_ARESETN) begin
    	        read_time_counter[gvar] <= 11'd0;

    	    end else begin
    	        if(run_read_time_counter[gvar]) begin
    	            read_time_counter[gvar] <= read_time_counter[gvar]+1;
    	        end else begin
    	            read_time_counter[gvar] <= 11'd0;
    	        end

    	    end
    	end


		always_comb begin
			if(read_time_counter[gvar] == 11'd1000) begin
				read_time_counter_timeout[gvar] = 1'b1;
				rd_addr_pre_final[gvar] = rd_addr_lat[gvar];
			end else begin
				read_time_counter_timeout[gvar] = 1'b0;
				rd_addr_pre_final[gvar] = 32'd0;
			end
		end


		always @(posedge M_AXI_ACLK, negedge M_AXI_ARESETN) begin

			if(!M_AXI_ARESETN) begin
				run_read_time_counter[gvar] <= 1'b0;
				rd_addr_lat[gvar] <= 32'd0;
				axi_rd_valid <= 1'b0; 
				axi_rd_valid_pre <= 1'b0;

			end else begin

				if(axi_rd_rq & !axi_rd_rq_prev) begin
					if(gvar == read_tracker) begin
						run_read_time_counter[gvar] <= 1'b1;
						rd_addr_lat[gvar] <= axi_rd_addr; 
					end
				end


				if(run_read_time_counter[gvar]) begin

					if(read_time_counter[gvar] == 11'd1000) begin
						run_read_time_counter[gvar] <= 1'b0;
					end else begin
						run_read_time_counter[gvar] <= 1'b1;
					end
				end


			end

		end

    	always @(posedge M_AXI_ACLK, negedge M_AXI_ARESETN) begin
    	    if(!M_AXI_ARESETN) begin
    	        write_time_counter[gvar] <= 11'd0;

    	    end else begin
    	        if(run_write_time_counter[gvar]) begin
    	            write_time_counter[gvar] <= write_time_counter[gvar]+1;
    	        end else begin
    	            write_time_counter[gvar] <= 11'd0;
    	        end

    	    end
    	end


		always_comb begin
			if(write_time_counter[gvar] == 11'd1000) begin
				write_time_counter_timeout[gvar] = 1'b1;
				wr_addr_pre_final[gvar] = wr_addr_lat[gvar];
				wr_data_pre_final[gvar] = wr_data_lat[gvar];
			end else begin
				write_time_counter_timeout[gvar] = 1'b0;
				wr_addr_pre_final[gvar] = 32'd0;
				wr_data_pre_final[gvar] = 32'd0;
			end
		end


		always @(posedge M_AXI_ACLK, negedge M_AXI_ARESETN) begin

			if(!M_AXI_ARESETN) begin
				run_write_time_counter[gvar] <= 1'b0;
				wr_addr_lat[gvar] <= 32'd0;
				wr_data_lat[gvar] <= 32'd0;
				axi_wr_done <= 1'b0; 
				axi_wr_done_pre <= 1'b0;

			end else begin

				if(axi_wr_rq & !axi_wr_rq_prev) begin
					if(gvar == write_tracker) begin
						run_write_time_counter[gvar] <= 1'b1;
						wr_addr_lat[gvar] <= axi_wr_addr; 
					end
				end


				if(run_write_time_counter[gvar]) begin

					if(write_time_counter[gvar] == 11'd1000) begin
						run_write_time_counter[gvar] <= 1'b0;
					end else begin
						run_write_time_counter[gvar] <= 1'b1;
					end
				end


			end

		end
    end

endgenerate

logic fifo_full, fifo_empty;
logic [31:0] fifo_wr_data, fifo_rd_data;
logic push, pop;

logic axi_rd_valid_ack_prev;

sync_fifo inst_axi_sync_fifo(
    .i_clk(M_AXI_ACLK),
    .i_rstn(M_AXI_ARESETN),
    .push(push),
    .pop(pop),
    .push_data(fifo_wr_data),
    .pop_data(fifo_rd_data),
    .fifo_empty(fifo_empty),
    .fifo_full(fifo_full)
);

always_comb begin


	if(|read_time_counter_timeout) begin
	    fifo_wr_data = rd_addr_final;
		push = 1'b1; 
	end else begin
		fifo_wr_data = 32'd0;
		push = 1'b0;
	end

	if(~fifo_empty) begin
		if(axi_rd_valid_ack & !axi_rd_valid_ack_prev)
			pop = 1'b1;
		else 
			pop = 1'b0;
	end else 
		pop = 1'b0;

end

assign axi_rd_data[0] = fifo_rd_data;

   always @(posedge M_AXI_ACLK, negedge M_AXI_ARESETN) begin

       if(!M_AXI_ARESETN) begin
		axi_rd_valid <= 1'b0; 
		axi_rd_data[0] <= 32'd0;
		axi_rd_valid_pre <= 1'b0;
		read_tracker <= 4'd0;
		axi_rd_rq_prev <= 1'b0;
		//axi_rd_rq_ack <= 1'b0;
       end else begin

			axi_rd_valid_ack_prev <= axi_rd_valid_ack;

			axi_rd_rq_prev <= axi_rd_rq;

        	if(axi_rd_rq & !axi_rd_rq_prev) begin
				//axi_rd_rq_ack <= 1'b1;
				read_tracker <= read_tracker+1;
			end


			if(axi_rd_valid_ack & !axi_rd_valid_ack_prev)
				axi_rd_valid <= 1'b0;
			else begin
				if(!fifo_empty)
					axi_rd_valid <= 1'b1;
			end

       end
   end


   always @(posedge M_AXI_ACLK, negedge M_AXI_ARESETN) begin

       if(!M_AXI_ARESETN) begin
		axi_wr_done <= 1'b0; 
		axi_wr_done_pre <= 1'b0;
		write_tracker <= 4'd0;
		axi_wr_rq_prev <= 1'b0;
		axi_wr_rq_ack <= 1'b0;

       end else begin

			axi_wr_rq_prev <= axi_wr_rq;

        	if(axi_wr_rq & !axi_wr_rq_prev) begin
				axi_wr_rq_ack <= 1'b1;
				write_tracker <= write_tracker+1;
			end

			if(!axi_wr_rq) 
				axi_wr_rq_ack <= 1'b0;
		
			if(|write_time_counter_timeout) begin

                memory[wr_addr_final] <= wr_data_final; 
                axi_wr_done_pre <= 1'b1; 

			end else begin
				axi_wr_done_pre <=1'b0;
			end

			if(axi_wr_done_pre) begin
				axi_wr_done <= 1'b1;
			end else begin
				if(axi_wr_done_ack)
					axi_wr_done <= 1'b0;
			end


       end
   end


endmodule
