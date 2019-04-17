----------------------------------------------------------------------------
-- csa.vhd
--
-- section 8.2.3 
-- a carry-save adder (3-to-2 counter or CSA). 
-- Used in seven_to_three and in N_by_7_multiplier
-- 
----------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.all;
ENTITY csa IS
  GENERIC(n: NATURAL);
PORT (
  x1, x2, x3: IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
  y1, y2: OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0)
);
END csa;

ARCHITECTURE behavior OF csa IS
BEGIN
  y2(0) <= '0';
  iteration: FOR i IN 0 TO n-2 GENERATE
    y1(i) <= x1(i) XOR x2(i) XOR x3(i);
    y2(i+1) <= (x1(i) AND x2(i)) OR (x1(i) AND x3(i)) OR (x2(i) AND x3(i));
  END GENERATE;
  y1(n-1) <= x1(n-1) XOR x2(n-1) XOR x3(n-1);
END behavior;
