/*
Author: Nader Hdeib, Cameron Archibald
Student ID: B00898627, B00893056
Date: November 20, 2025
File Name: controller.v
Description: This is the main blackjack game controller.
Acknowledgements: 
*/

module controller (
    //In/out to the fpga/testbench
    input clk,                      //Rising edge clock, internal 50MHz signal
    input rst,                      //Active low reset button
    input user_ready_to_begin,      //Active low start button
    input hit,                      //Active low hit button
    input stand,                    //Active low stand button
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
    output [6:0] hand_display_5,
    output [39:0] hands             // Output of hands for exhaustive testbench 
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
    parameter S_HOUSE_PLAY          = 5'b10000; // 16
    parameter S_CHECK_PLAYER_BUST   = 5'b10001; // 17
    parameter S_HOUSE_WIN           = 5'b10010; // 18
    parameter S_PLAYER_WIN          = 5'b10011; // 19
    parameter S_DRAW                = 5'b10100; // 20
    parameter S_WINNER_OUTPUT       = 5'b10101; // 21

    // Main FSM state register
    reg [4:0] state_r = S_RESET;
    assign state_out = state_r;


    // Game parameters
    parameter DEALING_ROUND_1       = 2'b00;    // 0
    parameter DEALING_ROUND_2       = 2'b01;    // 1
    parameter PLAYING               = 2'b10;    // 2
    parameter PLAY_DONE             = 2'b11;    // 3

    // Game state register
    reg [1:0] game_state_r = DEALING_ROUND_1;
    assign game_state_out = game_state_r;


    // User inputs
    reg user_ready_to_begin_r, stand_r, hit_r;

    // Outcome of game
    reg [1:0] outcome_r = 2'b00;
    assign game_outcome = outcome_r;

    // Deck module control signals
    reg shuffle_start_r = 0, card_start_r = 0;
    wire shuffle_ready_w, card_ready_w, card_overflow_w;

    // Deck module data registers
    wire [3:0] card_w;

    // Sum registers
    reg [5:0] player_sum_r = 6'b000000, house_sum_r = 6'b000000;

    // Player and house hands
    reg [3:0] player_hand_r [4:0];    // Array of 5 4-bit cards 
    reg [3:0] house_hand_r [4:0];     // Array of 5 4-bit cards

    // Index of cards in hands
    reg [2:0] player_hand_index_r = 3'b000, house_hand_index_r = 3'b000;
    
    // Assign hand registers to output
    assign hands[3:0]   = player_hand_r[0];
    assign hands[7:4]   = player_hand_r[1];
    assign hands[11:8]  = player_hand_r[2];
    assign hands[15:12] = player_hand_r[3];
    assign hands[19:16] = player_hand_r[4];

    assign hands[23:20]  = house_hand_r[0];
    assign hands[27:24]  = house_hand_r[1];
    assign hands[31:28]  = house_hand_r[2];
    assign hands[35:32]  = house_hand_r[3];
    assign hands[39:36]  = house_hand_r[4];

    // Sum output
    wire [5:0] player_sum_w, house_sum_w;

    // Adder module control signals
    reg player_select, house_select;

    // Comparator module control signals
    reg val1_player_r = 0, val1_house_r = 0, val2_player_r = 0, val2_house_r = 0, val2_21_r = 0, val2_17_r = 0;
    wire cp_eq_w, cp_gt_w, cp_lt_w;

    // 7segment display values
    reg [3:0] bcd_hand_r [4:0];
    reg [3:0] bcd_char_r;


    // Display instantiation
    bcd bcd_6(
		.input_char(bcd_char_r),
		.segment_output(hand_display_5)
	);
    bcd bcd_5(
		.input_char(bcd_hand_r[4]),
		.segment_output(hand_display_4)
	);
    bcd bcd_4(
		.input_char(bcd_hand_r[3]),
		.segment_output(hand_display_3)
	);
    bcd bcd_3(
		.input_char(bcd_hand_r[2]),
		.segment_output(hand_display_2)
	);
    bcd bcd_2(
		.input_char(bcd_hand_r[1]),
		.segment_output(hand_display_1)
	);
    bcd bcd_1(
		.input_char(bcd_hand_r[0]),
		.segment_output(hand_display_0)
	);

    // Deck instantiation
    deck deck_instance(
        .reset(!rst),
        .clk(clk),
        .shuffle_start(shuffle_start_r),
        .shuffle_ready(shuffle_ready_w),
        .seed(seed),
        .card_start(card_start_r),
        .card_ready(card_ready_w),
        .card(card_w),
        .card_overflow(card_overflow_w)
    );

    // Adder instantiation
    adder adder_instance(
        .reset(!rst),
        .card(card_w),
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
        .val1_player(val1_player_r),
        .val1_house(val1_house_r),
        .val2_player(val2_player_r),
        .val2_house(val2_house_r),
        .val2_21(val2_21_r),
        .val2_17(val2_17_r),
        .eq(cp_eq_w),
        .gt(cp_gt_w),
        .lt(cp_lt_w)
    );

    
    // Display control logic, lookup in BCD the values of the 7 segments
    always @ (hand_select or player_hand_r or house_hand_r or rst)
    begin
        if(!hand_select) begin // Display player hand
            bcd_char_r <= 4'b1111; //P
            bcd_hand_r[0] <= player_hand_r[0];
            bcd_hand_r[1] <= player_hand_r[1];
            bcd_hand_r[2] <= player_hand_r[2];
            bcd_hand_r[3] <= player_hand_r[3];
            bcd_hand_r[4] <= player_hand_r[4];

        end
        else begin // Display house hand
            bcd_char_r <= 4'b1110; //H
            bcd_hand_r[0] <= house_hand_r[0];
            bcd_hand_r[1] <= house_hand_r[1];
            bcd_hand_r[2] <= house_hand_r[2];
            bcd_hand_r[3] <= house_hand_r[3];
            bcd_hand_r[4] <= house_hand_r[4];
        end
    end

    // Main FSM
    always @ (posedge clk or negedge rst) begin
        
        // Assign IO registers
        user_ready_to_begin_r <= user_ready_to_begin;
        hit_r <= hit;
        stand_r <= stand;

        // Reset button is pressed, reset registers and go to first state
        if (!rst)
        begin
            state_r <= S_RESET;
            game_state_r <= DEALING_ROUND_1;
            house_sum_r <= 6'b000000;
            player_sum_r <= 6'b000000;
            house_hand_index_r <= 3'b000;
            player_hand_index_r <= 3'b000;

            house_hand_r[0] <= 4'b0000;
            house_hand_r[1] <= 4'b0000;
            house_hand_r[2] <= 4'b0000;
            house_hand_r[3] <= 4'b0000;
            house_hand_r[4] <= 4'b0000;

            player_hand_r[0] <= 4'b0000;
            player_hand_r[1] <= 4'b0000;
            player_hand_r[2] <= 4'b0000;
            player_hand_r[3] <= 4'b0000;
            player_hand_r[4] <= 4'b0000;

        end

        else 
        begin

            // Logic for remaining cases
            case(state_r)

                S_RESET:
                    // Reset button has been released
                    if(rst) begin
                        // Next state is shuffle start state
                        state_r <= S_SHUFFLE_START;
                        outcome_r <= 2'b00;
                    end

                S_SHUFFLE_START:
                    // Shuffle ready is high, deck is ready to be shuffled
                    if(shuffle_ready_w) begin
                        // Send shuffle start command
                        shuffle_start_r <= 1;
                    end
                    // Shuffle ready is low, deck is currently shuffling cards
                    else if (!shuffle_ready_w) begin
                        // Reset shuffle start command
                        shuffle_start_r <= 0;
                        // Next state waits for shuffle to complete (shuffle_ready_w to go high again)
                        state_r <= S_SHUFFLE_WAIT;    // Go to shuffle wait state
                    end 

                S_SHUFFLE_WAIT:
                    // If shuffle is complete and user has pressed start button
                    if(shuffle_ready_w && !user_ready_to_begin_r) begin
                        // Next state is start of dealing
                        state_r <= S_DEAL_START;
                    end
                
                S_DEAL_START:
                    // User has released start button
                    if(user_ready_to_begin_r && card_ready_w) begin
                        // Send card start command
                        card_start_r <= 1;
                        // Next state is getting card for player
                        state_r <= S_CARD_START_PLAYER;
                    end
                
                S_CARD_START_PLAYER:
                    // Deck module is dispensing a card
                    if(!card_ready_w) begin
                        // Reset card start command
                        card_start_r <= 0;
                        // Next state is getting card for player
                        state_r <= S_GETTING_CARD_PLAYER;
                    end
                
                S_GETTING_CARD_PLAYER:
                    // Card has been dispensed
                    if(card_ready_w) begin
                        // Set player select line for adder
                        player_select <= 1;
                        // Next state is adding to player sum
                        state_r <= S_ADD_PLAYER;
                    end

                S_ADD_PLAYER:
                    begin
                        // Store dealt card in player hand
                        player_hand_r[player_hand_index_r] <= card_w;
                        // Increment player hand index
                        player_hand_index_r <= player_hand_index_r + 3'b001;
                        // Store player sum from adder output
                        player_sum_r <= player_sum_w;
                        // Reset adder player select signal
                        player_select <= 0;
                        // If in dealing stage, no need to compare at this point
                        if(game_state_r == DEALING_ROUND_1 || game_state_r == DEALING_ROUND_2) begin
                            // Get the next deal card for the house
                            card_start_r <= 1;
                            state_r <= S_CARD_START_HOUSE;
                        end
                        // If in playing phase of game, compare player sum to bust
                        else if (game_state_r == PLAYING) begin
                            // Set comparator value 1
                            val1_player_r <= 1;
                            // Set comparator value 2s
                            val2_21_r <= 1;
                                // Next state is comparing player sum to bust
                            state_r <= S_CP_PLAYER_BUST;
                        end
                    end

                S_CARD_START_HOUSE:
                    // Deck module is dispensing a card
                    if(!card_ready_w) begin
                        // Reset card start command
                        card_start_r <= 0;
                        // Next state is waiting for card for house
                        state_r <= S_GETTING_CARD_HOUSE;
                    end

                S_GETTING_CARD_HOUSE:
                    // Card ready signal is high again (deck has dispensed card)
                    if(card_ready_w) begin
                        // Select house register as adder input
                        house_select <= 1;
                        // Next state is adding to house register
                        state_r <= S_ADD_HOUSE;
                    end
                
                S_ADD_HOUSE:
                    begin
                        // Store card in house hand
                        house_hand_r[house_hand_index_r] <= card_w;
                        // Increment index for house hand
                        house_hand_index_r <= house_hand_index_r + 3'b001;
                        // Store house sum from adder output
                        house_sum_r <= house_sum_w;
                        // Reset house select signal for adder
                        house_select <= 0;
                        // If in the first dealing phase of the game
                        if(game_state_r == DEALING_ROUND_1) begin
                            // Set game state to round 2 of dealing
                            game_state_r <= DEALING_ROUND_2;
                            // Set card start signal for player card deal
                            card_start_r <= 1;
                            // Next state is getting card for player hand
                            state_r <= S_CARD_START_PLAYER;
                        end
                        // If second round of dealing, next state is game start
                        else if(game_state_r == DEALING_ROUND_2) begin
                            // Next game state is the player's first turn
                            game_state_r <= PLAYING;
                            // Set comparator value 1
                            val1_player_r <= 1;
                            // Set comparator value 2s
                            val2_21_r <= 1;
                            // Next state is checking that player didn't bust in the deal
                            state_r <= S_CP_PLAYER_BUST;
                        end
                        // If in the playing stage of the game
                        else if (game_state_r == PLAYING) begin
                            // Setup comparator inputs
                            val1_house_r <= 1;
                            val2_21_r <= 1;
                            // Next state is house compare bust
                            state_r <= S_CP_HOUSE_BUST;
                        end
                    end
                
                S_PLAY_START:
                    // Player has 5 cards
                    if(player_hand_index_r > 3'b100) begin
                        state_r <= S_PLAYER_STAND;
                    end
                    else begin
                        // Player has pressed hit button
                        if(!hit_r) begin
                            state_r <= S_PLAYER_HIT;
                        end 
                        // Player has pressed stand button
                        else if(!stand_r) begin
                            state_r <= S_PLAYER_STAND;
                        end
                    end

                S_PLAYER_HIT:
                    // Player has released hit button
                    if(hit_r) begin
                        // Next state is player getting a card
                        card_start_r <= 1;
                        state_r <= S_CARD_START_PLAYER;
                    end

                S_PLAYER_STAND:
                    // Player has released stand button
                    if(stand_r) begin
                        // Next state is check if house busted
                        val1_house_r <= 1;
                        val2_21_r <= 1;

                        state_r <= S_CP_HOUSE_BUST;
                    end

                S_CP_HOUSE_HIT:
                    begin
                        // Reset comparator control signals
                        val1_house_r <= 0;
                        val2_17_r <= 0;
                        
                        // If house sum is less than 17
                        if(cp_lt_w && (house_hand_index_r <= 3'b100)) begin
                            // Next state is house hit
                            card_start_r <= 1;
                            state_r <= S_CARD_START_HOUSE;
                        end
                        // If house sum is greater than or equal to 17, house stands, compare winner
                        else begin
                            // Set game state to done
                            game_state_r <= PLAY_DONE;
                            // Set comparator parameter 1
                            val1_player_r = 1;
                            // Set comparator parameter 2
                            val2_house_r = 1;
                            // Compare output in next state
                            state_r <= S_WINNER_OUTPUT;
                        end
                    end

                S_CP_PLAYER_BUST:
                    begin
                        // Reset comparator control signals
                        val1_player_r <= 0;
                        val2_21_r <= 0;

                        // If player cards are less than or equal to 21
                        if(cp_lt_w || cp_eq_w) begin
                            // Next state is player turn again
                            state_r <= S_PLAY_START;
                        end
                        // If player cards are more than 21 (bust)
                        else if (cp_gt_w) begin
                            // Game state is done
                            game_state_r <= PLAY_DONE;
                            // Next state is house win
                            state_r <= S_HOUSE_WIN;
                        end
                    end

                S_CP_HOUSE_BUST:
                    begin
                        // Reset comaparator control signals
                        val1_house_r <= 0;
                        val2_21_r <= 0;

                        // If house cards are less than or equal to 21
                        if(cp_lt_w || cp_eq_w) begin
                            // Set comparator flags for house decision
                            val1_house_r <= 1;
                            val2_17_r <= 1;
                            // Next state is another house play
                            state_r <= S_CP_HOUSE_HIT;
                        end
                        // If house cards are greater than 21
                        else if (cp_gt_w) begin
                            // Set game state to done playing
                            game_state_r <= PLAY_DONE;
                            // Next state is player win
                            state_r <= S_PLAYER_WIN;
                        end
                    end
                
                S_WINNER_OUTPUT:
                    begin
                        // If player less than house, house wins
                        if(cp_lt_w)
                            state_r <= S_HOUSE_WIN;
                        // If player equal to house, draw
                        else if (cp_eq_w)
                            state_r <= S_DRAW;
                        // If player greater than house, player wins
                        else if (cp_gt_w)
                            state_r <= S_PLAYER_WIN;
                        // Reset comparator control signals
                        val1_player_r <= 0;
                        val2_house_r <= 0;
                    end

                // Set outputs based on outcome
                S_HOUSE_WIN:
                    begin
                        outcome_r <= 2'b10;
                    end
        
                S_DRAW:
                    begin
                        outcome_r <= 2'b11;
                    end

                S_PLAYER_WIN:
                    begin
                        outcome_r <= 2'b01;
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
	
	// The output segment format is ordered as follows: 7'b gfedcba
	always @ (*) 
    begin
		case(input_char)

            4'b0000: segment_output = 7'b1111111; // 0 (all off)
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
            4'b1011: segment_output = 7'b1110010; // J 
            4'b1100: segment_output = 7'b0000100; // Q 
            4'b1101: segment_output = 7'b0001001; // K 
            4'b1110: segment_output = 7'b0001001; // H[ouse win]
            4'b1111: segment_output = 7'b0001100; // P[layer win]
            default: segment_output = 7'b1111111; // invalid (all off)

		endcase
	end

endmodule