LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.all;
ENTITY test_six_to_three_counter IS
END test_six_to_three_counter;

ARCHITECTURE test OF test_six_to_three_counter IS
  COMPONENT six_to_three_counter IS
    GENERIC(n: NATURAL);
  PORT(
    x0, x1, x2, x3, x4, x5: IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
    u, v, w: OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0)
  );
  END COMPONENT;
  SIGNAL x0, x1, x2, x3, x4, x5, u, v, w: STD_LOGIC_VECTOR(7 DOWNTO 0);
BEGIN
  dut: six_to_three_counter GENERIC MAP(n => 8)
  PORT MAP(x0 => x0, x1 => x1, x2 => x2, x3 => x3, x4 => x4, x5 => x5, u => u, v => v, w => w);
  x0 <= "00000010", "00000011" AFTER 100 NS;
  x1 <= "00000011";
  x2 <= "00000001";
  x3 <= "00000110";
  x4 <= "00000111";
  x5 <= "00000001";
END test;