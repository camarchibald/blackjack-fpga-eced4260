---------------------------------------------------
-- Author: Cameron Archibald
-- Student ID: B00893056
-- Date: 2025-11-11
-- File Name: lfsr_circular_counter.vhd
-- Architecture: 
-- Description: Acts as two modules depending on mode.
-- 	Mode 0: Pseudo random number generator of 6 bits, using lfsr. 
--		Mode 1: Circular counter 
-- Acknowledgements: https://docs.amd.com/v/u/en-US/xapp052, shows table of tap locations for various bits
-------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.all;  

ENTITY lfsr_circular_counter IS
	GENERIC (MODE: STD_LOGIC; -- Mode 0 LFSR, mode 1 circular counter
				MAX: INTEGER := 51); -- Maximum value 
	PORT 	  (CLK: IN STD_LOGIC; -- Rising edge clock
				SET_START: IN STD_LOGIC; -- Initiate setting
				SET_READY: OUT STD_LOGIC := '1'; -- Low until setting complete
				SET_VAL: IN STD_LOGIC_VECTOR(5 DOWNTO 0); -- Reset number
				SHIFT_START: IN STD_LOGIC; -- Initiate shifting
				SHIFT_READY: OUT STD_LOGIC := '1'; -- Low until shifting complete
				OUTPUT: BUFFER STD_LOGIC_VECTOR(5 DOWNTO 0)); -- Value of generator
END ENTITY;

ARCHITECTURE Behaviour OF lfsr_circular_counter IS
	TYPE STATE_T IS (S_SET_START, S_SETTING, S_SHIFT_SET_START, S_SHIFTING);
	SIGNAL STATE: STATE_T := S_SET_START; -- State starts at S_SET_START (need to load starting value)		

BEGIN
	PROCESS (CLK)
	BEGIN
		IF rising_edge(CLK) THEN
			IF ((STATE = S_SET_START OR STATE = S_SHIFT_SET_START) AND SET_START = '1') THEN	-- Load starting value in, SET_READY low
				STATE <= S_SETTING;
				SET_READY <= '0';
				OUTPUT <= SET_VAL;

			ELSIF (STATE = S_SETTING) THEN	-- Starting value loaded, SET_READY high
				SET_READY <= '1';
				IF (SET_START = '0') THEN -- Once start released, ready to shift or set again
					STATE <= S_SHIFT_SET_START;
				END IF;

			ELSIF (STATE = S_SHIFT_SET_START AND SHIFT_START = '1') THEN -- Shift the LFSR, SHIFT_READY low
				STATE <= S_SHIFTING;
				SHIFT_READY <= '0';
				
				IF (MODE = '0') THEN 
					OUTPUT(0) <= OUTPUT(5) XNOR OUTPUT(4); -- Otherwise shift all by one, taps go into the first element
					OUTPUT(1) <= OUTPUT(0);
					OUTPUT(2) <= OUTPUT(1);
					OUTPUT(3) <= OUTPUT(2);
					OUTPUT(4) <= OUTPUT(3);
					OUTPUT(5) <= OUTPUT(4);

				ELSIF (MODE = '1') THEN
					IF (to_integer(UNSIGNED(OUTPUT)) >= MAX) THEN -- IF value greater than the max for the counter, loop to zero
						OUTPUT <= "000000"; 										
					ELSE -- Otherwise increment counter
						OUTPUT <= STD_LOGIC_VECTOR(UNSIGNED(OUTPUT) + 1);
					END IF;
				END IF;

			ELSIF (STATE = S_SHIFTING) THEN	-- LFSR shifted, SHIFT_READY high
				SHIFT_READY <= '1';
				IF (SHIFT_START <= '0') THEN -- Once start released, ready to shift or set again
					STATE <= S_SHIFT_SET_START; 
				END IF;
			END IF;
		END IF;
	END PROCESS;
END Behaviour;

