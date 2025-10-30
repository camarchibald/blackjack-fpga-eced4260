---------------------------------------------------
-- Author: Cameron Archibald
-- Student ID: B00893056
-- Date: 2025-10-30
-- File Name: lfsr.vhd
-- Architecture: 
-- Description: Pseudo random number generator of 6 bits, using lfsr. 
-- 				 Test shows all numbers 0 to 62 inclusive are created
-- Acknowledgements: https://docs.amd.com/v/u/en-US/xapp052, shows table of tap locations for various bits
-------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.all;  

Entity lfsr IS
	PORT 	  (CLK, SET: IN STD_LOGIC; 							-- Clock signal actuate updates on rising edge, set signal active high
				SET_VAL: IN STD_LOGIC_VECTOR(5 DOWNTO 0); 	-- Reset number
				OUTPUT: OUT STD_LOGIC_VECTOR(5 DOWNTO 0)); 	-- Value of generator
END ENTITY;

ARCHITECTURE Behaviour OF lfsr IS
	SIGNAL VAL: STD_LOGIC_VECTOR(5 DOWNTO 0); 				-- Internal state

BEGIN
	PROCESS (CLK)
	BEGIN
		IF rising_edge(CLK) THEN
			IF (SET = '1') THEN										-- IF set signal high, place reset value
				VAL <= SET_VAL; 																				
			ELSE															-- Otherwise shift all by one, taps go into the first element
				VAL(0) <= VAL(5) XNOR VAL(4);
				VAL(1) <= VAL(0);
				VAL(2) <= VAL(1);
				VAL(3) <= VAL(2);
				VAL(4) <= VAL(3);
				VAL(5) <= VAL(4);
			END IF;
		END IF;
	END PROCESS;
	
	OUTPUT <= VAL; 													-- Map internal state to output
END Behaviour;

