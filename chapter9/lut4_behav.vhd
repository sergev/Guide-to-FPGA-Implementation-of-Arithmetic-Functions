----------------------------------------------------------------------------
-- lut4_behav.vhd
--
-- section 9.3 radix-B divider
-- behavioural description of a LUT (4 inputs look up table)
--
----------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.all;
ENTITY lut4b IS
    GENERIC(truth_vector: STD_LOGIC_VECTOR(0 to 15));
PORT (
  a: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
  b: OUT STD_LOGIC 
);
END lut4b;
 
ARCHITECTURE behavior OF lut4b IS
BEGIN
  PROCESS(a)
    VARIABLE c: NATURAL; 
  BEGIN
    c := CONV_INTEGER(a);
    b <= truth_vector(c);
  END PROCESS; 
END behavior;
