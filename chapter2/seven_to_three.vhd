----------------------------------------------------------------
-- seven_to_three.vhd
-- seven to three counter in Introductoy example 2.3.1. 
-- 
----------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.all;
ENTITY seven_to_three IS
  GENERIC(n: NATURAL:= 8);
PORT (
  x1, x2, x3, x4, x5, x6, x7: IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
  y1, y2, y3: OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0)
);
END seven_to_three;

ARCHITECTURE circuit OF seven_to_three IS
  COMPONENT csa IS
    GENERIC(n: NATURAL);
  PORT (
    x1, x2, x3: IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
    y1, y2: OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0)
  );
  END COMPONENT;
  SIGNAL a1, a2, b1, b2, c1, c2, d1, d2: STD_LOGIC_VECTOR(n-1 DOWNTO 0);
BEGIN
  first_csa: csa GENERIC MAP(n => n)
  PORT MAP(x1 => x1, x2 => x2, x3 => x3, y1 => a1, y2 => a2);
  second_csa: csa GENERIC MAP(n => n) 
  PORT MAP(x1 => x4, x2 => x5, x3 => x6, y1 => b1, y2 => b2);
  third_csa: csa GENERIC MAP(n => n) 
  PORT MAP(x1 => a2, x2 => b2, x3 => x7, y1 => c1, y2 => c2);
  fourth_csa: csa GENERIC MAP(n => n) 
  PORT MAP(x1 => a1, x2 => b1, x3 => c1, y1 => d1, y2 => d2);
  y1 <= d1; y2 <= d2; y3 <= c2;
END circuit;