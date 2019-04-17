----------------------------------------------------------------------------
-- test_unrolled_divider.vhd
--
-- Simple test bench for unrolled divider
--
----------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY test_unrolled_divider IS
END test_unrolled_divider;

ARCHITECTURE test OF test_unrolled_divider IS
  COMPONENT unrolled_divider IS
    GENERIC(n, p: NATURAL);
  PORT(
    x, y: IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
    clk, reset, start:IN STD_LOGIC;
    quotient: OUT STD_LOGIC_VECTOR(1 TO p);
    remainder: OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0);
    done: OUT STD_LOGIC
  );
  END COMPONENT;
  SIGNAL x, y, remainder: STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL clk, reset, start, done: STD_LOGIC;
  SIGNAL quotient: STD_LOGIC_VECTOR(1 TO 10);
  
BEGIN
  dut: unrolled_divider GENERIC MAP(n => 8, p => 10)
    PORT MAP(x => x, y => y, clk => clk, reset => reset, start => start, done => done, quotient => quotient, remainder => remainder);
END test;