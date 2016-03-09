`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    07:42:24 11/15/2015 
// Design Name: 
// Module Name:    MemoryController 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module MemoryController(
	input clk,
	input rst,

	input DataRequest,
	output CacheEnough,
	
	output reg WrInitStreamData,
	output reg [LENGTH_ARRAY_WIDTH_BIT-1:0] AddrInitStreamData,
	output reg [DATA_INDEX_WIDTH-1:0] InitStreamData,
	
	output reg WrInitHash,
	output reg [LENGTH_HASH_ARRAY_WIDTH_BIT-1:0] AddrInitHashOccurr,
	output reg [DATA_INDEX_WIDTH*2-1:0] InitHashOccurr
);
	 
//Define parameter//
parameter LENGTH_ARRAY = 100;
parameter NUM_PROCESSOR = 3;
parameter DATA_INDEX_WIDTH = 32;
parameter BIT_ON_TAILS = 7;

localparam integer NUM_STATE_WIDTH_BIT = log2(NUM_STATE);
localparam integer LENGTH_ARRAY_WIDTH_BIT = log2(LENGTH_ARRAY);
localparam integer LENGTH_HASH_ARRAY = 1 << BIT_ON_TAILS;
localparam integer LENGTH_HASH_ARRAY_WIDTH_BIT = log2((1 << BIT_ON_TAILS + 1));
localparam integer MASK = (1 << BIT_ON_TAILS) - 1;
localparam integer NUM_STATE = 6;

function [31:0] log2;
	input [31:0] value;
	integer l;
	begin
		log2 = 0;
		for (l = 0; (1<<l) < value; l = l + 1)
			log2 = l+1;
	end
endfunction

reg [31:0] br_dout[0:99];
				
initial 
begin
	br_dout[0] =   514;
	br_dout[1] =    39;
	br_dout[2] =   608;
	br_dout[3] =   341;
	br_dout[4] =   294;
	br_dout[5] =   571;
	br_dout[6] =   940;
	br_dout[7] =   505;
	br_dout[8] =   650;
	br_dout[9] =   583;
	br_dout[10] =   832;
	br_dout[11] =   221;
	br_dout[12] =   886;
	br_dout[13] =    91;
	br_dout[14] =   404;
	br_dout[15] =   857;
	br_dout[16] =   506;
	br_dout[17] =   895;
	br_dout[18] =   784;
	br_dout[19] =   829;
	br_dout[20] =   470;
	br_dout[21] =   891;
	br_dout[22] =   948;
	br_dout[23] =   665;
	br_dout[24] =   370;
	br_dout[25] =   791;
	br_dout[26] =   712;
	br_dout[27] =    37;
	br_dout[28] =   918;
	br_dout[29] =   827;
	br_dout[30] =   476;
	br_dout[31] =   785;
	br_dout[32] =    74;
	br_dout[33] =   727;
	br_dout[34] =   888;
	br_dout[35] =   413;
	br_dout[36] =   134;
	br_dout[37] =   299;
	br_dout[38] =   620;
	br_dout[39] =    25;
	br_dout[40] =   530;
	br_dout[41] =   207;
	br_dout[42] =   424;
	br_dout[43] =   125;
	br_dout[44] =   942;
	br_dout[45] =   683;
	br_dout[46] =   956;
	br_dout[47] =   953;
	br_dout[48] =   138;
	br_dout[49] =   999;
	br_dout[50] =   184;
	br_dout[51] =   597;
	br_dout[52] =   422;
	br_dout[53] =   739;
	br_dout[54] =   444;
	br_dout[55] =   865;
	br_dout[56] =   290;
	br_dout[57] =   567;
	br_dout[58] =   864;
	br_dout[59] =   789;
	br_dout[60] =   822;
	br_dout[61] =   955;
	br_dout[62] =   908;
	br_dout[63] =   449;
	br_dout[64] =   690;
	br_dout[65] =   439;
	br_dout[66] =   704;
	br_dout[67] =    61;
	br_dout[68] =   750;
	br_dout[69] =   403;
	br_dout[70] =   388;
	br_dout[71] =   777;
	br_dout[72] =    66;
	br_dout[73] =   903;
	br_dout[74] =   296;
	br_dout[75] =   309;
	br_dout[76] =   942;
	br_dout[77] =   107;
	br_dout[78] =   532;
	br_dout[79] =   121;
	br_dout[80] =   162;
	br_dout[81] =   991;
	br_dout[82] =   152;
	br_dout[83] =   557;
	br_dout[84] =   478;
	br_dout[85] =   163;
	br_dout[86] =   564;
	br_dout[87] =   561;
	br_dout[88] =   602;
	br_dout[89] =    31;
	br_dout[90] =    72;
	br_dout[91] =   485;
	br_dout[92] =   462;
	br_dout[93] =   611;
	br_dout[94] =   884;
	br_dout[95] =   769;
	br_dout[96] =   850;
	br_dout[97] =   303;
	br_dout[98] =   680;
	br_dout[99] =   101;
end

always @(posedge clk)
begin
	if (rst)
		begin
			WrInitStreamData <= 0;
			AddrInitStreamData <= 0;
		end
	else
		begin
			if (DataRequest)
				begin
					if (AddrInitStreamData < LENGTH_ARRAY)
						begin
							InitStreamData <= br_dout[AddrInitStreamData];
							WrInitStreamData <= 1;
							AddrInitStreamData <= AddrInitStreamData + 1;
						end
					else
						begin
							WrInitStreamData <= 0;
						end
				end
			else
				begin
					WrInitStreamData <= 0;
					AddrInitStreamData <= 0;
				end
		end
end

always @(posedge clk)
begin
	if (rst)
		begin
			WrInitHash <= 0;
			
			AddrInitHashOccurr <= 0;
		end
	else
		begin
			if (DataRequest)
				begin
					if (AddrInitHashOccurr < LENGTH_HASH_ARRAY)
						begin
							InitHashOccurr <= 0;
							WrInitHash <= 1;
							AddrInitHashOccurr <= AddrInitHashOccurr + 1;
						end
					else
						begin
							WrInitHash <= 0;
						end
				end
			else
				begin
					WrInitHash <= 0;
					AddrInitHashOccurr <= 0;
				end


		end
end

assign CacheEnough = (AddrInitHashOccurr == LENGTH_HASH_ARRAY);


endmodule
