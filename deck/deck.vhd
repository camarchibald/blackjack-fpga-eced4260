---------------------------------------------------
-- Author: Cameron Archibald, Nader Hdeib
-- Student ID: B00893056, B00898627
-- Date: 2025-11-11
-- File Name: deck.vhd
-- Architecture: Behavioural, Structural
-- Description: Implements a deck that shuffles cards and dispenses one card at a time
-- Acknowledgements: 
-------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.all;  

ENTITY deck IS
	GENERIC (LFSR_MAX_BIT: INTEGER := 5; -- Highest bit in lfsr
				CARD_MAX_BIT: INTEGER := 3); -- Highest bit of card
	PORT 	  (CLK: IN STD_LOGIC; -- Rising edge clock
				RESET: IN STD_LOGIC; -- Asynchronous reset						
				SHUFFLE_START: IN STD_LOGIC; -- Initiate shuffling					
				SHUFFLE_READY: OUT STD_LOGIC := '1'; -- Low until shuffling complete
				SEED: IN STD_LOGIC_VECTOR(LFSR_MAX_BIT DOWNTO 0); -- Seed to initialize lfsr
				CARD_START: IN STD_LOGIC; -- Initiate drawing card
				CARD_READY: OUT STD_LOGIC := '1'; -- Low until card value ready
				CARD: OUT STD_LOGIC_VECTOR(CARD_MAX_BIT DOWNTO 0); -- Card value
				CARD_OVERFLOW: OUT STD_LOGIC := '0'); -- 1 if the user requests too many cards from the deck
							
END ENTITY;

