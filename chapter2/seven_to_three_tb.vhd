------------------------------------------------------------------
-- seven_to_three_tb.vhd
-- Simple Testbench for introductoy example 2.3.1 
-- 
-------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.all;
ENTITY test_counter IS END test_counter;

ARCHITECTURE test OF test_counter IS
  COMPONENT seven_to_three IS
    GENERIC(n: NATURAL);
  PORT (
    x1, x2, x3, x4, x5, x6, x7: IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
    y1, y2, y3: OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0)
  );
  END COMPONENT;
  SIGNAL x1, x2, x3, x4, x5, x6, x7, y1, y2, y3: STD_LOGIC_VECTOR(7 DOWNTO 0);
BEGIN
  dut: seven_to_three GENERIC MAP(n => 8)
  PORT MAP(x1 => x1, x2 => x2, x3 => x3, x4 => x4, x5 => x5, x6 => x6, x7 => x7, 
  y1 => y1, y2 => y2, y3 => y3);
  x1 <= "00110011"; x2 <= "01010101"; x3 <= "00000111"; x4 <= "01000100";
  x5 <= "00110110"; x6 <= "01100011"; 
  x7 <= "00000000", "11111111" after 100 ns;
END test;