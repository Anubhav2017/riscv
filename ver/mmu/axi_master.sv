`timescale 1 ns / 1 ps

	module my_axi_master #
	(

		// Burst Length. Supports 1, 2, 4, 8, 16, 32, 64, 128, 256 burst lengths
		parameter integer C_M_AXI_BURST_LEN	= 16,
		// Thread ID Width
		parameter integer C_M_AXI_ID_WIDTH	= 1,
		// Width of Address Bus
		parameter integer C_M_AXI_ADDR_WIDTH	= 32,
		// Width of Data Bus
		parameter integer C_M_AXI_DATA_WIDTH	= 32,
		// Width of User Write Address Bus
		parameter integer C_M_AXI_AWUSER_WIDTH	= 0,
		// Width of User Read Address Bus
		parameter integer C_M_AXI_ARUSER_WIDTH	= 0,
		// Width of User Write Data Bus
		parameter integer C_M_AXI_WUSER_WIDTH	= 0,
		// Width of User Read Data Bus
		parameter integer C_M_AXI_RUSER_WIDTH	= 0,
		// Width of User Response Bus
		parameter integer C_M_AXI_BUSER_WIDTH	= 0
	)
	(
		// Initiate AXI transactions
		input wire  start_write_txn,
        input wire [C_M_AXI_ADDR_WIDTH-1:0] write_base_addr,
        input wire [C_M_AXI_DATA_WIDTH*C_M_AXI_BURST_LEN-1:0] write_data,

        input wire start_read_txn,
        input wire [C_M_AXI_ADDR_WIDTH-1:0] read_base_addr,
		
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

	logic [C_M_AXI_DATA_WIDTH-1:0] write_data_array[C_M_AXI_BURST_LEN];

	always_comb begin 
		integer i;
		for(i=0;i<C_M_AXI_BURST_LEN;i++) 
			write_data_array[i] = write_data[i*C_M_AXI_DATA_WIDTH+:C_M_AXI_DATA_WIDTH];
	end
//write fsm

	parameter [1:0] WRITE_IDLE = 2'b00,
		WRITE_ADDR  = 2'b01,
		WRITE_DATA = 2'b10,
        WRITE_RESP = 2'b11;

    reg [1:0] write_fsm_state;
    reg [7:0] write_data_counter;

    always @(posedge M_AXI_ACLK, negedge M_AXI_ARESETN) begin

        if(!M_AXI_ARESETN) begin
            write_fsm_state <= WRITE_IDLE;
            write_data_counter <= 8'd0;

        end else begin
            if(write_fsm_state == WRITE_IDLE) begin
                write_data_counter <= 8'd0;
                if(start_write_txn) begin
                    write_fsm_state <= WRITE_ADDR;
            
                end 
            end else if(write_fsm_state == WRITE_ADDR) begin
                write_data_counter <= 8'd0;

                if(M_AXI_AWREADY==1'b1) begin
                    write_fsm_state <= WRITE_DATA;
                end

            end else if(write_fsm_state == WRITE_DATA) begin
                
                if(M_AXI_WREADY == 1'b1) begin
                    if(write_data_counter < C_M_AXI_BURST_LEN-1) begin 
                        write_data_counter <= write_data_counter+1;
						write_fsm_state <= WRITE_DATA;
					end else begin
                        write_data_counter <= 8'd0;
                        write_fsm_state <= WRITE_RESP;
					end
                end


            end else begin
                
                if(M_AXI_BVALID == 1'b1) begin

                    if(M_AXI_BRESP == 2'b00) begin
                        write_fsm_state <= WRITE_IDLE;
                    end else begin
                        write_fsm_state <= WRITE_ADDR;
                    end
                end


            end

        end

    end
	assign M_AXI_WDATA = write_data_array[write_data_counter];
	assign M_AXI_AWADDR = write_base_addr;
    always @(*) begin
        if(write_fsm_state == WRITE_IDLE) begin
            M_AXI_AWVALID = 1'b0;
            M_AXI_WVALID = 1'b0;
            M_AXI_BREADY = 1'b0;
        end else if(write_fsm_state == WRITE_ADDR) begin
            M_AXI_AWVALID = 1'b1;
            M_AXI_WVALID = 1'b0;
            M_AXI_BREADY = 1'b0;
        end else if(write_fsm_state == WRITE_DATA) begin
            M_AXI_AWVALID = 1'b0;
            M_AXI_WVALID = 1'b1;
            M_AXI_BREADY = 1'b0;
        end else begin
            M_AXI_AWVALID = 1'b0; 
            M_AXI_WVALID = 1'b0;
            M_AXI_BREADY = 1'b1;      
        end

		if((write_fsm_state == WRITE_DATA)&(write_data_counter == C_M_AXI_BURST_LEN-1))
			M_AXI_WLAST = 1'b1;
		else
			M_AXI_WLAST = 1	'b0;

    end

	assign M_AXI_WSTRB = 4'hF;

	assign M_AXI_ARBURST = 2'b01;
	assign M_AXI_ARCACHE = 4'd0;
	assign M_AXI_ARID = 1'b0;
	assign M_AXI_AWLEN = C_M_AXI_BURST_LEN-1;
	assign M_AXI_ARLEN = C_M_AXI_BURST_LEN-1;
	assign M_AXI_ARLOCK = 1'b0;
	assign M_AXI_ARPROT = 3'b0;

	assign M_AXI_ARQOS = 4'b0;
	assign M_AXI_ARSIZE = 4'b0010;
	assign M_AXI_AWSIZE = 4'b0010;
	assign M_AXI_ARUSER = 1'b0;
	assign M_AXI_AWBURST = 2'b01;
	assign M_AXI_AWCACHE = 4'b0;
	assign M_AXI_AWID = 1'b0;
	assign M_AXI_AWLOCK = 1'b0;
	assign M_AXI_AWPROT = 3'b0;
	assign M_AXI_AWQOS = 4'b0;
	assign M_AXI_AWUSER = 1'b0;


	parameter [1:0] READ_IDLE = 2'b00,
		READ_ADDR  = 2'b01,
		READ_DATA = 2'b10,
		READ_RESP = 2'b11;

	reg [1:0] read_fsm_state;
	logic [7:0] read_data_counter;

	logic [C_M_AXI_DATA_WIDTH-1:0] read_data_array[C_M_AXI_BURST_LEN];
	
	always @(posedge M_AXI_ACLK, negedge M_AXI_ARESETN) begin

		if(!M_AXI_ARESETN) begin

			read_fsm_state <= READ_IDLE;
			read_data_counter <= 8'd0;

		end else begin

			if(read_fsm_state == READ_IDLE) begin

				read_data_counter <= 8'b0;

				if(start_read_txn) begin
					read_fsm_state <= READ_ADDR;
				end
            end else if(read_fsm_state == READ_ADDR) begin
                read_data_counter <= 8'd0;

                if(M_AXI_ARREADY==1'b1) begin
                    read_fsm_state <= READ_DATA;
                end

            end else if(read_fsm_state == READ_DATA) begin
                
                if(M_AXI_RVALID == 1'b1) begin
                    if(M_AXI_RLAST==1'b0) begin 
                        read_data_counter <= read_data_counter+1;
						read_fsm_state <= READ_DATA;
					end else begin
						read_fsm_state <= READ_IDLE;

					end
				end else
					read_fsm_state <= READ_DATA;

			end else begin
				read_fsm_state <= READ_IDLE;
			end

		end

	end


	always @(*) begin

		case(read_fsm_state)

			READ_IDLE: begin

				M_AXI_ARVALID=1'b0;
				M_AXI_ARADDR = 32'b0;
				M_AXI_RREADY = 1'b0;

			end

			READ_ADDR: begin
				M_AXI_ARVALID = 1'b1;
				M_AXI_ARADDR = read_base_addr;
				M_AXI_RREADY = 1'b0;
			end

			READ_DATA: begin

				M_AXI_ARVALID = 1'b0;
				M_AXI_ARADDR= read_base_addr;
				M_AXI_RREADY = 1'b1;

			end

			default: begin

				M_AXI_ARVALID = 1'b0;
				M_AXI_ARADDR = 32'b0;
				M_AXI_RREADY = 1'b0;

			end

		endcase

	end

	always @(posedge M_AXI_ACLK, negedge M_AXI_ARESETN) begin

		if(!M_AXI_ARESETN) begin
			read_data_array <= '{default:'0};		
		end else begin

			if(read_fsm_state == READ_DATA) begin
				if(M_AXI_RVALID == 1'b1) begin
					read_data_array[read_data_counter] <= M_AXI_RDATA;
				end
			end
		end

	end





	endmodule
