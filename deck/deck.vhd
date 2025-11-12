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

ENTITY deck IS
	PORT 	  (CLK: IN STD_LOGIC; -- Rising edge clock							
				SHUFFLE_START: IN STD_LOGIC; -- Initiate shuffling					
				SHUFFLE_READY: OUT STD_LOGIC := '1'; -- Low until shuffling complete
				SEED: IN STD_LOGIC_VECTOR(5 DOWNTO 0); -- Seed to initialize lfsr
				CARD_START: IN STD_LOGIC; -- Initiate drawing card
				CARD_READY: OUT STD_LOGIC := '1'; -- Low until card value ready
				CARD: OUT STD_LOGIC_VECTOR(3 DOWNTO 0)); -- Card value			
END ENTITY;

ARCHITECTURE Behaviour OF deck IS
	COMPONENT lfsr_circular_counter
	GENERIC (MODE: STD_LOGIC := '0'; -- Mode 0 LFSR, mode 1 circular counter
				MAX: INTEGER := 51); -- Maximum value 
	PORT 	  (CLK: IN STD_LOGIC; -- Rising edge clock
				SET_START: IN STD_LOGIC; -- Initiate setting
				SET_READY: OUT STD_LOGIC := '1'; -- Low until setting complete
				SET_VAL: IN STD_LOGIC_VECTOR(5 DOWNTO 0); -- Reset number
				SHIFT_START: IN STD_LOGIC; -- Initiate shifting
				SHIFT_READY: OUT STD_LOGIC := '1'; -- Low until shifting complete
				OUTPUT: BUFFER STD_LOGIC_VECTOR(5 DOWNTO 0)); -- Value of generator
	END COMPONENT;

	-- Deck states
	TYPE T_STATE IS (S_RESET, S_SHUFFLE_START, S_LFSR_SETTING, S_LFSR_SET, S_LOADED_UNSHUFFLED, S_SHUFFLED, S_LFSR_SHIFT_START, S_LFSR_SHIFTING, S_CARD_START, S_CARD_GETTING, S_CARD_READY);
	SIGNAL STATE: T_STATE := S_RESET;

	-- Signals to connect to lfsr
	SIGNAL LFSR_SET_START, LFSR_SHIFT_START: STD_LOGIC := '0'; -- Initial zero (don't start anything)
	SIGNAL LFSR_SET_READY, LFSR_SHIFT_READY: STD_LOGIC;
	SIGNAL LFSR_SET_VAL, LFSR_OUTPUT: STD_LOGIC_VECTOR(5 DOWNTO 0);

	-- Holds 1 if the card in that position from the unshuffled deck in that position has been used already
	TYPE T_USED_UNSHIFFLED_CARDS IS ARRAY(0 TO 51) OF STD_LOGIC;
	SIGNAL USED_UNSHUFFLED_CARDS: T_USED_UNSHIFFLED_CARDS := (OTHERS => '0');

	-- Array of unshuffled cards (in order), and array of shuffled cards (cards being placed in the deck)
	TYPE T_CARDS IS ARRAY(0 TO 51) OF STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL SHUFFLED_CARDS : T_CARDS;
	CONSTANT UNSHUFFLED_CARDS : T_CARDS := (
		0 => STD_LOGIC_VECTOR(to_unsigned(1, 4)),
		1 => STD_LOGIC_VECTOR(to_unsigned(2, 4)),
		2 => STD_LOGIC_VECTOR(to_unsigned(3, 4)),
		3 => STD_LOGIC_VECTOR(to_unsigned(4, 4)),
		4 => STD_LOGIC_VECTOR(to_unsigned(5, 4)),
		5 => STD_LOGIC_VECTOR(to_unsigned(6, 4)),
		6 => STD_LOGIC_VECTOR(to_unsigned(7, 4)),
		7 => STD_LOGIC_VECTOR(to_unsigned(8, 4)),
		8 => STD_LOGIC_VECTOR(to_unsigned(9, 4)),
		9 => STD_LOGIC_VECTOR(to_unsigned(10, 4)),
		10 => STD_LOGIC_VECTOR(to_unsigned(11, 4)),
		11 => STD_LOGIC_VECTOR(to_unsigned(12, 4)),
		12 => STD_LOGIC_VECTOR(to_unsigned(13, 4)),
		13 => STD_LOGIC_VECTOR(to_unsigned(1, 4)),
		14 => STD_LOGIC_VECTOR(to_unsigned(2, 4)),
		15 => STD_LOGIC_VECTOR(to_unsigned(3, 4)),
		16 => STD_LOGIC_VECTOR(to_unsigned(4, 4)),
		17 => STD_LOGIC_VECTOR(to_unsigned(5, 4)),
		18 => STD_LOGIC_VECTOR(to_unsigned(6, 4)),
		19 => STD_LOGIC_VECTOR(to_unsigned(7, 4)),
		20 => STD_LOGIC_VECTOR(to_unsigned(8, 4)),
		21 => STD_LOGIC_VECTOR(to_unsigned(9, 4)),
		22 => STD_LOGIC_VECTOR(to_unsigned(10, 4)),
		23 => STD_LOGIC_VECTOR(to_unsigned(11, 4)),
		24 => STD_LOGIC_VECTOR(to_unsigned(12, 4)),
		25 => STD_LOGIC_VECTOR(to_unsigned(13, 4)),
		26 => STD_LOGIC_VECTOR(to_unsigned(1, 4)),
		27 => STD_LOGIC_VECTOR(to_unsigned(2, 4)),
		28 => STD_LOGIC_VECTOR(to_unsigned(3, 4)),
		29 => STD_LOGIC_VECTOR(to_unsigned(4, 4)),
		30 => STD_LOGIC_VECTOR(to_unsigned(5, 4)),
		31 => STD_LOGIC_VECTOR(to_unsigned(6, 4)),
		32 => STD_LOGIC_VECTOR(to_unsigned(7, 4)),
		33 => STD_LOGIC_VECTOR(to_unsigned(8, 4)),
		34 => STD_LOGIC_VECTOR(to_unsigned(9, 4)),
		35 => STD_LOGIC_VECTOR(to_unsigned(10, 4)),
		36 => STD_LOGIC_VECTOR(to_unsigned(11, 4)),
		37 => STD_LOGIC_VECTOR(to_unsigned(12, 4)),
		38 => STD_LOGIC_VECTOR(to_unsigned(13, 4)),
		39 => STD_LOGIC_VECTOR(to_unsigned(1, 4)),
		40 => STD_LOGIC_VECTOR(to_unsigned(2, 4)),
		41 => STD_LOGIC_VECTOR(to_unsigned(3, 4)),
		42 => STD_LOGIC_VECTOR(to_unsigned(4, 4)),
		43 => STD_LOGIC_VECTOR(to_unsigned(5, 4)),
		44 => STD_LOGIC_VECTOR(to_unsigned(6, 4)),
		45 => STD_LOGIC_VECTOR(to_unsigned(7, 4)),
		46 => STD_LOGIC_VECTOR(to_unsigned(8, 4)),
		47 => STD_LOGIC_VECTOR(to_unsigned(9, 4)),
		48 => STD_LOGIC_VECTOR(to_unsigned(10, 4)),
		49 => STD_LOGIC_VECTOR(to_unsigned(11, 4)),
		50 => STD_LOGIC_VECTOR(to_unsigned(12, 4)),
		51 => STD_LOGIC_VECTOR(to_unsigned(13, 4))
	);
	
	SIGNAL SHUFFLED_INDEX: INTEGER := 0;


BEGIN
	-- lfsr and circular counter instances
	lfsr: lfsr_circular_counter GENERIC MAP (MODE => '0') PORT MAP (CLK, LFSR_SET_START, LFSR_SET_READY, LFSR_SET_VAL, LFSR_SHIFT_START, LFSR_SHIFT_READY, LFSR_OUTPUT);
	
	LFSR_SET_VAL <= SEED;

	PROCESS (CLK)
	BEGIN
		IF rising_edge(CLK) THEN
			IF (STATE = S_RESET AND SHUFFLE_START <= '1') THEN -- On shuffle start signal, shuffle ready goes low, initiate setting of lfsr with seed
				STATE <= S_SHUFFLE_START;
				SHUFFLE_READY <= '0';
				LFSR_SET_START <= '1';

			ELSIF (STATE = S_SHUFFLE_START AND LFSR_SET_READY = '0') THEN -- Intermediate lfsr setting stage
				STATE <= S_LFSR_SETTING;
				LFSR_SET_START <= '0';
			
			ELSIF (STATE = S_LFSR_SETTING AND LFSR_SET_READY = '1') THEN -- lfsr done setting
				STATE <= S_LFSR_SET;
			
			ELSIF (STATE = S_LFSR_SET) THEN -- Load the card into the shuffled deck, increment count of cards added
				STATE <= S_LOADED_UNSHUFFLED;
				SHUFFLED_CARDS(SHUFFLED_INDEX) <= UNSHUFFLED_CARDS(to_integer(UNSIGNED(LFSR_OUTPUT)));
				SHUFFLED_INDEX <= SHUFFLED_INDEX + 1;
			
			ELSIF (STATE = S_LOADED_UNSHUFFLED) THEN -- If all cards added, shuffle complete
				IF (SHUFFLED_INDEX > 51) THEN
					STATE <= S_SHUFFLED;
					SHUFFLE_READY <= '1';
					SHUFFLED_INDEX <= 0; -- Use shuffled index to pull out the cards from the shuffled deck
				ELSE
					STATE <= S_LFSR_SHIFT_START; -- Else initiate shift of lfsr
					LFSR_SHIFT_START <= '1';
				END IF;
			
			ELSIF (STATE = S_LFSR_SHIFT_START AND LFSR_SHIFT_READY = '0') THEN -- Intermediate lfsr shifting stage
				STATE <= S_LFSR_SHIFTING;
				LFSR_SHIFT_START <= '0';
			
			ELSIF (STATE = S_LFSR_SHIFTING AND LFSR_SHIFT_READY = '1') THEN -- lfsr done shifting, add the new one to deck
				STATE <= S_LFSR_SET;

			ELSIF ((STATE = S_SHUFFLED OR STATE = S_CARD_READY) AND CARD_START = '1') THEN -- Requested to get a new card
				STATE <= S_CARD_START;
				CARD_READY <= '0';
			
			ELSIF (STATE = S_CARD_START AND CARD_START = '0') THEN -- Intermediate stage of getting card
				STATE <= S_CARD_GETTING;
				CARD <= SHUFFLED_CARDS(SHUFFLED_INDEX);
				SHUFFLED_INDEX <= SHUFFLED_INDEX + 1;
				
			ELSIF (STATE = S_CARD_GETTING) THEN -- Card ready
				STATE <= S_CARD_READY;
				CARD_READY <= '1';
			END IF;
		END IF;
	END PROCESS;
	
END Behaviour;

