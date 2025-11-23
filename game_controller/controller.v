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
    input rst,
    input user_ready_to_begin
);

    // State parameters
    parameter S_RESET	            = 4'b0000; // Reset state
	parameter S_SHUFFLE_START	    = 4'b0001; // Shuffle start send
	parameter S_SHUFFLE_DONE	    = 4'b0010; // Shuffle done
	parameter S_GAME_START 	        = 4'b0011; // Game start
	parameter S_CARD_START_HOUSE 	= 4'b0100;
	parameter S_GETTING_CARD_HOUSE 	= 4'b0101;
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

    // User inputs
    reg user_ready_to_begin_r;

    // 4 bit FSM state register
    reg [3:0] state = S_RESET;

    // Deck module control signals
    reg shuffle_start = 0, card_start = 0;
    wire shuffle_ready, card_ready, card_overflow, shuffling;

    // Deck module data registers
    wire [3:0] card;
    reg [5:0] seed = 5'b01010;

    // Sum registers
    reg [5:0] player_sum_r = 6'b000000, house_sum_r = 6'b000000;

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

    // Assign I/O
    assign user_ready_to_begin_r = user_ready_to_begin;

    // Main FSM
    always @ (posedge clk or posedge rst) begin
        
        // If reset pin is high, go to S0
        if (rst) 
        begin
            state <= S_RESET;
            house_sum_r = 6'b000000;
            player_sum_r = 6'b000000;
        end

        else 
        begin

            // Logic for remaining cases
            case(state)

                S_RESET: // Reset state
                    if(!rst) begin
                        state <= S_SHUFFLE_START;
                    end

                S_SHUFFLE_START: // Shuffle start send
                    if(shuffle_ready) begin
                        shuffle_start <= 1;
                    end
                    else if (!shuffle_ready) begin
                        shuffle_start <= 0;
                        state <= S_SHUFFLE_DONE;
                    end 

                S_SHUFFLE_DONE: // Shuffle done
                    if(shuffle_ready & user_ready_to_begin_r) begin
                        state <= S_GAME_START;
                    end
                
                S_GAME_START: // Game start
                    if(!user_ready_to_begin_r) begin
                        card_start <= 1;
                        state <= S_CARD_START_HOUSE;
                    end
                
                S_CARD_START_HOUSE:
                    if(card_ready) begin
                       card_start <= 0;
                       state <= S_GETTING_CARD_HOUSE; 
                    end
                S_GETTING_CARD_HOUSE:
                    state <= S_GETTING_CARD_HOUSE;

            endcase
        end

    end

endmodule