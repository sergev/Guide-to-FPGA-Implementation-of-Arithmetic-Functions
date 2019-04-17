----------------------------------------------------------------------------
-- test_mod_f_division2.vhd
--
-- section 13.4 mod f diviver
--
-- Simple test bench for polynomial division
--
----------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE work.binary_algorithm_polynomials_parameters.ALL;
ENTITY test_mod_f_division2 IS END test_mod_f_division2;

ARCHITECTURE test OF test_mod_f_division2 IS
  COMPONENT mod_f_division2 IS
  PORT (
    g, h: IN STD_LOGIC_VECTOR(m-1 DOWNTO 0);
    clk, reset, start: IN STD_LOGIC;
    z: OUT STD_LOGIC_VECTOR(m-1 DOWNTO 0);
    done: OUT STD_LOGIC 
    );
  END COMPONENT;
  SIGNAL g, h, z: STD_LOGIC_VECTOR(m-1 DOWNTO 0);
  SIGNAL clk: STD_LOGIC := '0';
  SIGNAL reset, start, done: STD_LOGIC;
BEGIN
  dut: mod_f_division2
  PORT MAP(g => g, h => h, z => z, clk => clk, reset => reset, start => start, done => done);
  clk <= NOT(clk) AFTER 50 NS;
  reset <= '1', '0' AFTER 100 NS;
  start <= '0', '1' AFTER 200 NS, '0' AFTER 300 NS, '1' AFTER 2000 NS;
  g <= "01001000", "10010001" AFTER 1900 NS;
  h <= "01001110", "11010001" AFTER 1900 NS;
END test;