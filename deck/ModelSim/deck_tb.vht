---------------------------------------------------
-- Author: Cameron Archibald
-- Student ID: B00893056
-- Date: 2025-11-12
-- File Name: deck_tb.vht
-- Architecture: 
-- Description: Test the deck functionality
-- Acknowledgements: 
-------------------------------------------------
LIBRARY IEEE;                                               
USE IEEE.std_logic_1164.all;    
USE IEEE.numeric_std.all;                            

ENTITY testbench IS
END testbench;

ARCHITECTURE Behaviour OF testbench IS
   COMPONENT deck
	PORT 	  (CLK: IN STD_LOGIC; -- Rising edge clock							
				SHUFFLE_START: IN STD_LOGIC; -- Initiate shuffling					
				SHUFFLE_READY: OUT STD_LOGIC := '1'; -- Low until shuffling complete
				SEED: IN STD_LOGIC_VECTOR(5 DOWNTO 0); -- Seed to initialize lfsr
				CARD_START: IN STD_LOGIC; -- Initiate drawing card
				CARD_READY: OUT STD_LOGIC := '1'; -- Low until card value ready
				CARD: OUT STD_LOGIC_VECTOR(3 DOWNTO 0)); -- Card value			
   END COMPONENT;

   SIGNAL CLK: STD_LOGIC := '0';
   SIGNAL SHUFFLE_START: STD_LOGIC := '0';
   SIGNAL SHUFFLE_READY: STD_LOGIC;
   SIGNAL SEED: STD_LOGIC_VECTOR(5 DOWNTO 0);
   SIGNAL CARD_START: STD_LOGIC := '0';
   SIGNAL CARD_READY: STD_LOGIC;
   SIGNAL CARD: STD_LOGIC_VECTOR(3 DOWNTO 0);

   -- Testbench state
   TYPE T_STATE IS (S1, S2, S3, S4, S5);
   SIGNAL STATE: T_STATE;

BEGIN
   deck_inst: deck PORT MAP (CLK, SHUFFLE_START, SHUFFLE_READY, SEED, CARD_START, CARD_READY, CARD);

   -- Run clock continuously
   PROCESS
   BEGIN
   SEED <= "101010";
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
         IF (STATE = S1 AND SHUFFLE_READY = '1') THEN
            SHUFFLE_START <= '1';
         ELSIF (STATE = S1 AND SHUFFLE_READY = '0') THEN
            STATE <= S2;
            SHUFFLE_START <= '0';
         ELSIF (STATE = S2 AND SHUFFLE_READY = '1') THEN
            STATE <= S3;
         ELSIF (STATE = S3 AND CARD_READY = '1') THEN
            CARD_START <= '1';
         ELSIF (STATE = S3 AND CARD_READY = '0') THEN
            STATE <= S4;
            CARD_START <= '0';
         ELSIF (STATE = S4 AND CARD_READY = '1') THEN
            STATE <= S5;
         ELSIF (STATE = S5) THEN
            STATE <= S3;
         END IF;
      END IF;
   END PROCESS;

END;
