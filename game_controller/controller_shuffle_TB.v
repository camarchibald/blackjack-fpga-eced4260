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
    reg rst;

    // Instantiate controller
    controller U1 (
        .clk(clk),
        .rst(rst)
    );

    // Main clock
    always #1 clk = ~clk;

    // Deck shuffle testing
    initial begin
        
        // Initial conditions:
        rst = 1;
        // Begin the simulation
        // Reset released after 3 clock cycles
        #3 rst <= 0;

        


    end
	
	
endmodule

	