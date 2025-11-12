---------------------------------------------------
-- Author: Cameron Archibald
-- Student ID: B00893056
-- Date: 2025-10-30
-- File Name: lfsr_tb.vht
-- Architecture: 
-- Description: Test the pseudo random number generator by loading various numbers and observing the sequence of numbers
-- Acknowledgements: 
-------------------------------------------------
LIBRARY IEEE;                                               
USE IEEE.std_logic_1164.all;    
USE IEEE.numeric_std.all;                            

ENTITY testbench IS
END testbench;

ARCHITECTURE Behaviour OF testbench IS
   COMPONENT lfsr
	PORT 	  (CLK: IN STD_LOGIC; -- Rising edge clock
				SET_START: IN STD_LOGIC; -- Initiate setting
				SET_READY: OUT STD_LOGIC := '1'; -- Low until setting complete
				SET_VAL: IN STD_LOGIC_VECTOR(5 DOWNTO 0); -- Reset number
				SHIFT_START: IN STD_LOGIC; -- Initiate shifting
				SHIFT_READY: OUT STD_LOGIC := '1'; -- Low until shifting complete
				OUTPUT: BUFFER STD_LOGIC_VECTOR(5 DOWNTO 0)); -- Value of generator
   END COMPONENT;

   SIGNAL CLK: STD_LOGIC := '0';
   SIGNAL SET_START: STD_LOGIC := '0';
   SIGNAL SET_READY: STD_LOGIC;
   SIGNAL SET_VAL: STD_LOGIC_VECTOR(5 DOWNTO 0);
   SIGNAL SHIFT_START: STD_LOGIC := '0';
   SIGNAL SHIFT_READY: STD_LOGIC;
   SIGNAL OUTPUT: STD_LOGIC_VECTOR(5 DOWNTO 0);

   TYPE T_STATE IS (S1, S2, S3, S4, S5);
   SIGNAL STATE: T_STATE;

BEGIN
   inst: lfsr PORT MAP (CLK, SET_START, SET_READY, SET_VAL, SHIFT_START, SHIFT_READY, OUTPUT);

   PROCESS
   BEGIN
   WHILE (1 = 1) LOOP
      WAIT FOR 5 ns;
      CLK <= '1';
      WAIT FOR 5 ns;
      CLK <= '0';
   END LOOP;
   END PROCESS;

   PROCESS (CLK)
   BEGIN
      IF rising_edge(CLK) THEN
         IF (STATE = S1) THEN
            STATE <= S2;
            SET_START <= '1';
         ELSIF (STATE = S2 AND START_)
         END IF;
      END IF;
   END PROCESS;
END;
