/*
Author: Nader Hdeib
Student ID: B00898627
Date: November 22, 2025
File Name: controller_shuffle_TB.v
Description: This file attempts to excercise a blackjack shuffle sequence.
*/

`timescale 1ns / 1ps

module controller_shuffle_TB ();

    reg clk = 0;
    reg rst = 1;
    reg user_ready_to_begin = 1;
    reg hit = 1;
    reg stand = 1;
    reg [5:0] seed = 6'b001010;
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
        .hand_display_5(hand_display_5)
    );

    // Main clock
    always #1 clk = ~clk;

    // Deck shuffle testing
    initial begin
        
        // Begin the simulation
        // Reset released after 3 clock cycles
        #0 rst <= 1;

        #700 user_ready_to_begin <= 0;      // Time = 700 ns 
        #20 user_ready_to_begin <= 1;           // Time = 720 ns
        #50 hit = 0;                            // Time = 770 ns
        #20 hit = 1;                            // Time = 790 ns
        #100 hit = 0;                         // Time = 890 ns
        #20 hit = 1;                            // Time = 850 ns
    end
	
	
endmodule

	