/*
Author: Cameron Archibald
Student ID: B00893056
Date: November 26, 2025
File Name: controller_exhaustive_tb.v
Description: 
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

    // Assign to the mega hand signal
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

    integer i, j, k;
    
    initial begin
        seed <= 5'd0;
        for (i = 0; i < 64; i = 1 + 1) begin
            for (j = 0; j <= 3; j = j + 1) begin

                #20;
                rst <= 0;
                #20; 
                rst <= 1;
                
                #700;
                
                user_ready_to_begin <= 0;
                #20;     
                user_ready_to_begin <= 1;     
                
                #50;

                
                for (k = 0; k < j; k = k + 1) begin
                    hit <= 0;
                    #20;
                    hit <= 1;
                    #20;
                end
                
                
                #20
                stand <= 0;
                #20;
                stand <= 1;
                
                #20;
                // Validate results
            end

            //Next seed
            seed <= seed + 5'd1;
        end                                  
    end
	
	
endmodule

	