/*
Author: Nader Hdeib, Cameron Archibald
Student ID: B00898627, B00893056
Date: November 22, 2025
File Name: controller_tb.v
Description: This file executes a single game of blackjack
*/

`timescale 1ns / 1ps

module controller_tb ();

    reg clk = 0;
    reg rst = 1;
    reg user_ready_to_begin = 1;
    reg hit = 1;
    reg stand = 1;
    reg [5:0] seed = 6'b000010;
    reg hand_select = 1;
    wire [1:0] game_outcome;      // Winner outcome LED's
    wire [4:0] state_out;         // FSM state LED's
    wire [1:0] game_state_out;    // Gamse state LED's
    wire [6:0] hand_display_0;    // Hand display on 7-segment displays
    wire [6:0] hand_display_1;
    wire [6:0] hand_display_2;
    wire [6:0] hand_display_3;
    wire [6:0] hand_display_4;
    wire [6:0] hand_display_5;
    

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
        .state_out(),
        .game_state_out(game_state_out),
        .hand_display_0(hand_display_0),
        .hand_display_1(hand_display_1),
        .hand_display_2(hand_display_2),
        .hand_display_3(hand_display_3),
        .hand_display_4(hand_display_4),
        .hand_display_5(hand_display_5),
        .hands()
    );

    // Main clock
    always #1 clk = ~clk;

    // Deck test sequence, vary the combinations of stand, hit to change how the player plays
    initial begin
        
        // Reset released after 5 clock cycles
        #5 rst <= 1;

        // Press start button
        #700 user_ready_to_begin <= 0;       
        #20 user_ready_to_begin <= 1; 

        #50;
        
        // Press hit button (up to 3 times is possible)
        //#20 hit = 0;                      
        //#20 hit = 1; 
        //#20 hit = 0;                      
        //#20 hit = 1;  
        //#20 hit = 0;                      
        //#20 hit = 1;   
        
        // Press stand button
        #20 stand = 0;                            
        #20 stand = 1;                                   
    end
	
	
endmodule

	