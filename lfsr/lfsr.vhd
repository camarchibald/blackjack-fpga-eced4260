---------------------------------------------------
-- Author: Cameron Archibald
-- Student ID: B00893056
-- Date: 2025-11-11
-- File Name: lfsr.vhd
-- Architecture: 
-- Description: Pseudo random number generator of 6 bits, using lfsr. 
-- Acknowledgements: https://docs.amd.com/v/u/en-US/xapp052, shows table of tap locations for various bits
-------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.all;  

ENTITY lfsr IS
	GENERIC (HIGH_BIT: INTEGER := 5); -- Highest bit in register
	PORT 	  (CLK: IN STD_LOGIC; -- Rising edge clock
				RESET: IN STD_LOGIC; -- Asynchronous reset
				SET_START: IN STD_LOGIC; -- Initiate setting
				SET_READY: OUT STD_LOGIC := '1'; -- Low until setting complete
				SET_VAL: IN STD_LOGIC_VECTOR(HIGH_BIT DOWNTO 0); -- Reset number
				SHIFT_START: IN STD_LOGIC; -- Initiate shifting
				SHIFT_READY: OUT STD_LOGIC := '1'; -- Low until shifting complete
				OUTPUT: BUFFER STD_LOGIC_VECTOR(HIGH_BIT DOWNTO 0)); -- Value of generator
END ENTITY;

ARCHITECTURE Behaviour OF lfsr IS
	TYPE STATE_T IS (S_SET_START, S_SETTING, S_SHIFT_SET_START, S_SHIFTING_RANDOM, S_SHIFTING_CHECK, S_SHIFTING_DONE);
	SIGNAL STATE: STATE_T := S_SET_START; -- State starts at S_SET_START (need to load starting value)

	CONSTANT MAX: UNSIGNED(HIGH_BIT DOWNTO 0) := to_unsigned(51, HIGH_BIT + 1); -- Maximum value
	CONSTANT INVALID_SEED: UNSIGNED(HIGH_BIT DOWNTO 0) := to_unsigned(63, HIGH_BIT + 1); -- If seed is 63 then it will not shift

BEGIN
	PROCESS (CLK, RESET)
	BEGIN
		IF (RESET = '1') THEN -- Reset to first state
			STATE <= S_SET_START;
			SET_READY <= '1';
		
		ELSIF (rising_edge(CLK)) THEN
			IF ((STATE = S_SET_START OR STATE = S_SHIFT_SET_START) AND SET_START = '1') THEN	-- Load starting value in, SET_READY low
				STATE <= S_SETTING;
				SET_READY <= '0';
				OUTPUT <= SET_VAL;

			ELSIF (STATE = S_SETTING AND SET_START = '0') THEN	-- Starting value loaded, SET_READY high
				STATE <= S_SHIFT_SET_START;
				SET_READY <= '1';

			ELSIF (STATE = S_SHIFT_SET_START AND SHIFT_START = '1') THEN -- Shift the LFSR, SHIFT_READY low
				SHIFT_READY <= '0';
				STATE <= S_SHIFTING_RANDOM;

			ELSIF (STATE = S_SHIFTING_RANDOM) THEN -- Shift all by one, taps go into the first element
				STATE <= S_SHIFTING_CHECK;
				OUTPUT(0) <= OUTPUT(5) XNOR OUTPUT(4); 
				OUTPUT(1) <= OUTPUT(0);
				OUTPUT(2) <= OUTPUT(1);
				OUTPUT(3) <= OUTPUT(2);
				OUTPUT(4) <= OUTPUT(3);
				OUTPUT(5) <= OUTPUT(4);
				
			ELSIF (STATE = S_SHIFTING_CHECK) THEN -- Check if over 51, need to do the random shift again, if equal to 63 (invalid seed) then flip one bit to zero and shift once
				IF (UNSIGNED(OUTPUT) = INVALID_SEED) THEN
					STATE <= S_SHIFTING_RANDOM;
					OUTPUT(0) <= '0';
				ELSIF (UNSIGNED(OUTPUT) > MAX) THEN 
					STATE <= S_SHIFTING_RANDOM;
				ELSE
					STATE <= S_SHIFTING_DONE;
					SHIFT_READY <= '1';
				END IF;

			ELSIF (STATE = S_SHIFTING_DONE AND SHIFT_START = '0') THEN -- Start signal low, ready for next shift or set
				STATE <= S_SHIFT_SET_START; 

			END IF;
		END IF;
	END PROCESS;
END Behaviour;

