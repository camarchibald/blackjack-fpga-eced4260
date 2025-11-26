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
    input user_ready_to_begin,
    input hit,
    input stand,
    input [5:0] seed,               // Seed input switches
    input hand_select,              // Display deck control switch
    output [1:0] game_outcome,      // Winner outcome LED's
    output [4:0] state_out,         // FSM state LED's
    output [1:0] game_state_out,    // Gamse state LED's
    output [6:0] hand_display_0,    // Hand display on 7-segment displays
    output [6:0] hand_display_1,
    output [6:0] hand_display_2,
    output [6:0] hand_display_3,
    output [6:0] hand_display_4,
    output [6:0] hand_display_5
);
    // State parameters
    parameter S_RESET	            = 5'b00000; // 0
	parameter S_SHUFFLE_START	    = 5'b00001; // 1
	parameter S_SHUFFLE_WAIT	    = 5'b00010; // 2
	parameter S_DEAL_START 	        = 5'b00011; // 3
	parameter S_CARD_START_PLAYER 	= 5'b00100; // 4
	parameter S_GETTING_CARD_PLAYER = 5'b00101; // 5
    parameter S_ADD_PLAYER 	        = 5'b00110; // 6
    parameter S_CARD_START_HOUSE 	= 5'b00111; // 7
    parameter S_GETTING_CARD_HOUSE 	= 5'b01000; // 8
    parameter S_ADD_HOUSE 	        = 5'b01001; // 9
    parameter S_PLAY_START 	        = 5'b01010; // 10
    parameter S_PLAYER_HIT 	        = 5'b01011; // 11
    parameter S_PLAYER_STAND 	    = 5'b01100; // 12
    parameter S_CP_HOUSE_HIT 	    = 5'b01101; // 13
    parameter S_CP_PLAYER_BUST      = 5'b01110; // 14
    parameter S_CP_HOUSE_BUST 	    = 5'b01111; // 15
    parameter S_CP_WINNER           = 5'b10000; // 16
    parameter S_HOUSE_PLAY          = 5'b10001; // 17
    parameter S_CHECK_PLAYER_BUST   = 5'b10010; // 18
    parameter S_HOUSE_WIN           = 5'b10011; // 19
    parameter S_PLAYER_WIN          = 5'b10100; // 20
    parameter S_DRAW                = 5'b10101; // 21
    parameter S_WINNER_OUTPUT       = 5'b10110; // 22

    // Game parameters
    parameter DEALING_ROUND_1       = 2'b00;    // 0
    parameter DEALING_ROUND_2       = 2'b01;    // 1
    parameter PLAYING               = 2'b10;    // 2
    parameter PLAY_DONE             = 2'b11;    // 3

    // User inputs
    reg user_ready_to_begin_r, stand_r, hit_r;

    // Main FSM state register
    reg [4:0] state = S_RESET;
    assign state_out = state;

    // Game state register
    reg [1:0] game_state = DEALING_ROUND_1;
    assign game_state_out = game_state;

    // Outcome of game
    reg [1:0] outcome = 2'b00;
    assign game_outcome = outcome;

    // Deck module control signals
    reg shuffle_start = 0, card_start = 0;
    wire shuffle_ready, card_ready, card_overflow, shuffling;

    // Deck module data registers
    wire [3:0] card;

    // Sum registers
    reg [5:0] player_sum_r = 6'b000000, house_sum_r = 6'b000000;

    // Player and house hands
    reg [3:0] player_hand [4:0];    // Array of 5 4-bit cards 
    reg [3:0] house_hand [4:0];     // Array of 5 4-bit cards

    reg [2:0] player_hand_index = 3'b000, house_hand_index = 3'b000;

    // Sum output
    wire [5:0] player_sum_w, house_sum_w;

    // Adder module control signals
    reg player_select, house_select;

    // Comparator module control signals
    reg val1_player = 0, val1_house = 0, val2_player = 0, val2_house = 0, val2_21 = 0, val2_17 = 0;
    wire cp_eq, cp_gt, cp_lt;

    // Display module control signals
    reg [3:0] bcd_hand [4:0];
    reg [3:0] bcd_char;

    // Display control logics
    always @ (hand_select or player_hand or house_hand or rst)
    begin
        if(!hand_select) begin // Display player hand
            bcd_char <= 4'b1111;
            bcd_hand[0] <= player_hand[0];
            bcd_hand[1] <= player_hand[1];
            bcd_hand[2] <= player_hand[2];
            bcd_hand[3] <= player_hand[3];
            bcd_hand[4] <= player_hand[4];

        end
        else begin // Display house hand
            bcd_char <= 4'b1110;
            bcd_hand[0] <= house_hand[0];
            bcd_hand[1] <= house_hand[1];
            bcd_hand[2] <= house_hand[2];
            bcd_hand[3] <= house_hand[3];
            bcd_hand[4] <= house_hand[4];
        end
    end

    // Display instantiation
    bcd bcd_6(
		.input_char(bcd_char),
		.segment_output(hand_display_5)
	);
    bcd bcd_5(
		.input_char(bcd_hand[4]),
		.segment_output(hand_display_4)
	);
    bcd bcd_4(
		.input_char(bcd_hand[3]),
		.segment_output(hand_display_3)
	);
    bcd bcd_3(
		.input_char(bcd_hand[2]),
		.segment_output(hand_display_2)
	);
    bcd bcd_2(
		.input_char(bcd_hand[1]),
		.segment_output(hand_display_1)
	);
    bcd bcd_1(
		.input_char(bcd_hand[0]),
		.segment_output(hand_display_0)
	);

    // Deck instantiation
    deck deck_instance(
        .reset(!rst),
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
        .reset(!rst),
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
        .val1_house(val1_house),
        .val2_player(val2_player),
        .val2_house(val2_house),
        .val2_21(val2_21),
        .val2_17(val2_17),
        .eq(cp_eq),
        .gt(cp_gt),
        .lt(cp_lt)
    );

    // Main FSM
    always @ (posedge clk or negedge rst) begin
        
        // Assign IO registers at clock
        user_ready_to_begin_r <= user_ready_to_begin;
        hit_r <= hit;
        stand_r <= stand;

        // Reset button is pressed, reset registers and go to first state
        if (!rst)
        begin
            state <= S_RESET;
            game_state <= DEALING_ROUND_1;
            house_sum_r <= 6'b000000;
            player_sum_r <= 6'b000000;
            house_hand_index <= 3'b000;
            player_hand_index <= 3'b000;

            house_hand[0] <= 4'b0000;
            house_hand[1] <= 4'b0000;
            house_hand[2] <= 4'b0000;
            house_hand[3] <= 4'b0000;
            house_hand[4] <= 4'b0000;

            player_hand[0] <= 4'b0000;
            player_hand[1] <= 4'b0000;
            player_hand[2] <= 4'b0000;
            player_hand[3] <= 4'b0000;
            player_hand[4] <= 4'b0000;

        end

        else 
        begin

            // Logic for remaining cases
            case(state)

                S_RESET:
                    // Reset button has been released
                    if(rst) begin
                        // Next state is shuffle start state
                        state <= S_SHUFFLE_START;
                        outcome <= 2'b00;
                    end

                S_SHUFFLE_START:
                    // Shuffle ready is high, deck is ready to be shuffled
                    if(shuffle_ready) begin
                        // Send shuffle start command
                        shuffle_start <= 1;
                    end
                    // Shuffle ready is low, deck is currently shuffling cards
                    else if (!shuffle_ready) begin
                        // Reset shuffle start command
                        shuffle_start <= 0;
                        // Next state waits for shuffle to complete (shuffle_ready to go high again)
                        state <= S_SHUFFLE_WAIT;    // Go to shuffle wait state
                    end 

                S_SHUFFLE_WAIT:
                    // If shuffle is complete and user has pressed start button
                    if(shuffle_ready && !user_ready_to_begin_r) begin
                        // Next state is start of dealing
                        state <= S_DEAL_START;
                    end
                
                S_DEAL_START:
                    // User has released start button
                    if(user_ready_to_begin_r && card_ready) begin
                        // Send card start command
                        card_start <= 1;
                        // Next state is getting card for player
                        state <= S_CARD_START_PLAYER;
                    end
                
                S_CARD_START_PLAYER:
                    // Deck module is dispensing a card
                    if(!card_ready) begin
                        // Reset card start command
                        card_start <= 0;
                        // Next state is getting card for player
                        state <= S_GETTING_CARD_PLAYER;
                    end
                
                S_GETTING_CARD_PLAYER:
                    // Card has been dispensed
                    if(card_ready) begin
                        // Set player select line for adder
                        player_select <= 1;
                        // Next state is adding to player sum
                        state <= S_ADD_PLAYER;
                    end

                S_ADD_PLAYER:
                    begin
                        // Store dealt card in player hand
                        player_hand[player_hand_index] <= card;
                        // Increment player hand index
                        player_hand_index <= player_hand_index + 3'b001;
                        // Store player sum from adder output
                        player_sum_r <= player_sum_w;
                        // Reset adder player select signal
                        player_select <= 0;
                        // If in dealing stage, no need to compare at this point
                        if(game_state == DEALING_ROUND_1 || game_state == DEALING_ROUND_2) begin
                            // Get the next deal card for the house
                            card_start <= 1;
                            state <= S_CARD_START_HOUSE;
                        end
                        // If in playing phase of game, compare player sum to bust
                        else if (game_state == PLAYING) begin
                            // Set comparator value 1
                            val1_player <= 1;
                            // Set comparator value 2s
                            val2_21 <= 1;
                                // Next state is comparing player sum to bust
                            state <= S_CP_PLAYER_BUST;
                        end
                    end

                S_CARD_START_HOUSE:
                    // Deck module is dispensing a card
                    if(!card_ready) begin
                        // Reset card start command
                        card_start <= 0;
                        // Next state is waiting for card for house
                        state <= S_GETTING_CARD_HOUSE;
                    end

                S_GETTING_CARD_HOUSE:
                    // Card ready signal is high again (deck has dispensed card)
                    if(card_ready) begin
                        // Select house register as adder input
                        house_select <= 1;
                        // Next state is adding to house register
                        state <= S_ADD_HOUSE;
                    end
                
                S_ADD_HOUSE:
                    begin
                        // Store card in house hand
                        house_hand[house_hand_index] <= card;
                        // Increment index for house hand
                        house_hand_index <= house_hand_index + 3'b001;
                        // Store house sum from adder output
                        house_sum_r <= house_sum_w;
                        // Reset house select signal for adder
                        house_select <= 0;
                        // If in the first dealing phase of the game
                        if(game_state == DEALING_ROUND_1) begin
                            // Set game state to round 2 of dealing
                            game_state <= DEALING_ROUND_2;
                            // Set card start signal for player card deal
                            card_start <= 1;
                            // Next state is getting card for player hand
                            state <= S_CARD_START_PLAYER;
                        end
                        // If second round of dealing, next state is game start
                        else if(game_state == DEALING_ROUND_2) begin
                            // Next game state is the player's first turn
                            game_state <= PLAYING;
                            // Set comparator value 1
                            val1_player <= 1;
                            // Set comparator value 2s
                            val2_21 <= 1;
                            // Next state is checking that player didn't bust in the deal
                            state <= S_CP_PLAYER_BUST;
                        end
                        // If in the playing stage of the game
                        else if (game_state == PLAYING) begin
                            // Setup comparator inputs
                            val1_house <= 1;
                            val2_21 <= 1;
                            // Next state is house compare bust
                            state <= S_CP_HOUSE_BUST;
                        end
                    end
                
                S_PLAY_START:
                    // Player has 5 cards
                    if(player_hand_index > 3'b100) begin
                        state <= S_PLAYER_STAND;
                    end
                    else begin
                        // Player has pressed hit button
                        if(!hit_r) begin
                            state <= S_PLAYER_HIT;
                        end 
                        // Player has pressed stand button
                        else if(!stand_r) begin
                            state <= S_PLAYER_STAND;
                        end
                    end

                S_PLAYER_HIT:
                    // Player has released hit button
                    if(hit_r) begin
                        // Next state is player getting a card
                        card_start <= 1;
                        state <= S_CARD_START_PLAYER;
                    end

                S_PLAYER_STAND:
                    // Player has released stand button
                    if(stand_r) begin
                        // Next state is check if house busted
                        val1_house <= 1;
                        val2_21 <= 1;

                        state <= S_CP_HOUSE_BUST;
                    end

                S_CP_HOUSE_HIT:
                    begin
                        // Reset comparator control signals
                        val1_house <= 0;
                        val2_17 <= 0;
                        
                        // If house sum is less than 17
                        if(cp_lt && (house_hand_index <= 3'b100)) begin
                            // Next state is house hit
                            card_start <= 1;
                            state <= S_CARD_START_HOUSE;
                        end
                        // If house sum is greater than or equal to 17, house stands, compare winner
                        else begin
                            // Set game state to done
                            game_state <= PLAY_DONE;
                            // Next state is win comparison
                            state <= S_CP_WINNER;
                        end
                    end

                S_CP_PLAYER_BUST:
                    begin
                        // Reset comparator control signals
                        val1_player <= 0;
                        val2_21 <= 0;

                        // If player cards are less than or equal to 21
                        if(cp_lt || cp_eq) begin
                            // Next state is player turn again
                            state <= S_PLAY_START;
                        end
                        // If player cards are more than 21 (bust)
                        else if (cp_gt) begin
                            // Game state is done
                            game_state <= PLAY_DONE;
                            // Next state is house win
                            state <= S_HOUSE_WIN;
                        end
                    end

                S_CP_HOUSE_BUST:
                    begin
                        // Reset comaparator control signals
                        val1_house <= 0;
                        val2_21 <= 0;

                        // If house cards are less than or equal to 21
                        if(cp_lt || cp_eq) begin
                            // Set comparator flags for house decision
                            val1_house <= 1;
                            val2_17 <= 1;
                            // Next state is another house play
                            state <= S_CP_HOUSE_HIT;
                        end
                        // If house cards are greater than 21
                        else if (cp_gt) begin
                            // Set game state to done playing
                            game_state <= PLAY_DONE;
                            // Next state is player win
                            state <= S_PLAYER_WIN;
                        end
                    end

                S_CP_WINNER:
                    begin
                        // Set comparator parameter 1
                        val1_player = 1;
                        // Set comparator parameter 2
                        val2_house = 1;
                        // Compare output in next state
                        state <= S_WINNER_OUTPUT;
                    end
                
                S_WINNER_OUTPUT:
                    begin
                        // If player less than house, house wins
                        if(cp_lt)
                            state <= S_HOUSE_WIN;
                        // If player equal to house, draw
                        else if (cp_eq)
                            state <= S_DRAW;
                        // If player greater than house, player wins
                        else if (cp_gt)
                            state <= S_PLAYER_WIN;
                        // Reset comparator control signals
                        val1_player <= 0;
                        val2_house <= 0;
                    end

                S_HOUSE_WIN:
                    begin
                        outcome <= 2'b10;
                    end
        
                S_DRAW:
                    begin
                        outcome <= 2'b11;
                    end

                S_PLAYER_WIN:
                    begin
                        outcome <= 2'b01;
                    end

            endcase
        end

    end

endmodule

// BCD conversion module
module bcd(
		input wire [3:0] input_char,
		output reg [6:0] segment_output
	);
	
	// The output segment format is ordered as follows: 7'b abcedfg
	always @ (*) 
    begin
		case(input_char)

            4'b0000: segment_output = 7'b1111111; // 0
            4'b0001: segment_output = 7'b0001000; // 1 (ace)
            4'b0010: segment_output = 7'b0100100; // 2
            4'b0011: segment_output = 7'b0110000; // 3
            4'b0100: segment_output = 7'b0011001; // 4
            4'b0101: segment_output = 7'b0010010; // 5
            4'b0110: segment_output = 7'b0000010; // 6
            4'b0111: segment_output = 7'b1111000; // 7
            4'b1000: segment_output = 7'b0000000; // 8
            4'b1001: segment_output = 7'b0011000; // 9
            4'b1010: segment_output = 7'b1000000; // 10
            4'b1011: segment_output = 7'b1000000; // J
            4'b1100: segment_output = 7'b1000000; // Q
            4'b1101: segment_output = 7'b1000000; // K
            4'b1110: segment_output = 7'b0001001; // H[ouse win]
            4'b1111: segment_output = 7'b0001100; // P[layer win]
            default: segment_output = 7'b1111111; // invalid

		endcase
	end

endmodule