---------------------------------------------------
-- Author: Cameron Archibald
-- Student ID: B00893056
-- Date: 2025-10-30
-- File Name: circular_counter_tb.vht
-- Architecture: 
-- Description: Test circular counter by applying various set signals and clocking to see values wrap around
-- Acknowledgements: 
-------------------------------------------------
LIBRARY IEEE;                                               
USE IEEE.std_logic_1164.all;    
USE IEEE.numeric_std.all;                            

ENTITY testbench IS
END testbench;

ARCHITECTURE Behaviour OF testbench IS
   COMPONENT circular_counter
	GENERIC (MAX: INTEGER := 51); 								-- Max value of counter, default 51
	PORT 	  (CLK, SET: IN STD_LOGIC; 							-- Clock signal actuate updates on rising edge, set signal active high
				SET_VAL: IN STD_LOGIC_VECTOR(5 DOWNTO 0); 	-- Reset number
				OUTPUT: OUT STD_LOGIC_VECTOR(5 DOWNTO 0)); 	-- Value of counter
   END COMPONENT;

   SIGNAL CLK_TB: STD_LOGIC := '0';
   SIGNAL SET_TB: STD_LOGIC;
   SIGNAL SET_VAL_TB, OUTPUT_TB: STD_LOGIC_VECTOR(5 DOWNTO 0);

BEGIN
   inst: circular_counter PORT MAP (CLK_TB, SET_TB, SET_VAL_TB, OUTPUT_TB);

   PROCESS           
	BEGIN

   -- Load 4 then run counter 6 times
   SET_VAL_TB <= "000100";
   SET_TB <= '1';

   WAIT FOR 5 ns;

   CLK_TB <= '1';

   WAIT FOR 5 ns;

   CLK_TB <= '0';
   SET_TB <= '0';

   FOR I IN 1 TO 6 LOOP
      WAIT FOR 5 ns;
      CLK_TB <= '1';

      WAIT FOR 5 ns;
      CLK_TB <= '0';
   END LOOP;

   -- Load 37 then run counter 60 times
   SET_VAL_TB <= "100101";
   SET_TB <= '1';

   WAIT FOR 5 ns;

   CLK_TB <= '1';

   WAIT FOR 5 ns;

   CLK_TB <= '0';
   SET_TB <= '0';

   FOR I IN 1 TO 60 LOOP
      WAIT FOR 5 ns;
      CLK_TB <= '1';

      WAIT FOR 5 ns;
      CLK_TB <= '0';
   END LOOP;

   -- Load 51 then run counter 60 times
   SET_VAL_TB <= "110011";
   SET_TB <= '1';

   WAIT FOR 5 ns;

   CLK_TB <= '1';

   WAIT FOR 5 ns;

   CLK_TB <= '0';
   SET_TB <= '0';

   FOR I IN 1 TO 60 LOOP
      WAIT FOR 5 ns;
      CLK_TB <= '1';

      WAIT FOR 5 ns;
      CLK_TB <= '0';
   END LOOP;

   -- Load 0 then run counter 60 times
   SET_VAL_TB <= "000000";
   SET_TB <= '1';

   WAIT FOR 5 ns;

   CLK_TB <= '1';

   WAIT FOR 5 ns;

   CLK_TB <= '0';
   SET_TB <= '0';

   FOR I IN 1 TO 60 LOOP
      WAIT FOR 5 ns;
      CLK_TB <= '1';

      WAIT FOR 5 ns;
      CLK_TB <= '0';
   END LOOP;

   WAIT;

   END PROCESS;

END;
