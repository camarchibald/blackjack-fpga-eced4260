---------------------------------------------------
-- Author: Cameron Archibald
-- Student ID: B00893056
-- Date: 2025-11-11
-- File Name: deck.vhd
-- Architecture: 
-- Description: 
-- Acknowledgements: 
-------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.all;  

Entity deck IS
	PORT 	  (CLK: IN STD_LOGIC; -- Rising edge clock							
				SHUFFLE_START: IN STD_LOGIC; -- Initiate shuffling					
				SHUFFLE_READY: OUT STD_LOGIC; -- Low until shuffling complete
				SEED: IN STD_LOGIC_VECTOR(5 DOWNTO 0); -- Seed to initialize lfsr
				CARD_START: IN STD_LOGIC; -- Initiate drawing card
				CARD_READY: OUT STD_LOGIC; -- Low until card value ready
				CARD: OUT STD_LOGIC_VECTOR(3 DOWNTO 0)); -- Card value			
END ENTITY;

ARCHITECTURE Behaviour OF deck IS
	COMPONENT lfsr_circular_counter
	GENERIC (MODE: STD_LOGIC := '1'; -- Mode 0 LFSR, mode 1 circular counter
				MAX: INTEGER := 51); -- Maximum value 
	PORT 	  (CLK: IN STD_LOGIC; -- Rising edge clock
				SET_START: IN STD_LOGIC; -- Initiate setting
				SET_READY: OUT STD_LOGIC := '1'; -- Low until setting complete
				SET_VAL: IN STD_LOGIC_VECTOR(5 DOWNTO 0); -- Reset number
				SHIFT_START: IN STD_LOGIC; -- Initiate shifting
				SHIFT_READY: OUT STD_LOGIC := '1'; -- Low until shifting complete
				OUTPUT: BUFFER STD_LOGIC_VECTOR(5 DOWNTO 0)); -- Value of generator
	END COMPONENT;

	TYPE T_STATE IS (RESET);
	SIGNAL STATE: T_STATE := RESET;

	SIGNAL LFSR_SET_START, LFSR_SHIFT_START, CIRCULAR_SET_START, CIRCULAR_SHIFT_START: STD_LOGIC := '0';
	SIGNAL LFSR_SET_READY, LFSR_SHIFT_READY, CIRCULAR_SET_READY, CIRCULAR_SHIFT_READY: STD_LOGIC;
	SIGNAL LFSR_SET_VAL, CIRCULAR_SET_VAL, LFSR_OUTPUT, CIRCULAR_OUTPUT: STD_LOGIC_VECTOR(5 DOWNTO 0);

	TYPE T_CARDS IS ARRAY(0 TO 51) OF STD_LOGIC_VECTOR(3 DOWNTO 0);
	CONSTANT UNSHUFFLED_CARDS : T_CARDS := (
		0 => STD_LOGIC_VECTOR(to_unsigned(1, 4)),
		1 => STD_LOGIC_VECTOR(to_unsigned(1, 4)),
		2 => STD_LOGIC_VECTOR(to_unsigned(1, 4)),
		3 => STD_LOGIC_VECTOR(to_unsigned(1, 4)),
		4 => STD_LOGIC_VECTOR(to_unsigned(2, 4)),
		5 => STD_LOGIC_VECTOR(to_unsigned(2, 4)),
		6 => STD_LOGIC_VECTOR(to_unsigned(2, 4)),
		7 => STD_LOGIC_VECTOR(to_unsigned(2, 4)),
		8 => STD_LOGIC_VECTOR(to_unsigned(3, 4)),
		9 => STD_LOGIC_VECTOR(to_unsigned(3, 4)),
		10 => STD_LOGIC_VECTOR(to_unsigned(3, 4)),
		11 => STD_LOGIC_VECTOR(to_unsigned(3, 4)),
		12 => STD_LOGIC_VECTOR(to_unsigned(4, 4)),
		13 => STD_LOGIC_VECTOR(to_unsigned(4, 4)),
		14 => STD_LOGIC_VECTOR(to_unsigned(4, 4)),
		15 => STD_LOGIC_VECTOR(to_unsigned(4, 4)),
		16 => STD_LOGIC_VECTOR(to_unsigned(5, 4)),
		17 => STD_LOGIC_VECTOR(to_unsigned(5, 4)),
		18 => STD_LOGIC_VECTOR(to_unsigned(5, 4)),
		19 => STD_LOGIC_VECTOR(to_unsigned(5, 4)),
		20 => STD_LOGIC_VECTOR(to_unsigned(6, 4)),
		21 => STD_LOGIC_VECTOR(to_unsigned(6, 4)),
		22 => STD_LOGIC_VECTOR(to_unsigned(6, 4)),
		23 => STD_LOGIC_VECTOR(to_unsigned(6, 4)),
		24 => STD_LOGIC_VECTOR(to_unsigned(7, 4)),
		25 => STD_LOGIC_VECTOR(to_unsigned(7, 4)),
		26 => STD_LOGIC_VECTOR(to_unsigned(7, 4)),
		27 => STD_LOGIC_VECTOR(to_unsigned(7, 4)),
		28 => STD_LOGIC_VECTOR(to_unsigned(8, 4)),
		29 => STD_LOGIC_VECTOR(to_unsigned(8, 4)),
		30 => STD_LOGIC_VECTOR(to_unsigned(8, 4)),
		31 => STD_LOGIC_VECTOR(to_unsigned(8, 4)),
		32 => STD_LOGIC_VECTOR(to_unsigned(9, 4)),
		33 => STD_LOGIC_VECTOR(to_unsigned(9, 4)),
		34 => STD_LOGIC_VECTOR(to_unsigned(9, 4)),
		35 => STD_LOGIC_VECTOR(to_unsigned(9, 4)),
		36 => STD_LOGIC_VECTOR(to_unsigned(10, 4)),
		37 => STD_LOGIC_VECTOR(to_unsigned(10, 4)),
		38 => STD_LOGIC_VECTOR(to_unsigned(10, 4)),
		39 => STD_LOGIC_VECTOR(to_unsigned(10, 4)),
		40 => STD_LOGIC_VECTOR(to_unsigned(11, 4)),
		41 => STD_LOGIC_VECTOR(to_unsigned(11, 4)),
		42 => STD_LOGIC_VECTOR(to_unsigned(11, 4)),
		43 => STD_LOGIC_VECTOR(to_unsigned(11, 4)),
		44 => STD_LOGIC_VECTOR(to_unsigned(12, 4)),
		45 => STD_LOGIC_VECTOR(to_unsigned(12, 4)),
		46 => STD_LOGIC_VECTOR(to_unsigned(12, 4)),
		47 => STD_LOGIC_VECTOR(to_unsigned(12, 4)),
		48 => STD_LOGIC_VECTOR(to_unsigned(13, 4)),
		49 => STD_LOGIC_VECTOR(to_unsigned(13, 4)),
		50 => STD_LOGIC_VECTOR(to_unsigned(13, 4)),
		51 => STD_LOGIC_VECTOR(to_unsigned(13, 4))
	);
	

BEGIN
	lfsr: lfsr_circular_counter GENERIC MAP (MODE => '0') PORT MAP (CLK, LFSR_SET_START, LFSR_SET_READY, LFSR_SET_VAL, LFSR_SHIFT_START, LFSR_SHIFT_READY, LFSR_OUTPUT);
	circular: lfsr_circular_counter GENERIC MAP (MODE => '1') PORT MAP (CLK, CIRCULAR_SET_START, CIRCULAR_SET_READY, CIRCULAR_SET_VAL, CIRCULAR_SHIFT_START, CIRCULAR_SHIFT_READY, CIRCULAR_OUTPUT);
	
	
END Behaviour;

