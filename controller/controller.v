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
    input stand
);

    // State parameters
    parameter S_RESET	            = 5'b00000;
	parameter S_SHUFFLE_START	    = 5'b00001;
	parameter S_SHUFFLE_WAIT	    = 5'b00010;
	parameter S_DEAL_START 	        = 5'b00011;
	parameter S_CARD_START_HOUSE 	= 5'b00100;
	parameter S_GETTING_CARD_HOUSE 	= 5'b00101;
    parameter S_ADD_HOUSE 	        = 5'b00110;
    parameter S_CARD_START_PLAYER 	= 5'b00111;
    parameter S_GETTING_CARD_PLAYER = 5'b01000;
    parameter S_ADD_PLAYER 	        = 5'b01001;
    parameter S_PLAY_START 	        = 5'b01010;
    parameter S_PLAYER_HIT 	        = 5'b01011;
    parameter S_PLAYER_STAND 	    = 5'b01100;
    parameter S_CP_HOUSE_HIT 	    = 5'b01101;
    parameter S_CP_PLAYER_BUST      = 5'b01110;
    parameter S_CP_HOUSE_BUST 	    = 5'b01111;
    parameter S_CP_WINNER           = 5'b10000;

    // Game parameters
    parameter DEALING_ROUND_1   = 2'b00;
    parameter DEALING_ROUND_2   = 2'b01;
    parameter PLAYING           = 2'b10;
    parameter PLAY_DONE         = 2'b11;

    // User inputs
    reg user_ready_to_begin_r, stand_r, hit_r;

    // Main FSM state register
    reg [4:0] state = S_RESET;

    // Game state register
    reg [1:0] game_state = DEALING_ROUND_1;

    // Deck module control signals
    reg shuffle_start = 0, card_start = 0;
    wire shuffle_ready, card_ready, card_overflow, shuffling;

    // Deck module data registers
    wire [3:0] card;
    reg [5:0] seed = 5'b01010;

    // Sum registers
    reg [5:0] player_sum_r = 6'b000000, house_sum_r = 6'b000000;

    // Player and house hands
    reg [3:0] player_hand [4:0];    // Array of 5 4-bit cards 
    reg [3:0] house_hand [4:0];     // Array of 5 4-bit cards

    reg [2:0] player_hand_index = 3'b000, house_hand_index = 3'b000;

    // TODO: check house and player hand index SOMEHWERE

    // Sum output
    wire [5:0] player_sum_w, house_sum_w;

    // Adder module control signals
    reg player_select, house_select;

    // Comparator module control signals
    reg val1_player, val1_house, val2_player, val2_house, val2_21, val2_17;
    wire cp_eq, cp_gt, cp_lt;

    // Display module control signals
    wire display_ready;

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
    always @ (posedge clk or negedge rst) begin
        
        // Assign IO registers at clock
        user_ready_to_begin_r <= user_ready_to_begin;
        hit_r <= hit;
        stand_r <= stand;

        // If reset pin is high, go to S0
        if (!rst) 
        begin
            state <= S_RESET;
            house_sum_r = 6'b000000;
            player_sum_r = 6'b000000;
        end

        else 
        begin

            // Logic for remaining cases
            case(state)

                S_RESET:
                    if(rst) begin
                        state <= S_SHUFFLE_START;
                    end

                S_SHUFFLE_START:
                    if(shuffle_ready) begin
                        shuffle_start <= 1;
                    end
                    else if (!shuffle_ready) begin
                        shuffle_start <= 0;
                        state <= S_SHUFFLE_WAIT;
                    end 

                S_SHUFFLE_WAIT:
                    if(shuffle_ready & !user_ready_to_begin_r) begin
                        state <= S_DEAL_START;
                    end
                
                S_DEAL_START:
                    if(user_ready_to_begin_r) begin
                        card_start <= 1;
                        state <= S_CARD_START_HOUSE;
                    end
                
                S_CARD_START_HOUSE:
                    if(!card_ready) begin
                       card_start <= 0;
                       state <= S_GETTING_CARD_HOUSE;
                    end

                S_GETTING_CARD_HOUSE:
                    if(card_ready) begin
                        house_select <= 1;
                        state <= S_ADD_HOUSE;
                    end
                
                S_ADD_HOUSE:
                    begin
                        house_hand[house_hand_index] <= card;
                        house_hand_index <= house_hand_index + 3'b001;
                        house_sum_r <= house_sum_w;
                        house_select <= 0;
                        card_start <= 1;
                        state <= S_CARD_START_PLAYER;
                    end

                S_CARD_START_PLAYER:
                    if(!card_ready) begin
                        card_start <= 0;
                        state <= S_GETTING_CARD_PLAYER;
                    end
                
                S_GETTING_CARD_PLAYER:
                    if(card_ready) begin
                        player_select <= 1;
                        state <= S_ADD_PLAYER;
                    end

                S_ADD_PLAYER:
                    begin
                        player_hand[player_hand_index] <= card;
                        player_hand_index <= player_hand_index + 3'b001;
                        player_sum_r <= player_sum_w;
                        player_select <= 0;
                        if(game_state == DEALING_ROUND_1) begin
                            game_state <= DEALING_ROUND_2;
                            state <= S_DEAL_START;
                        end
                        else begin
                            game_state <= PLAYING;
                            state <= S_PLAY_START;
                        end
                    end
                
                S_PLAY_START:
                    if(hit_r) begin
                        state <= S_PLAYER_HIT;
                    end
                    else if (stand_r) begin
                        state <= S_PLAYER_STAND;
                    end

                S_PLAYER_HIT:
                    if(!hit_r) begin
                        state <= S_PLAYER_HIT;
                    end

                S_PLAYER_STAND:
                    state <= S_PLAYER_STAND;

            endcase
        end

    end

endmodule