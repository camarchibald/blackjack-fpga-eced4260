---------------------------------------------------
-- Author: Cameron Archibald
-- Student ID: B00893056
-- Date: 2025-11-16
-- File Name: adder.vhd
-- Architecture: 
-- Description: 6 bit adder, add a card value to a running sum chosen from two channels
-- Acknowledgements: https://www.geeksforgeeks.org/digital-logic/full-adder-in-digital-logic/, full adder
-- 	https://www.geeksforgeeks.org/digital-logic/half-adder-in-digital-logic/, half adder
-------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.all;  

-- 6 bit adder
ENTITY adder IS
	GENERIC (SUM_MAX_BIT: INTEGER := 5; -- Max bit of the adder and sum
				CARD_MAX_BIT: INTEGER := 3); -- Max bit of the card
	PORT (CARD: IN STD_LOGIC_VECTOR(CARD_MAX_BIT DOWNTO 0); -- Card input to adder
			PLAYER_INPUT, HOUSE_INPUT: IN STD_LOGIC_VECTOR(SUM_MAX_BIT DOWNTO 0); -- Running sum inputs to adder
			PLAYER_OUTPUT, HOUSE_OUTPUT: OUT STD_LOGIC_VECTOR(SUM_MAX_BIT DOWNTO 0); -- Running sum outputs from adder
			PLAYER_SELECT, HOUSE_SELECT: IN STD_LOGIC); -- Control signals, 1 outputs the adder output, 0 outputs 0					
END ENTITY;

ARCHITECTURE Behaviour OF adder IS
	COMPONENT full_adder
	PORT (A, B, CIN: IN STD_LOGIC;
			SUM, COUT: OUT STD_LOGIC);			
	END COMPONENT;

	-- Adder signals, sum output is sufficiently large since the sum should never exceed the bits of the inputs
	SIGNAL IN1_ARR, IN2_ARR, CIN_ARR, COUT_ARR, SUM_ARR: STD_LOGIC_VECTOR(SUM_MAX_BIT DOWNTO 0);

BEGIN
	-- Create full adders and connect to signal arrays
	FULL_ADDERS:
	FOR I IN 0 TO SUM_MAX_BIT GENERATE
		FA: full_adder PORT MAP (A => IN1_ARR(I), B => IN2_ARR(I), CIN => CIN_ARR(I), SUM => SUM_ARR(I), COUT => COUT_ARR(I));

		CONNECT_CARRY:
		IF (I > 0) GENERATE
			CIN_ARR(I) <= COUT_ARR(I - 1); -- Connect cin, cout
		END GENERATE CONNECT_CARRY;
	END GENERATE FULL_ADDERS;

	-- No carry in
	CIN_ARR(0) <= '0';

	-- Card is input 1, fill the rest of the unused bits as zero (cards only go up to 11d which is 4 bits)
	IN1_ARR(CARD_MAX_BIT DOWNTO 0) <= CARD;
	IN1_ARR(SUM_MAX_BIT DOWNTO (CARD_MAX_BIT + 1)) <= (OTHERS => '0');

	-- Running sum is input 2
	IN2_ARR <= PLAYER_INPUT WHEN PLAYER_SELECT = '1' AND HOUSE_SELECT = '0' ELSE
				  HOUSE_INPUT WHEN HOUSE_SELECT = '1' AND PLAYER_SELECT = '0' ELSE
				  (OTHERS => '0');

	-- Player output choose between all zeros or adder output
	PLAYER_OUTPUT <= SUM_ARR WHEN PLAYER_SELECT = '1' ELSE
						  (OTHERS => '0');

	-- House output choose between all zeros or adder output
	HOUSE_OUTPUT <= SUM_ARR WHEN HOUSE_SELECT = '1' ELSE
						  (OTHERS => '0');
	
END Behaviour;


LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.all;  

-- Full adder built with two half adders
ENTITY full_adder IS
	PORT (A, B, CIN: IN STD_LOGIC;
			SUM, COUT: OUT STD_LOGIC);			
END ENTITY;

ARCHITECTURE Behaviour OF full_adder IS
	COMPONENT half_adder
	PORT (A, B: IN STD_LOGIC;
			SUM, COUT: OUT STD_LOGIC);	
	END COMPONENT;

	SIGNAL S_LOW, C_LOW, C_HIGH: STD_LOGIC; -- Sum, carry output of low, high half adder

	BEGIN
	half_adder_low: half_adder PORT MAP (A => A, B => B, SUM => S_LOW, COUT => C_LOW);
	half_adder_high: half_adder PORT MAP (A => CIN, B => S_LOW, SUM => SUM, COUT => C_HIGH);
	COUT <= C_LOW OR C_HIGH;
	
END Behaviour;


LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.all;  

-- Half adder
ENTITY half_adder IS
	PORT (A, B: IN STD_LOGIC;
			SUM, COUT: OUT STD_LOGIC);			
END ENTITY;

ARCHITECTURE Behaviour OF half_adder IS
BEGIN
	SUM <= A XOR B;
	COUT <= A AND B;
	
END Behaviour;





