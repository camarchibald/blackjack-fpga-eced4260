/*
Author: Cameron Archibald, Nader Hdeib
Student ID: B00893056, B00898627
Date: November 26, 2025
File Name: controller_exhaustive_tb.v
Description: The testbench tests every possible game of blackjack (all 0-63 seeds, 0-2 hits by the player)
*/

`timescale 1ns / 1ps

module controller_exhaustive_tb ();

    //Internal
    reg clk = 0;

    //Buttons
    reg rst = 1;
    reg user_ready_to_begin = 1;
    reg hit = 1;
    reg stand = 1;

    //Switches
    reg [5:0] seed;
    reg hand_select = 1;

    //LEDs
    wire [1:0] game_outcome;
    
    //Other
    wire [39:0] hands;
    reg [3:0] player_hand [4:0];
    reg [3:0] house_hand [4:0];
    wire [4:0] state;
    reg [5:0] player_sum_tb, house_sum_tb; //Sums of the player, house hands as calculated by the testbench

    //Count of correct or incorrect outcomes, incorrect should be zero at the end of the simulation
    reg [9:0] correct = 10'd0;
    reg [9:0] incorrect = 10'd0;

    // Looping counters
    integer i, j, k, m;

    // Instantiate controller
    controller U1 (
        .clk(clk),
        .rst(rst),
        .user_ready_to_begin(user_ready_to_begin),
        .hit(hit),
        .stand(stand),
        .seed(seed),
        .hand_select(hand_select),
        .game_outcome(game_outcome),
        .state_out(state),
        .game_state_out(),
        .hand_display_0(),
        .hand_display_1(),
        .hand_display_2(),
        .hand_display_3(),
        .hand_display_4(),
        .hand_display_5(),
        .hands(hands)
    );

    // Main clock
    always #1 clk = ~clk;

    // Assign to the from the combined hand signal
    always @* begin
        player_hand[0] = hands[3:0]   ;
        player_hand[1] = hands[7:4]   ;
        player_hand[2] = hands[11:8]  ;
        player_hand[3] = hands[15:12] ;
        player_hand[4] = hands[19:16] ;

        house_hand[0]  = hands[23:20] ;
        house_hand[1]  = hands[27:24] ;
        house_hand[2]  = hands[31:28] ;
        house_hand[3]  = hands[35:32] ;
        house_hand[4]  = hands[39:36] ;   
    end

    initial begin
        seed <= 5'd0;
        
        // Loop through all 0-63 seeds
        for (i = 0; i < 64; i = i + 1) begin

            // Loop through 0-3 hits
            for (j = 0; j <= 3; j = j + 1) begin
                player_sum_tb <= 6'd0;
                house_sum_tb <= 6'd0;
                
                // Apply reset
                #20;
                rst <= 0;
                #20; 
                rst <= 1;
                
                #700;
                
                // Press start button
                user_ready_to_begin <= 0;
                #20;     
                user_ready_to_begin <= 1;     
                
                #50;

                // Execute the 0-3 hits
                for (k = 0; k < j; k = k + 1) begin
                    hit <= 0;
                    #20;
                    hit <= 1;
                    #20;
                end
                
                // Press stand button
                #20
                stand <= 0;
                #20;
                stand <= 1;

                #100;

                //Add the sums for each hand
                for (m = 0; m <= 4; m = m + 1) begin
                    case (player_hand[m])
                        //A
                        6'd1: begin
                            player_sum_tb <= player_sum_tb + 6'd11;
                        end
                        //JQK
                        6'd11, 6'd12, 6'd13: begin
                            player_sum_tb <= player_sum_tb + 6'd10;
                        end
                        //Other cards have their value
                        default: begin
                            player_sum_tb <= player_sum_tb + player_hand[m];
                        end
                    endcase

                    case (house_hand[m])
                        //A
                        6'd1: begin
                            house_sum_tb <= house_sum_tb + 6'd11;
                        end
                        //JQK
                        6'd11, 6'd12, 6'd13: begin
                            house_sum_tb <= house_sum_tb + 6'd10;
                        end
                        //Other cards have their value
                        default: begin
                            house_sum_tb <= house_sum_tb + house_hand[m];
                        end
                    endcase
                    #1;
                end

                // Determine whether the outcome was correct or not
                // Controller reports the game outcome, we compare if that is right based off of the hands
                case (game_outcome)
                    2'd1: begin //Player win, player doesn't bust and (player exceeds house or house busts)
                        if (((player_sum_tb > house_sum_tb) || (house_sum_tb > 10'd21)) && (player_sum_tb <= 10'd21)) begin
                            correct <= correct + 10'd1;
                        end else begin
                            incorrect <= incorrect + 10'd1;
                        end
                    end

                    2'd2: begin //House win, player busts or (house exceeds player given the house hasn't busted)
                        if (((house_sum_tb > player_sum_tb) && (house_sum_tb <= 10'd21)) || (player_sum_tb > 10'd21)) begin
                            correct <= correct + 10'd1;
                        end else begin
                            incorrect <= incorrect + 10'd1;
                        end
                    end

                    2'd3: begin //Push
                        if (player_sum_tb == house_sum_tb) begin
                            correct <= correct + 10'd1;
                        end else begin
                            incorrect <= incorrect + 10'd1;
                        end
                    end

                endcase
            end

            //Next seed
            seed <= seed + 5'd1;
        end        
    end
	
	
endmodule

	