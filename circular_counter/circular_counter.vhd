---------------------------------------------------
-- Author: Cameron Archibald
-- Student ID: B00893056
-- Date: 2025-10-30
-- File Name: circular-counter.vhd
-- Architecture: 
-- Description: Circular up counter from 0 to 51 (or any 6 bit number)
-- Acknowledgements: 
-------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.all;  

Entity circular_counter IS
	GENERIC (MAX: INTEGER := 51); 								-- Max value of counter, default 51
	PORT 	  (CLK, SET: IN STD_LOGIC; 							-- Clock signal actuate updates on rising edge, set signal active high
				SET_VAL: IN STD_LOGIC_VECTOR(5 DOWNTO 0); 	-- Reset number
				OUTPUT: OUT STD_LOGIC_VECTOR(5 DOWNTO 0)); 	-- Value of counter
END ENTITY;

ARCHITECTURE Behaviour OF circular_counter IS
	SIGNAL VAL: STD_LOGIC_VECTOR(5 DOWNTO 0); 				-- Internal state

BEGIN
	PROCESS (CLK)
	BEGIN
		IF rising_edge(CLK) THEN
			IF (SET = '1') THEN										-- IF set signal high, place reset value
				VAL <= SET_VAL; 										
			ELSIF (to_integer(UNSIGNED(VAL)) >= MAX) THEN   -- IF value greater than the max for the counter, loop to zero
				VAL <= "000000"; 										
			ELSE															-- Otherwise increment counter
				VAL <= STD_LOGIC_VECTOR(UNSIGNED(VAL) + 1); 	
			END IF;
		END IF;
	END PROCESS;
	
	OUTPUT <= VAL; 													-- Map internal state to output
END Behaviour;

