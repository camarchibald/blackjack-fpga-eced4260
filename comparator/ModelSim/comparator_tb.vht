---------------------------------------------------
-- Author: Cameron Archibald
-- Student ID: B00893056
-- Date: 2025-11-16
-- File Name: comparator_tb.vht
-- Architecture: 
-- Description: Test the comparator functionality
-- Acknowledgements: 
-------------------------------------------------
LIBRARY IEEE;                                               
USE IEEE.std_logic_1164.all;    
USE IEEE.numeric_std.all;                            

ENTITY testbench IS
END testbench;

ARCHITECTURE Behaviour OF testbench IS
   COMPONENT comparator
	GENERIC (SUM_MAX_BIT: INTEGER := 5); -- Max bit of comparator values
	PORT (PLAYER_INPUT, HOUSE_INPUT: IN STD_LOGIC_VECTOR(SUM_MAX_BIT DOWNTO 0); -- Running sum inputs to comparator
			VAL1_PLAYER, VAL1_HOUSE, VAL2_PLAYER, VAL2_HOUSE, VAL2_21, VAL2_17: IN STD_LOGIC; -- Control signals which values used in comparison. GT 1 if VAL1 > Val2, LT 1 if VAL1 < VAL2
			EQ, GT, LT: OUT STD_LOGIC); -- Equal, greater than, less than
   END COMPONENT;

   CONSTANT SUM_MAX_BIT: INTEGER := 5;

   -- Testbench signals
	SIGNAL PLAYER_INPUT, HOUSE_INPUT: STD_LOGIC_VECTOR(SUM_MAX_BIT DOWNTO 0); 
	SIGNAL VAL1_PLAYER, VAL1_HOUSE, VAL2_PLAYER, VAL2_HOUSE, VAL2_21, VAL2_17: STD_LOGIC;
   SIGNAL EQ, GT, LT: STD_LOGIC; 

BEGIN
   comparator_inst: comparator GENERIC MAP (SUM_MAX_BIT) PORT MAP (PLAYER_INPUT, HOUSE_INPUT, VAL1_PLAYER, VAL1_HOUSE, VAL2_PLAYER, VAL2_HOUSE, VAL2_21, VAL2_17, EQ, GT, LT);

   PROCESS
   BEGIN 

   -- All inputs 1, both inputs default to all zeros thus EQ expected.
   PLAYER_INPUT <= STD_LOGIC_VECTOR(to_unsigned(4, PLAYER_INPUT'length));
   HOUSE_INPUT <= STD_LOGIC_VECTOR(to_unsigned(3, HOUSE_INPUT'length));
   VAL1_PLAYER <= '1'; VAL1_HOUSE <= '1'; VAL2_PLAYER <= '1'; VAL2_HOUSE <= '1'; VAL2_21 <= '1'; VAL2_17 <= '1';
   WAIT FOR 5 ns;

   -- All inputs 0, both inputs default to all zeros thus EQ expected.
   VAL1_PLAYER <= '0'; VAL1_HOUSE <= '0'; VAL2_PLAYER <= '0'; VAL2_HOUSE <= '0'; VAL2_21 <= '0'; VAL2_17 <= '0';
   WAIT FOR 5 ns;

   -- Player compared against house
   VAL1_PLAYER <= '1'; VAL1_HOUSE <= '0'; VAL2_PLAYER <= '0'; VAL2_HOUSE <= '1'; VAL2_21 <= '0'; VAL2_17 <= '0';
   FOR I IN 1 TO 21 LOOP -- No comp above 21 since that is a bust
      PLAYER_INPUT <= STD_LOGIC_VECTOR(to_unsigned(I, PLAYER_INPUT'length));
      FOR J IN 17 TO 21 LOOP -- House hits on 16, can't be below 17
         HOUSE_INPUT <= STD_LOGIC_VECTOR(to_unsigned(J, HOUSE_INPUT'length));
         WAIT FOR 5 ns;
      END LOOP;
   END LOOP;

   -- Player compared against bust
   VAL1_PLAYER <= '1'; VAL1_HOUSE <= '0'; VAL2_PLAYER <= '0'; VAL2_HOUSE <= '0'; VAL2_21 <= '1'; VAL2_17 <= '0';
   FOR I IN 1 TO 32 LOOP -- 32 is highest that can be achieved with 21 + hit (11)
      PLAYER_INPUT <= STD_LOGIC_VECTOR(to_unsigned(I, PLAYER_INPUT'length));
      WAIT FOR 5 ns;
   END LOOP;

   -- House compared against bust
   VAL1_PLAYER <= '0'; VAL1_HOUSE <= '1'; VAL2_PLAYER <= '0'; VAL2_HOUSE <= '0'; VAL2_21 <= '1'; VAL2_17 <= '0';
   FOR I IN 1 TO 27 LOOP -- 27 is highest that can be achieved with 16 + hit (11)
      HOUSE_INPUT <= STD_LOGIC_VECTOR(to_unsigned(I, HOUSE_INPUT'length));
      WAIT FOR 5 ns;
   END LOOP;

   -- House compared against 17 (decide to hit or not)
   VAL1_PLAYER <= '0'; VAL1_HOUSE <= '1'; VAL2_PLAYER <= '0'; VAL2_HOUSE <= '0'; VAL2_21 <= '0'; VAL2_17 <= '1';
   FOR I IN 1 TO 21 LOOP -- 27 is highest that can be achieved with 16 + hit (11)
      HOUSE_INPUT <= STD_LOGIC_VECTOR(to_unsigned(I, HOUSE_INPUT'length));
      WAIT FOR 5 ns;
   END LOOP;

   WAIT;
   END PROCESS;

END;
