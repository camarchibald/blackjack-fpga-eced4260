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
    reg card_overflow, shuffling, card_ready, shuffle_ready, shuffle_start, card_start;

    // Deck module data registers
    reg [3:0] card;
    reg [5:0] seed;

    // Sum registers
    reg [5:0] player_sum, house_sum;

    // Adder module control signals
    reg player_select, house_select;

    // Comparator module control signals
    reg val1_player, val1_house, val2_player, val2_house, val2_21, val2_17, cp_eq, cp_gt, cp_let;

    // Display module control signals
    wire display_ready;
    register [2:0] game_state;

    // Deck instantiation
    deck deck_instance(
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
        .player_input(player_sum),
        .house_input(house_sum),
        .player_output(player_sum),
        .house_output(house_sum),
        .player_select(player_select),
        .house_select(house_select)
    );

    // Comparator instantiation
    comparator comparator_instance(
        .player_input(player_sum),
        .house_input(house_sum),
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

                S_SHUFFLE_START:
                    // assert shuffle deck control signal
                    // read deck shuffling control signal
                        // if deck shuffling control signal is high, go to SHUFFLING state
                S_SHUFFLING:
                    // read deck_shuffling control signal
                        // if deck shuffling control signal is low, set shuffle ready register and light shuffle LED
                        // if user pressed start after LED, go to DEAL_START state
                S_DEAL_START:
                    // read start button
                        // if start button is still asserted by used remain here
                        // else set card_start control signal
                S_CARD_START_HOUSE_PREGAME:
                S_GETTING_CARD_HOUSE:
                S_ADD_HOUSE_PREGAME:
                S_CARD_START_PLAYER_PREGAME:
                S_GETTING_CARD_PLAYER:
                S_ADD_PLAYER_PREGAME:
                S_DEAL_DONE_CHECK:
                S_PLAY_START:
                S_PLAYER_HIT:
                S_PLAYER_STAND:
                S_CARD_START_PLAYER_INGAME:
                S_GETTING_CARD_PLAYER_INGAME:
                S_ADD_PLAYER_INGAME:
                S_CHECK_PLAYER_BUST:
                S_CHECK_HOUSE_HIT:
                S_CARD_START_HOUSE_INGAME:
                S_GETTING_CARD_HOUSE_INGAME:
                S_CHECK_BUST_HOUSE:
                S_DETERMINE_WINNER:

            endcase
        end

    end

endmodule