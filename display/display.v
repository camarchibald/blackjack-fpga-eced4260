/*
Author: Nader Hdeib
Student ID: B00898627
Date: November 25, 2025
File Name: display.v
Description: This is the display module for the blackjack game.
Acknowledgements: 
*/

module display (
    input [1:0] game_state,
    input [3:0] cards_to_display [4:0]
);

    // BCD instance
    bcd 

    always @ (*) 
    begin
        case(game_state)

            2'b00:

        endcase
    end

endmodule

// BCD conversion module
module bcd(
		input wire [3:0] input_char,
		output reg [6:0] segment_output
	);
	
	// The output segment format is ordered as follows: 7'babcedfg
	always @ (*) 
    begin
		case(input_char)
        
			4'b0000: segment_output = 7'b1111110; // 0
			4'b0001: segment_output = 7'b0110000; // 1
			4'b0010: segment_output = 7'b1101101; // 2
			4'b0011: segment_output = 7'b1111001; // 3
			4'b0100: segment_output = 7'b0110011; // 4
			4'b0101: segment_output = 7'b1011011; // 5
			4'b0110: segment_output = 7'b1011111; // 6
			4'b0111: segment_output = 7'b1110000; // 7
			4'b1000: segment_output = 7'b1111111; // 8
			4'b1001: segment_output = 7'b1111011; // 9
            4'b1010: segment_output = 7'b0110111; // H[ouse win]
            4'b1011: segment_output = 7'b1100111; // P[layer win]
            4'b1100: segment_output = 7'b0111110; // d[raw]

		endcase
	end

endmodule