---------------------------------------------------
-- Author: Cameron Archibald, Nader Hdeib
-- Student ID: B00893056, B00898627
-- Date: 2025-11-12
-- File Name: deck_tb.vht
-- Architecture: 
-- Description: Test the deck functionality.
--    Shuffles the deck and starts dealing cards then resets
--    After two cycles shuffle the deck and deal cards forever
--       Showing the card overflow signal (deck empty)
-- Acknowledgements: 
-------------------------------------------------
LIBRARY IEEE;                                               
USE IEEE.std_logic_1164.all;    
USE IEEE.numeric_std.all;                            

ENTITY testbench IS
END testbench;

ARCHITECTURE Behaviour OF testbench IS
   COMPONENT deck
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
   END COMPONENT;

   -- Testbench signals
   SIGNAL CLK: STD_LOGIC := '0';
   SIGNAL RESET: STD_LOGIC := '0';
   SIGNAL SHUFFLE_START: STD_LOGIC := '0';
   SIGNAL SHUFFLE_READY: STD_LOGIC;
   SIGNAL SEED: STD_LOGIC_VECTOR(5 DOWNTO 0);
   SIGNAL CARD_START: STD_LOGIC := '0';
   SIGNAL CARD_READY: STD_LOGIC;
   SIGNAL CARD: STD_LOGIC_VECTOR(3 DOWNTO 0);
   SIGNAL CARD_OVERFLOW: STD_LOGIC;

   -- Testbench state
   TYPE T_STATE IS (S1, S2, S3, S4, S5, S6);
   SIGNAL STATE: T_STATE;

   SIGNAL COUNT: INTEGER := 0; -- Count of cards given before reset signal
   SIGNAL RESET_COUNT: INTEGER := 0; -- Count of how many times we have reset

BEGIN
   -- Create deck
   deck_inst: deck PORT MAP (CLK, RESET, SHUFFLE_START, SHUFFLE_READY, SEED, CARD_START, CARD_READY, CARD, CARD_OVERFLOW);

   -- Run clock continuously
   PROCESS
   BEGIN
   --Initialize seed
   SEED <= "111010";

   WHILE (1 = 1) LOOP
      WAIT FOR 5 ns;
      CLK <= '1';
      WAIT FOR 5 ns;
      CLK <= '0';
   END LOOP;
   END PROCESS;

   -- Testbench state machine
   PROCESS (CLK)
   BEGIN
      IF rising_edge(CLK) THEN
      -- Send shuffle start signal
         IF (STATE = S1 AND SHUFFLE_READY = '1') THEN
            SHUFFLE_START <= '1';
            RESET <= '0';
      -- Turn off shuffle start signal once ready is low
         ELSIF (STATE = S1 AND SHUFFLE_READY = '0') THEN
            STATE <= S2;
            SHUFFLE_START <= '0';
      -- Shuffle complete
         ELSIF (STATE = S2 AND SHUFFLE_READY = '1') THEN
            STATE <= S3;
      -- Send draw card signal
         ELSIF (STATE = S3 AND CARD_READY = '1') THEN
            CARD_START <= '1';
      -- Turn off draw card signal once ready is low
         ELSIF (STATE = S3 AND CARD_READY = '0') THEN
            STATE <= S4;
            CARD_START <= '0';
      -- Card ready
         ELSIF (STATE = S4 AND CARD_READY = '1') THEN
            STATE <= S5;
      -- Before 10 iterations draw another card, else apply reset
         ELSIF (STATE = S5) THEN
            IF (COUNT > 10) THEN
            -- If we've already reset twice, continue drawing cards to show overflow signal
               IF (RESET_COUNT >= 2) THEN
                  STATE <= S3;
                  COUNT <= COUNT + 1;
               ELSE 
                  STATE <= S6;
                  RESET <= '1';
                  COUNT <= 0;
                  RESET_COUNT <= RESET_COUNT + 1;
               END IF;
            ELSE
               STATE <= S3;
               COUNT <= COUNT + 1;
            END IF;
      -- Turn off reset and initiate shuffle again
         ELSIF (STATE = S6) THEN
            STATE <= S1;
            RESET <= '0';
         END IF;
      END IF;
   END PROCESS;

END;
