------------------------------------------------------------------
-- csa_tb.vhd
-- Simple Testbench for n-bit carry save adder
-- 
-------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.all;
ENTITY test_csa is END test_csa;

ARCHITECTURE test OF test_csa IS
  COMPONENT csa IS
    GENERIC(n: NATURAL);
  PORT (
    x1, x2, x3: IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
    y1, y2: OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0)
  );
  END COMPONENT;
  SIGNAL x1, x2, x3, y1, y2: STD_LOGIC_VECTOR(7 DOWNTO 0);
BEGIN
  dut: csa GENERIC MAP(n => 8) 
  PORT MAP(x1 => x1, x2 => x2, x3 => x3, y1 => y1, y2 => y2);
  x1 <= "01001101", "01111110" after 100 ns;
  x2 <= "01010101", "00011001" after 200 ns;
  x3 <= "11100100", "11111111" after 300 ns;
END test;
  
  





