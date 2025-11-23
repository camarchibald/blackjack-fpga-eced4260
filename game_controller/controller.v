/*
Author: Nader Hdeib
Student ID: B00898627
Date: November 20, 2025
File Name: controller.v
Description: This is the main blackjack game controller.
Acknowledgements: 
*/

module controller (
    input clk,
    input rst
);

    // State parameters
    parameter S0	= 4'b0000;
	parameter S1	= 4'b0001;
	parameter S2	= 4'b0010;
	parameter S3 	= 4'b0011;
	parameter S4 	= 4'b0100;
	parameter S5 	= 4'b0101;
    parameter S6 	= 4'b0110;
    parameter S7 	= 4'b0111;
    parameter S8 	= 4'b1000;
    parameter S9 	= 4'b1001;
    parameter S10 	= 4'b1010;
    parameter S11 	= 4'b1011;
    parameter S12 	= 4'b1100;
    parameter S13 	= 4'b1101;
    parameter S14 	= 4'b1110;
    parameter S15 	= 4'b1111;

    // 4 bit FSM state register
    reg [3:0] state = S0;

    // Deck module control signals
    reg shuffle_start, card_start;
    wire shuffle_ready, card_ready, card_overflow, shuffling;

    // Deck module data registers
    wire [3:0] card;
    reg [5:0] seed;

    // Sum registers
    reg [5:0] player_sum_r, house_sum_r;

    // Sum output
    wire [5:0] player_sum_w, house_sum_w;

    // Adder module control signals
    reg player_select, house_select;

    // Comparator module control signals
    reg val1_player, val1_house, val2_player, val2_house, val2_21, val2_17;
    wire cp_eq, cp_gt, cp_lt;

    // Display module control signals
    wire display_ready;
    reg [2:0] game_state;

    // Deck instantiation
    deck deck_instance(
        .clk(clk),
        .shuffle_start(shuffle_start),
        .shuffle_ready(shuffle_ready),
        .seed(seed),
        .card_start(card_start),
        .card_ready(card_ready),
        .card(card),
        .card_overflow(card_overflow)
    );

    // Adder instantiation
    adder adder_instance(
        .card(card),
        .player_input(player_sum_r),
        .house_input(house_sum_r),
        .player_output(player_sum_w),
        .house_output(house_sum_w),
        .player_select(player_select),
        .house_select(house_select)
    );

    // Comparator instantiation
    comparator comparator_instance(
        .player_input(player_sum_r),
        .house_input(house_sum_r),
        .val1_player(val1_player),
        .val1_house(val2_player),
        .val2_player(val2_player),
        .val2_house(val2_house),
        .val2_21(val2_21),
        .val2_17(val2_17),
        .eq(cp_eq),
        .gt(cp_gt),
        .lt(cp_lt)
    );

    // Main FSM
    always @ (posedge clk or posedge rst) begin
        
        /// If reset pin is high, go to S0
        if (rst) 
        begin
            state <= S0;
        end

        else 
        begin

            // Logic for remaining cases
            case(state)

                S0:
                    if(!rst) begin
                        shuffle_start <= 1;
                        state <= S1;
                    end

                S1:
                    if(!shuffle_ready) begin
                        shuffle_start <= 0;
                        state <= S2;
                    end

                S2:
                    if(shuffle_ready /*& user_start_game*/) begin // TODO: Implement user start game signal
                        state <= S3;
                    end
                
                S3:
                    state <= S3;


            endcase
        end

    end

endmodule