ARCHITECTURE Behaviour OF deck IS
	COMPONENT lfsr
	GENERIC (HIGH_BIT: INTEGER := 5); -- Highest bit in register
	PORT 	  (CLK: IN STD_LOGIC; -- Rising edge clock
				RESET: IN STD_LOGIC; -- Asynchronous reset
				SET_START: IN STD_LOGIC; -- Initiate setting
				SET_READY: OUT STD_LOGIC := '1'; -- Low until setting complete
				SET_VAL: IN STD_LOGIC_VECTOR(HIGH_BIT DOWNTO 0); -- Reset number
				SHIFT_START: IN STD_LOGIC; -- Initiate shifting
				SHIFT_READY: OUT STD_LOGIC := '1'; -- Low until shifting complete
				OUTPUT: BUFFER STD_LOGIC_VECTOR(HIGH_BIT DOWNTO 0)); -- Value of generator
	END COMPONENT;

	-- 52 cards
	CONSTANT MAX_CARD: INTEGER := 51;

	-- Deck states
	TYPE T_STATE IS (S_RESET, S_SHUFFLE_START, S_LFSR_SETTING, S_LFSR_SET, S_SHUFFLED_CHECK, S_SHUFFLED, S_LFSR_SHIFT_START, S_LFSR_SHIFTING, S_CARD_GETTING);
	SIGNAL STATE: T_STATE := S_RESET;

	-- Signals to connect to lfsr
	SIGNAL LFSR_SET_START, LFSR_SHIFT_START: STD_LOGIC := '0'; -- Initial zero (don't start anything)
	SIGNAL LFSR_SET_READY, LFSR_SHIFT_READY: STD_LOGIC;
	SIGNAL LFSR_SET_VAL, LFSR_OUTPUT: STD_LOGIC_VECTOR(LFSR_MAX_BIT DOWNTO 0);

	-- Array of unshuffled cards (in order), and array of shuffled cards (the deck)
	TYPE T_CARDS IS ARRAY(0 TO MAX_CARD) OF STD_LOGIC_VECTOR(CARD_MAX_BIT DOWNTO 0);
	SIGNAL SHUFFLED_CARDS : T_CARDS;
	CONSTANT UNSHUFFLED_CARDS : T_CARDS := (
		0  => STD_LOGIC_VECTOR(to_unsigned(1 , CARD_MAX_BIT + 1)),
		1  => STD_LOGIC_VECTOR(to_unsigned(2 , CARD_MAX_BIT + 1)),
		2  => STD_LOGIC_VECTOR(to_unsigned(3 , CARD_MAX_BIT + 1)),
		3  => STD_LOGIC_VECTOR(to_unsigned(4 , CARD_MAX_BIT + 1)),
		4  => STD_LOGIC_VECTOR(to_unsigned(5 , CARD_MAX_BIT + 1)),
		5  => STD_LOGIC_VECTOR(to_unsigned(6 , CARD_MAX_BIT + 1)),
		6  => STD_LOGIC_VECTOR(to_unsigned(7 , CARD_MAX_BIT + 1)),
		7  => STD_LOGIC_VECTOR(to_unsigned(8,  CARD_MAX_BIT + 1)),
		8  => STD_LOGIC_VECTOR(to_unsigned(9 , CARD_MAX_BIT + 1)),
		9  => STD_LOGIC_VECTOR(to_unsigned(10, CARD_MAX_BIT + 1)),
		10 => STD_LOGIC_VECTOR(to_unsigned(11, CARD_MAX_BIT + 1)),
		11 => STD_LOGIC_VECTOR(to_unsigned(12, CARD_MAX_BIT + 1)),
		12 => STD_LOGIC_VECTOR(to_unsigned(13, CARD_MAX_BIT + 1)),
		13 => STD_LOGIC_VECTOR(to_unsigned(1 , CARD_MAX_BIT + 1)),
		14 => STD_LOGIC_VECTOR(to_unsigned(2 , CARD_MAX_BIT + 1)),
		15 => STD_LOGIC_VECTOR(to_unsigned(3 , CARD_MAX_BIT + 1)),
		16 => STD_LOGIC_VECTOR(to_unsigned(4 , CARD_MAX_BIT + 1)),
		17 => STD_LOGIC_VECTOR(to_unsigned(5 , CARD_MAX_BIT + 1)),
		18 => STD_LOGIC_VECTOR(to_unsigned(6 , CARD_MAX_BIT + 1)),
		19 => STD_LOGIC_VECTOR(to_unsigned(7 , CARD_MAX_BIT + 1)),
		20 => STD_LOGIC_VECTOR(to_unsigned(8 , CARD_MAX_BIT + 1)),
		21 => STD_LOGIC_VECTOR(to_unsigned(9 , CARD_MAX_BIT + 1)),
		22 => STD_LOGIC_VECTOR(to_unsigned(10, CARD_MAX_BIT + 1)),
		23 => STD_LOGIC_VECTOR(to_unsigned(11, CARD_MAX_BIT + 1)),
		24 => STD_LOGIC_VECTOR(to_unsigned(12, CARD_MAX_BIT + 1)),
		25 => STD_LOGIC_VECTOR(to_unsigned(13, CARD_MAX_BIT + 1)),
		26 => STD_LOGIC_VECTOR(to_unsigned(1 , CARD_MAX_BIT + 1)),
		27 => STD_LOGIC_VECTOR(to_unsigned(2 , CARD_MAX_BIT + 1)),
		28 => STD_LOGIC_VECTOR(to_unsigned(3 , CARD_MAX_BIT + 1)),
		29 => STD_LOGIC_VECTOR(to_unsigned(4 , CARD_MAX_BIT + 1)),
		30 => STD_LOGIC_VECTOR(to_unsigned(5 , CARD_MAX_BIT + 1)),
		31 => STD_LOGIC_VECTOR(to_unsigned(6 , CARD_MAX_BIT + 1)),
		32 => STD_LOGIC_VECTOR(to_unsigned(7 , CARD_MAX_BIT + 1)),
		33 => STD_LOGIC_VECTOR(to_unsigned(8 , CARD_MAX_BIT + 1)),
		34 => STD_LOGIC_VECTOR(to_unsigned(9 , CARD_MAX_BIT + 1)),
		35 => STD_LOGIC_VECTOR(to_unsigned(10, CARD_MAX_BIT + 1)),
		36 => STD_LOGIC_VECTOR(to_unsigned(11, CARD_MAX_BIT + 1)),
		37 => STD_LOGIC_VECTOR(to_unsigned(12, CARD_MAX_BIT + 1)),
		38 => STD_LOGIC_VECTOR(to_unsigned(13, CARD_MAX_BIT + 1)),
		39 => STD_LOGIC_VECTOR(to_unsigned(1 , CARD_MAX_BIT + 1)),
		40 => STD_LOGIC_VECTOR(to_unsigned(2 , CARD_MAX_BIT + 1)),
		41 => STD_LOGIC_VECTOR(to_unsigned(3 , CARD_MAX_BIT + 1)),
		42 => STD_LOGIC_VECTOR(to_unsigned(4 , CARD_MAX_BIT + 1)),
		43 => STD_LOGIC_VECTOR(to_unsigned(5 , CARD_MAX_BIT + 1)),
		44 => STD_LOGIC_VECTOR(to_unsigned(6 , CARD_MAX_BIT + 1)),
		45 => STD_LOGIC_VECTOR(to_unsigned(7 , CARD_MAX_BIT + 1)),
		46 => STD_LOGIC_VECTOR(to_unsigned(8 , CARD_MAX_BIT + 1)),
		47 => STD_LOGIC_VECTOR(to_unsigned(9 , CARD_MAX_BIT + 1)),
		48 => STD_LOGIC_VECTOR(to_unsigned(10, CARD_MAX_BIT + 1)),
		49 => STD_LOGIC_VECTOR(to_unsigned(11, CARD_MAX_BIT + 1)),
		50 => STD_LOGIC_VECTOR(to_unsigned(12, CARD_MAX_BIT + 1)),
		51 => STD_LOGIC_VECTOR(to_unsigned(13, CARD_MAX_BIT + 1))
	);
	
	-- Position in the shuffled deck
	SIGNAL SHUFFLED_INDEX: INTEGER := 0;


BEGIN
	-- lfsr and circular counter instances
	lfsr_inst: lfsr GENERIC MAP (LFSR_MAX_BIT) PORT MAP (CLK, RESET, LFSR_SET_START, LFSR_SET_READY, LFSR_SET_VAL, LFSR_SHIFT_START, LFSR_SHIFT_READY, LFSR_OUTPUT);
	
	LFSR_SET_VAL <= SEED;

	PROCESS (CLK, RESET)
	BEGIN
	-- Reset signals and shuffled cards to zero
		IF (RESET = '1') THEN 
			STATE <= S_RESET;
			SHUFFLE_READY <= '1';
			CARD_READY <= '1';
			SHUFFLED_INDEX <= 0;
			SHUFFLED_CARDS <= (OTHERS => (OTHERS => '0')); -- Don't necessarily need to clear the shuffled cards since they will be overwritten
																		  -- for clarity in analysis, reset all to zero

		ELSIF (rising_edge(CLK)) THEN
		-- On shuffle start signal, shuffle ready goes low, initiate setting of lfsr with seed
			IF (STATE = S_RESET AND SHUFFLE_START = '1') THEN 
				STATE <= S_SHUFFLE_START;
				SHUFFLE_READY <= '0';
				LFSR_SET_START <= '1';

		-- Intermediate lfsr setting stage
			ELSIF (STATE = S_SHUFFLE_START AND LFSR_SET_READY = '0') THEN 
				STATE <= S_LFSR_SETTING;	
				LFSR_SET_START <= '0';

		-- lfsr done setting, perform first shift to ensure starting position is within 0-51 if the seed was above 51
			ELSIF (STATE = S_LFSR_SETTING AND LFSR_SET_READY = '1') THEN 
				STATE <= S_LFSR_SHIFT_START;
				LFSR_SHIFT_START <= '1';

		-- Load the card into the shuffled deck, increment count of cards added
			ELSIF (STATE = S_LFSR_SET) THEN 
				STATE <= S_SHUFFLED_CHECK;
				SHUFFLED_CARDS(SHUFFLED_INDEX) <= UNSHUFFLED_CARDS(to_integer(UNSIGNED(LFSR_OUTPUT)));
				SHUFFLED_INDEX <= SHUFFLED_INDEX + 1;

		-- If all cards added, shuffle complete
			ELSIF (STATE = S_SHUFFLED_CHECK) THEN 
			-- Not all cards added, get new card
				IF (SHUFFLED_INDEX <= MAX_CARD) THEN 
					STATE <= S_LFSR_SHIFT_START;
					LFSR_SHIFT_START <= '1';

			-- All cards added and start signal zero
				ELSIF (SHUFFLE_START = '0') THEN 
					STATE <= S_SHUFFLED;
					SHUFFLE_READY <= '1';
					SHUFFLED_INDEX <= 0; -- Use shuffled index to pull out the cards from the shuffled deck
				END IF;
			
		-- Intermediate lfsr shifting stage
			ELSIF (STATE = S_LFSR_SHIFT_START AND LFSR_SHIFT_READY = '0') THEN 
				STATE <= S_LFSR_SHIFTING;
				LFSR_SHIFT_START <= '0';
			
		-- lfsr done shifting, add the new one to deck
			ELSIF (STATE = S_LFSR_SHIFTING AND LFSR_SHIFT_READY = '1') THEN 
				STATE <= S_LFSR_SET;

		-- Requested to get a new card, unless too many cards requested
			ELSIF (STATE = S_SHUFFLED AND CARD_START = '1') THEN 
				IF (SHUFFLED_INDEX <= MAX_CARD) THEN
					STATE <= S_CARD_GETTING;
					CARD_READY <= '0';
					CARD <= SHUFFLED_CARDS(SHUFFLED_INDEX);
					SHUFFLED_INDEX <= SHUFFLED_INDEX + 1;
				ELSE
					CARD_OVERFLOW <= '1'; -- Indicate overflow, deck is stuck in this state
				END IF;
				
		-- Card ready
			ELSIF (STATE = S_CARD_GETTING AND CARD_START = '0') THEN 
				STATE <= S_SHUFFLED;
				CARD_READY <= '1';

			END IF;
		END IF;
	END PROCESS;
	
END Behaviour;

