----------------------------------------------------------------------------
-- Booth1_multiplier.vhd
--
-- section 8.4.4  Booth parallel multiplier for integer numbers
--
-- Computes: z = x·y
-- x: n+1 bits
-- y: m+1 bits
-- z: n+m+1 bits
-- 
----------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY Booth1_multiplier IS
  GENERIC(n: NATURAL:= 16; m: NATURAL:= 8);
PORT(
  x, u: IN STD_LOGIC_VECTOR(n DOWNTO 0);
  y: IN STD_LOGIC_VECTOR(m DOWNTO 0);
  z: OUT STD_LOGIC_VECTOR(n+m+1 DOWNTO 0)
);
END Booth1_multiplier;

ARCHITECTURE circuit OF Booth1_multiplier IS
  TYPE matrix IS ARRAY (0 TO m) OF STD_LOGIC_VECTOR(n+1 DOWNTO 0);
  SIGNAL a: matrix;
BEGIN

  a(0) <= ((u(n)&u) - (x(n)&x)) when y(0) = '1' ELSE u(n)&u;
  z(0) <= a(0)(0);

  main_iteration: FOR i IN 1 TO m GENERATE
    a(i) <= ((a(i-1)(n+1)&a(i-1)(n+1 DOWNTO 1)) - (x(n)&x)) WHEN (y(i-1) = '0' AND y(i) = '1') 
    ELSE ((a(i-1)(n+1)&a(i-1)(n+1 DOWNTO 1)) + (x(n)&x)) WHEN (y(i-1) = '1' AND y(i) = '0')
    ELSE a(i-1)(n+1)&a(i-1)(n+1 DOWNTO 1);
    z(i) <= a(i)(0);
  END GENERATE;

  z(n+m+1 DOWNTO m+1) <= a(m)(n+1 DOWNTO 1);
    
END circuit;


