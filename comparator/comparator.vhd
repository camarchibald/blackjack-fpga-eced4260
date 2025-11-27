---------------------------------------------------
-- Author: Cameron Archibald, Nader Hdeib
-- Student ID: B00893056, B00898627
-- Date: 2025-11-16
-- File Name: comparator.vhd
-- Architecture: Dataflow, structural
-- Description: 6 bit comparator, chaining six single bit adders
--		Inputs are multiplexed to choose between different input signals
-- Acknowledgements: https://en.wikipedia.org/wiki/Digital_comparator, comparator equations
-------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.all;  

-- 6 bit comparator
ENTITY comparator IS
	GENERIC (SUM_MAX_BIT: INTEGER := 5); -- Max bit of comparator values
	PORT (PLAYER_INPUT, HOUSE_INPUT: IN STD_LOGIC_VECTOR(SUM_MAX_BIT DOWNTO 0); -- Running sum inputs to comparator
			VAL1_PLAYER, VAL1_HOUSE, VAL2_PLAYER, VAL2_HOUSE, VAL2_21, VAL2_17: IN STD_LOGIC; -- Control signals which values used in comparison. GT 1 if VAL1 > Val2, LT 1 if VAL1 < VAL2
			EQ, GT, LT: OUT STD_LOGIC); -- Equal, greater than, less than
END ENTITY;

ARCHITECTURE Behaviour OF comparator IS
	COMPONENT single_comparator
	PORT (A, B: IN STD_LOGIC; -- Comparator inputs
			EQ, GT, LT: OUT STD_LOGIC); -- Equal, A greater than B, A less than B		
	END COMPONENT;

	-- Comparator signals
	SIGNAL IN1_ARR, IN2_ARR, EQ_ARR, GT_ARR, LT_ARR: STD_LOGIC_VECTOR(SUM_MAX_BIT DOWNTO 0);

BEGIN
	-- Create single comparators and connect to the signal arrays
	SINGLE_COMPARATORS:
	FOR I IN 0 TO SUM_MAX_BIT GENERATE
		SA: single_comparator PORT MAP (A => IN1_ARR(I), B => IN2_ARR(I), EQ => EQ_ARR(I), GT => GT_ARR(I), LT => LT_ARR(I));
	END GENERATE SINGLE_COMPARATORS;

	-- Connect bit comparators to overall comparator equations
	EQ <= EQ_ARR(5) AND EQ_ARR(4) AND EQ_ARR(3) AND EQ_ARR(2) AND EQ_ARR(1) AND EQ_ARR(0);
	GT <= GT_ARR(5) OR 
			(EQ_ARR(5) AND GT_ARR(4)) OR 
			(EQ_ARR(5) AND EQ_ARR(4) AND GT_ARR(3)) OR 
			(EQ_ARR(5) AND EQ_ARR(4) AND EQ_ARR(3) AND GT_ARR(2)) OR 
			(EQ_ARR(5) AND EQ_ARR(4) AND EQ_ARR(3) AND EQ_ARR(2) AND GT_ARR(1)) OR 
			(EQ_ARR(5) AND EQ_ARR(4) AND EQ_ARR(3) AND EQ_ARR(2) AND EQ_ARR(1) AND GT_ARR(0));
	LT <= LT_ARR(5) OR 
			(EQ_ARR(5) AND LT_ARR(4)) OR 
			(EQ_ARR(5) AND EQ_ARR(4) AND LT_ARR(3)) OR 
			(EQ_ARR(5) AND EQ_ARR(4) AND EQ_ARR(3) AND LT_ARR(2)) OR 
			(EQ_ARR(5) AND EQ_ARR(4) AND EQ_ARR(3) AND EQ_ARR(2) AND LT_ARR(1)) OR 
			(EQ_ARR(5) AND EQ_ARR(4) AND EQ_ARR(3) AND EQ_ARR(2) AND EQ_ARR(1) AND LT_ARR(0));

	-- Select input 1 signal based on control
	IN1_ARR <= PLAYER_INPUT WHEN VAL1_PLAYER = '1' AND VAL1_HOUSE = '0' ELSE
				  HOUSE_INPUT WHEN VAL1_HOUSE = '1' AND VAL1_PLAYER = '0' ELSE
				  (OTHERS => '0');

	-- Select input 2 signal based on control
	IN2_ARR <= PLAYER_INPUT WHEN VAL2_PLAYER = '1' AND VAL2_HOUSE = '0' AND VAL2_21 = '0' AND VAL2_17 = '0' ELSE
				  HOUSE_INPUT WHEN VAL2_HOUSE = '1' AND VAL2_PLAYER = '0' AND VAL2_21 = '0' AND VAL2_17 = '0' ELSE
				  STD_LOGIC_VECTOR(TO_UNSIGNED(21, IN2_ARR'length)) WHEN VAL2_21 = '1' AND VAL2_PLAYER = '0' AND VAL2_HOUSE = '0' AND VAL2_17 = '0' ELSE
				  STD_LOGIC_VECTOR(TO_UNSIGNED(17, IN2_ARR'length)) WHEN VAL2_17 = '1' AND VAL2_PLAYER = '0' AND VAL2_HOUSE = '0' AND VAL2_21 = '0' ELSE
				  (OTHERS => '0');
		
END Behaviour;


LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.all;  

-- Single bit comparator
ENTITY single_comparator IS
	PORT (A, B: IN STD_LOGIC; -- Comparator inputs
			EQ, GT, LT: OUT STD_LOGIC); -- Equal, A greater than B, A less than B		
END ENTITY;

ARCHITECTURE Behaviour OF single_comparator IS

	BEGIN
	EQ <= A XNOR B;
	GT <= A AND (NOT B);
	LT <= (NOT A) AND B;

END Behaviour;





