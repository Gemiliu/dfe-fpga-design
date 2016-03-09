`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:45:45 01/04/2016 
// Design Name: 
// Module Name:    IncModulus 
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
module IncModulus(
	input [DATA_INDEX_WIDTH-1:0] PreModulus,
	output [DATA_INDEX_WIDTH-1:0] NxtModulus
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

assign NxtModulus = (PreModulus < (LENGTH_HASH_ARRAY-1)) ? PreModulus + 1 : 0;

endmodule
