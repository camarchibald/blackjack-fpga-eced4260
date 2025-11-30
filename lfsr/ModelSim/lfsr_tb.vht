---------------------------------------------------
-- Author: Cameron Archibald, Nader Hdeib
-- Student ID: B00893056, B00898627
-- Date: 2025-10-30
-- File Name: lfsr_tb.vht
-- Architecture: 
-- Description: Load value and observe the output of the lfsr, then reset and do again
-- Acknowledgements: 
-------------------------------------------------
LIBRARY IEEE;                                               
USE IEEE.std_logic_1164.all;    
USE IEEE.numeric_std.all;                            

ENTITY testbench IS
END testbench;

ARCHITECTURE Behaviour OF testbench IS
   COMPONENT lfsr
   GENERIC (HIGH_BIT: INTEGER := 5); -- Highest bit in register
	PORT 	  (CLK: IN STD_LOGIC; -- Rising edge clock
            RESET: IN STD_LOGIC; -- Asynchronous reset
				SET_START: IN STD_LOGIC; -- Initiate setting
				SET_READY: OUT STD_LOGIC := '1'; -- Low until setting complete
				SET_VAL: IN STD_LOGIC_VECTOR(5 DOWNTO 0); -- Reset number
				SHIFT_START: IN STD_LOGIC; -- Initiate shifting
				SHIFT_READY: OUT STD_LOGIC := '1'; -- Low until shifting complete
				OUTPUT: BUFFER STD_LOGIC_VECTOR(5 DOWNTO 0)); -- Value of generator
   END COMPONENT;

   -- Testbench signals
   SIGNAL CLK: STD_LOGIC := '0';
   SIGNAL RESET: STD_LOGIC := '0';
   SIGNAL SET_START: STD_LOGIC := '0';
   SIGNAL SET_READY: STD_LOGIC;
   SIGNAL SET_VAL: STD_LOGIC_VECTOR(5 DOWNTO 0) := "101010";
   SIGNAL SHIFT_START: STD_LOGIC := '0';
   SIGNAL SHIFT_READY: STD_LOGIC;
   SIGNAL OUTPUT: STD_LOGIC_VECTOR(5 DOWNTO 0);

   -- Testbench state
   TYPE T_STATE IS (S1, S2, S3, S4);
   SIGNAL STATE: T_STATE;

   -- How many times shifted
   SIGNAL COUNT: INTEGER:= 0;

BEGIN
   -- Create lfsr
   inst: lfsr PORT MAP (CLK, RESET, SET_START, SET_READY, SET_VAL, SHIFT_START, SHIFT_READY, OUTPUT);

   -- Run clock continuously
   PROCESS
   BEGIN
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
      -- SET signal start (load seed in)
         IF (STATE = S1 AND SET_READY = '1') THEN
            SET_START <= '1';
            RESET <= '0';
      -- Turn off set signal when ready signal goes low
         ELSIF (STATE = S1 AND SET_READY = '0') THEN
            STATE <= S2;
            SET_START <= '0';
      -- Set ready
         ELSIF (STATE = S2 AND SET_READY = '1') THEN
            STATE <= S3;
      -- Send shift signal
         ELSIF (STATE = S3 AND SHIFT_READY = '1') THEN
            SHIFT_START <= '1';
      -- Turn signal off once shift goes low
         ELSIF (STATE = S3 AND SHIFT_READY = '0') THEN
            STATE <= S4;
            SHIFT_START <= '0';
      -- If shifted 52 times, reset, change seed and start again
         ELSIF (STATE = S4 AND SHIFT_READY = '1') THEN
            IF (COUNT > 52) THEN
               COUNT <= 0;
               SET_VAL <= "111111"; -- Change seed
               RESET <= '1';
               STATE <= S1;
            ELSE 
               COUNT <= COUNT + 1;
               STATE <= S3;
            END IF;
         END IF;
      END IF;
   END PROCESS;
END;
