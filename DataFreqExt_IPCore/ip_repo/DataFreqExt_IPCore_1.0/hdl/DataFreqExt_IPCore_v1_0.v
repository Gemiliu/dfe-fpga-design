
`timescale 1 ps / 1 ps

	module DataFreqExt_IP_v1_0 #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Slave Bus Interface S_AXI
		parameter integer C_S_AXI_DATA_WIDTH	= 32,
		parameter integer C_S_AXI_ADDR_WIDTH	= 7
	)
	(
		// Users to add ports here
        output [31:0] br_memory_addr,
        output br_memory_clk,
        output [31:0] br_memory_din,
        input [31:0] br_memory_dout,
        output br_memory_en,
        output br_memory_rst,
        output [3:0] br_memory_we,
		
        output [31:0] br_NormHash_addr,
        output br_NormHash_clk,
        output [31:0] br_NormHash_din,
        input [31:0] br_NormHash_dout,
        output br_NormHash_en,
        output br_NormHash_rst,
        output [3:0] br_NormHash_we,
        
        output [31:0] br_NormOccurr_addr,
        output br_NormOccurr_clk,
        output [31:0] br_NormOccurr_din,
        input [31:0] br_NormOccurr_dout,
        output br_NormOccurr_en,
        output br_NormOccurr_rst,
        output [3:0] br_NormOccurr_we,
        
        output [31:0] br_NormCollision_addr,
        output br_NormCollision_clk,
        output [31:0] br_NormCollision_din,
        input [31:0] br_NormCollision_dout,
        output br_NormCollision_en,
        output br_NormCollision_rst,
        output [3:0] br_NormCollision_we,
        
        output [31:0] br_ClamHash_addr,
        output br_ClamHash_clk,
        output [31:0] br_ClamHash_din,
        input [31:0] br_ClamHash_dout,
        output br_ClamHash_en,
        output br_ClamHash_rst,
        output [3:0] br_ClamHash_we,
        
        output [31:0] br_ClamOccurr_addr,
        output br_ClamOccurr_clk,
        output [31:0] br_ClamOccurr_din,
        input [31:0] br_ClamOccurr_dout,
        output br_ClamOccurr_en,
        output br_ClamOccurr_rst,
        output [3:0] br_ClamOccurr_we,
        
        output [31:0] br_ClamCollision_addr,
        output br_ClamCollision_clk,
        output [31:0] br_ClamCollision_din,
        input [31:0] br_ClamCollision_dout,
        output br_ClamCollision_en,
        output br_ClamCollision_rst,
        output [3:0] br_ClamCollision_we,
		// User ports ends
		// Do not modify the ports beyond this line


		// Ports of Axi Slave Bus Interface S_AXI
		input wire  s_axi_aclk,
		input wire  s_axi_aresetn,
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] s_axi_awaddr,
		input wire [2 : 0] s_axi_awprot,
		input wire  s_axi_awvalid,
		output wire  s_axi_awready,
		input wire [C_S_AXI_DATA_WIDTH-1 : 0] s_axi_wdata,
		input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] s_axi_wstrb,
		input wire  s_axi_wvalid,
		output wire  s_axi_wready,
		output wire [1 : 0] s_axi_bresp,
		output wire  s_axi_bvalid,
		input wire  s_axi_bready,
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] s_axi_araddr,
		input wire [2 : 0] s_axi_arprot,
		input wire  s_axi_arvalid,
		output wire  s_axi_arready,
		output wire [C_S_AXI_DATA_WIDTH-1 : 0] s_axi_rdata,
		output wire [1 : 0] s_axi_rresp,
		output wire  s_axi_rvalid,
		input wire  s_axi_rready
	);
// Instantiation of Axi Bus Interface S_AXI
	DataFreqExt_IP_v1_0_S_AXI # ( 
		.C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
		.C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH)
	) DataFreqExt_IP_v1_0_S_AXI_inst (
        .br_memory_addr(br_memory_addr),
        .br_memory_clk(br_memory_clk),
        .br_memory_din(br_memory_din),
        .br_memory_dout(br_memory_dout),
        .br_memory_en(br_memory_en),
        .br_memory_rst(br_memory_rst),
        .br_memory_we(br_memory_we),
	
        .br_NormHash_addr(br_NormHash_addr),
        .br_NormHash_clk(br_NormHash_clk),
        .br_NormHash_din(br_NormHash_din),
        .br_NormHash_dout(br_NormHash_dout),
        .br_NormHash_en(br_NormHash_en),
        .br_NormHash_rst(br_NormHash_rst),
        .br_NormHash_we(br_NormHash_we),
        
        .br_NormOccurr_addr(br_NormOccurr_addr),
        .br_NormOccurr_clk(br_NormOccurr_clk),
        .br_NormOccurr_din(br_NormOccurr_din),
        .br_NormOccurr_dout(br_NormOccurr_dout),
        .br_NormOccurr_en(br_NormOccurr_en),
        .br_NormOccurr_rst(br_NormOccurr_rst),
        .br_NormOccurr_we(br_NormOccurr_we),
        
        .br_NormCollision_addr(br_NormCollision_addr),
        .br_NormCollision_clk(br_NormCollision_clk),
        .br_NormCollision_din(br_NormCollision_din),
        .br_NormCollision_dout(br_NormCollision_dout),
        .br_NormCollision_en(br_NormCollision_en),
        .br_NormCollision_rst(br_NormCollision_rst),
        .br_NormCollision_we(br_NormCollision_we),
        
        .br_ClamHash_addr(br_ClamHash_addr),
        .br_ClamHash_clk(br_ClamHash_clk),
        .br_ClamHash_din(br_ClamHash_din),
        .br_ClamHash_dout(br_ClamHash_dout),
        .br_ClamHash_en(br_ClamHash_en),
        .br_ClamHash_rst(br_ClamHash_rst),
        .br_ClamHash_we(br_ClamHash_we),
        
        .br_ClamOccurr_addr(br_ClamOccurr_addr),
        .br_ClamOccurr_clk(br_ClamOccurr_clk),
        .br_ClamOccurr_din(br_ClamOccurr_din),
        .br_ClamOccurr_dout(br_ClamOccurr_dout),
        .br_ClamOccurr_en(br_ClamOccurr_en),
        .br_ClamOccurr_rst(br_ClamOccurr_rst),
        .br_ClamOccurr_we(br_ClamOccurr_we),
        
        .br_ClamCollision_addr(br_ClamCollision_addr),
        .br_ClamCollision_clk(br_ClamCollision_clk),
        .br_ClamCollision_din(br_ClamCollision_din),
        .br_ClamCollision_dout(br_ClamCollision_dout),
        .br_ClamCollision_en(br_ClamCollision_en),
        .br_ClamCollision_rst(br_ClamCollision_rst),
        .br_ClamCollision_we(br_ClamCollision_we),
        
		.S_AXI_ACLK(s_axi_aclk),
		.S_AXI_ARESETN(s_axi_aresetn),
		.S_AXI_AWADDR(s_axi_awaddr),
		.S_AXI_AWPROT(s_axi_awprot),
		.S_AXI_AWVALID(s_axi_awvalid),
		.S_AXI_AWREADY(s_axi_awready),
		.S_AXI_WDATA(s_axi_wdata),
		.S_AXI_WSTRB(s_axi_wstrb),
		.S_AXI_WVALID(s_axi_wvalid),
		.S_AXI_WREADY(s_axi_wready),
		.S_AXI_BRESP(s_axi_bresp),
		.S_AXI_BVALID(s_axi_bvalid),
		.S_AXI_BREADY(s_axi_bready),
		.S_AXI_ARADDR(s_axi_araddr),
		.S_AXI_ARPROT(s_axi_arprot),
		.S_AXI_ARVALID(s_axi_arvalid),
		.S_AXI_ARREADY(s_axi_arready),
		.S_AXI_RDATA(s_axi_rdata),
		.S_AXI_RRESP(s_axi_rresp),
		.S_AXI_RVALID(s_axi_rvalid),
		.S_AXI_RREADY(s_axi_rready)
	);

	// Add user logic here

	// User logic ends

	endmodule
