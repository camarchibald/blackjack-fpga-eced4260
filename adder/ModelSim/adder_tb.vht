---------------------------------------------------
-- Author: Cameron Archibald
-- Student ID: B00893056
-- Date: 2025-11-16
-- File Name: adder_tb.vht
-- Architecture: 
-- Description: Test the adder functionality
-- Acknowledgements: 
-------------------------------------------------
LIBRARY IEEE;                                               
USE IEEE.std_logic_1164.all;    
USE IEEE.numeric_std.all;                            

ENTITY testbench IS
END testbench;

ARCHITECTURE Behaviour OF testbench IS
   COMPONENT adder IS
	GENERIC (SUM_MAX_BIT: INTEGER := 5; -- Max bit of the adder and sum
				CARD_MAX_BIT: INTEGER := 3); -- Max bit of the card
	PORT (CARD: IN STD_LOGIC_VECTOR(CARD_MAX_BIT DOWNTO 0); -- Card input to adder
			PLAYER_INPUT, HOUSE_INPUT: IN STD_LOGIC_VECTOR(SUM_MAX_BIT DOWNTO 0); -- Running sum inputs to adder
			PLAYER_OUTPUT, HOUSE_OUTPUT: OUT STD_LOGIC_VECTOR(SUM_MAX_BIT DOWNTO 0); -- Running sum outputs from adder
			PLAYER_SELECT, HOUSE_SELECT: IN STD_LOGIC); -- Control signals, 1 outputs the adder output, 0 outputs 0					
   END COMPONENT;

   CONSTANT SUM_MAX_BIT: INTEGER := 5;
   CONSTANT CARD_MAX_BIT: INTEGER := 3;

   -- Testbench signals
   SIGNAL CARD: STD_LOGIC_VECTOR(CARD_MAX_BIT DOWNTO 0); 
	SIGNAL PLAYER_INPUT, HOUSE_INPUT: STD_LOGIC_VECTOR(SUM_MAX_BIT DOWNTO 0); 
	SIGNAL PLAYER_OUTPUT, HOUSE_OUTPUT: STD_LOGIC_VECTOR(SUM_MAX_BIT DOWNTO 0); 
   SIGNAL PLAYER_SELECT, HOUSE_SELECT: STD_LOGIC; 

BEGIN
   adder_inst: adder GENERIC MAP (SUM_MAX_BIT, CARD_MAX_BIT) PORT MAP (CARD, PLAYER_INPUT, HOUSE_INPUT, PLAYER_OUTPUT, HOUSE_OUTPUT, PLAYER_SELECT, HOUSE_SELECT);

   PROCESS
   BEGIN 

   -- Select zero, output zero
   CARD <= STD_LOGIC_VECTOR(to_unsigned(5, CARD'length));
   PLAYER_INPUT <= STD_LOGIC_VECTOR(to_unsigned(4, PLAYER_INPUT'length));
   HOUSE_INPUT <= STD_LOGIC_VECTOR(to_unsigned(3, PLAYER_INPUT'length));
   PLAYER_SELECT <= '0'; HOUSE_SELECT <= '0';
   WAIT FOR 5 ns;

   -- Both selects 1, input zero, output adder to both player and house
   PLAYER_SELECT <= '1'; HOUSE_SELECT <= '1';
   WAIT FOR 5 ns;

   -- Player select 1, input from player, output goes to player
   PLAYER_SELECT <= '1'; HOUSE_SELECT <= '0';
   FOR I IN 0 TO 21 LOOP -- Loop through all possible values of running sum
      PLAYER_INPUT <= STD_LOGIC_VECTOR(to_unsigned(I, PLAYER_INPUT'length));
      FOR J IN 0 TO 11 LOOP -- Loop through all possible card values
         CARD <= STD_LOGIC_VECTOR(to_unsigned(J, CARD'length));
         WAIT FOR 5 ns;
      END LOOP;
   END LOOP;

   -- House select 1, input from house, output goes to house
   HOUSE_SELECT <= '1'; PLAYER_SELECT <= '0';
   FOR I IN 0 TO 21 LOOP -- Loop through all possible values of running sum
      HOUSE_INPUT <= STD_LOGIC_VECTOR(to_unsigned(I, HOUSE_INPUT'length));
      FOR J IN 0 TO 11 LOOP -- Loop through all possible card values
         CARD <= STD_LOGIC_VECTOR(to_unsigned(J, CARD'length));
         WAIT FOR 5 ns;
      END LOOP;
   END LOOP;

   WAIT;
   END PROCESS;

END;
