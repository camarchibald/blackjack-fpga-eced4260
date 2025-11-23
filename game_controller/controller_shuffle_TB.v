/*
Author: Nader Hdeib
Student ID: B00898627
Date: November 22, 2025
File Name: controller_shuffle_TB.v
Description: This file attempts to excercise a blackjack shuffle sequence.
*/

`timescale 1ns / 1ps

module cntroller_shuffle_tb ();

    reg clk = 0;
    reg rst;
    reg shuffle_ready;
    reg shuffling;
    reg card_ready;
    reg start_shuffle;
    reg start_card;

    // Instantiate controller
    controller U1 (
        .clk(clk),
        .rst(rst),
        .shuffling_ready(shuffling_ready),
        .shuffling(shuffling),
        .card_ready(card_ready),
        .start_shuffle(start_shuffle),
        .start_card(start_card)
    );

    // Main clock
    always #1 clk = ~clk;

    // Deck shuffle testing
    initial begin
        
        // Initial conditions:
        rst = 1;
        shuffle_ready = 0;
        shuffling = 0;
        card_ready = 0;

        // Begin the simulation
        // Reset released after 3 clock cycles
        #3 rst <= 0;

        


    end
	
	
endmodule

	