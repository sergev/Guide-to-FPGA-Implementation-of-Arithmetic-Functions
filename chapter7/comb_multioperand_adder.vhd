----------------------------------------------------------------------------
-- comb_multioperand_adder.vhd
--
-- section 7.7.2 combinational multioperand adder
-- m: number of operands of n bits
-- n: size of each operand
-- x = x0 & x1 & ... & xm-1
-- Z = x0 + x1 + ... + xm-1 mod 2^n
-- 
----------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY comb_multioperand_adder IS
  GENERIC(n: NATURAL:= 8; m: NATURAL:= 8);
PORT(
  x: IN STD_LOGIC_VECTOR(n*m-1 DOWNTO 0);
  z: OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0)
);
END comb_multioperand_adder;

ARCHITECTURE circuit OF comb_multioperand_adder IS
  SIGNAL y: STD_LOGIC_VECTOR(n*m-1 DOWNTO n);
BEGIN
   y(2*n-1 DOWNTO n) <= x(2*n-1 DOWNTO n) + x(n-1 DOWNTO 0);
   iteration: FOR i in 2 TO m-1 GENERATE
      y(i*n+n-1 DOWNTO i*n) <= y(i*n-1 DOWNTO i*n-n) + x(i*n+n-1 DOWNTO i*n);
   END GENERATE;
   z <= y(m*n-1 DOWNTO m*n-n);
END circuit;
