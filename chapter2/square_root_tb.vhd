------------------------------------------------------------------
-- square_root_tb.vhd
-- Simple Testbench for Introductoy example 2.1, Square root
-- 
-------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.all;
ENTITY test_square_root IS END test_square_root;

ARCHITECTURE test OF test_square_root IS
  COMPONENT square_root IS
    GENERIC(n: NATURAL);
  PORT (
    x: IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
    clk, reset, start: IN STD_LOGIC;
    r: INOUT STD_LOGIC_VECTOR(n-1 DOWNTO 0);
    done: OUT STD_LOGIC
  );
  END COMPONENT;
  SIGNAL clk: STD_LOGIC := '0';
  SIGNAL reset, start, done: STD_LOGIC;
  SIGNAL r, x: STD_LOGIC_VECTOR(7 DOWNTO 0);
BEGIN
  DUT: square_root
  GENERIC MAP(n => 8)
  PORT MAP(x => x, clk => clk, reset => reset, start => start, r => r, done => done);
  clk <= not(clk) after 50 ns;
  reset <= '1', '0' after 100 ns;
  x <= "10010000", 
       "10001111" after 2000 ns, 
       "01000000" after 4000 ns, 
       "00111111" after 6000 ns;
  start <= '0', 
  '1' after 200 ns, '0' after 300 ns,
  '1' after 2100 ns, '0' after 2200 ns,
  '1' after 4100 ns, '0' after 4200 ns,
  '1' after 6100 ns, '0' after 6200 ns;
END test;

