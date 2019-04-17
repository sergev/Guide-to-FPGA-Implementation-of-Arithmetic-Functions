----------------------------------------------------------------------------
-- synthesis_multiplier.vhd
--
-- section 8.2. Compare against synthesis default mult
--
-- Computes: z = x·y + u + v
-- x, u: n bits
-- y, v: m bits
-- z: n+m bits
-- 
----------------------------------------------------------------------------


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY synthesis_multiplier IS
  GENERIC(n: NATURAL:= 8; m: NATURAL:= 8);
PORT(
  x, u: IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
  y, v: IN STD_LOGIC_VECTOR(m-1 DOWNTO 0);
  z: OUT STD_LOGIC_VECTOR(n+m-1 DOWNTO 0)
);
END synthesis_multiplier;

ARCHITECTURE circuit OF synthesis_multiplier IS
 
signal z1: STD_LOGIC_VECTOR(n+m-1 DOWNTO 0);
attribute mult_style: string;
attribute mult_style of z1 : signal is "lut";
BEGIN
  z1 <= x*y;
  z <= z1 + u + v;
END circuit;

