----------------------------------------------------------------------------
-- eight_operand_adder.vhd
--
-- section 7.7.2 combinational 8-operand adder
-- n: size of each operand
-- z = x0 + x1 + ... + x7 mod 2^n
-- 
----------------------------------------------------------------------------


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY eight_operand_adder IS
  GENERIC(n: NATURAL:= 16);
PORT(
  x0, x1, x2, x3, x4, x5, x6, x7: IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
  z: OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0)
);
END eight_operand_adder;

ARCHITECTURE circuit OF eight_operand_adder IS
  SIGNAL y0, y1, y2, y3, y4, y5: STD_LOGIC_VECTOR(n-1 DOWNTO 0);
BEGIN
  y0 <= x0 + x1;
  y1 <= x2 + x3;
  y2 <= x4 + x5;
  y3 <= x6 + x7;
  y4 <= y0 + y1;
  y5 <= y2 + y3;
  z <= y4 + y5;
END circuit;
