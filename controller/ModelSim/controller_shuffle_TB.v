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
    reg user_ready_to_begin = 0;
    reg hit = 0;
    reg stand = 0;
    reg [5:0] seed = 6'b001010;

    // Instantiate controller
    controller U1 (
        .clk(clk),
        .rst(rst),
        .user_ready_to_begin(user_ready_to_begin),
        .hit(),
        .stand(),
        .state_out(),
        .seed(seed)
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
        #40 hit = 0;                            // Time = 830 ns
        #20 hit = 1;                            // Time = 850 ns
    end
	
	
endmodule

	