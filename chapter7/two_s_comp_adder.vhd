----------------------------------------------------------------------------
-- two_s_comp_adder.vhd
--
-- section 7.8 subtractor and adder subtractor
-- A two´s complement adder
--
----------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY two_s_comp_adder IS
  GENERIC(n: NATURAL);
PORT(
  x, y: IN STD_LOGIC_VECTOR(n DOWNTO 0);
  c_in: IN STD_LOGIC;
  z: OUT STD_LOGIC_VECTOR(n+1 DOWNTO 0)
);
END two_s_comp_adder;

ARCHITECTURE behavior OF two_s_comp_adder IS
BEGIN
  z <= (x(n)&x) + (y(n)&y) + c_in;
END behavior;
