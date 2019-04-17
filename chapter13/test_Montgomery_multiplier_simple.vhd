----------------------------------------------------------------------------
-- test_Montgomery_multiplier_simple.vhd
--
-- section 13.1.2.3 mod m Montgomery multiplier
--
-- Simple test bench for modular multiplication
--
----------------------------------------------------------------------------
LIBRARY IEEE; USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE work.mod_m.ALL;
ENTITY test_Montgomery_multiplier IS END test_Montgomery_multiplier;

ARCHITECTURE test OF test_Montgomery_multiplier IS
  COMPONENT Montgomery_multiplier IS
  PORT(
    x, y: IN STD_LOGIC_VECTOR(k-1 DOWNTO 0);
    clk, reset, start: STD_LOGIC;
    z: OUT STD_LOGIC_VECTOR(k-1 DOWNTO 0);
    done: OUT STD_LOGIC
  );
  END COMPONENT;
  SIGNAL x, y, z: STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL clk: STD_LOGIC := '0';
  SIGNAL reset, start, done: STD_LOGIC;
  
BEGIN
  dut: Montgomery_multiplier
  PORT MAP(x => x, y => y, z => z, clk => clk, start => start, reset => reset, done => done);
  
  clk <= NOT(clk) AFTER 50 NS;
  start <= '1', '0' AFTER 200 NS, '1' AFTER 300 NS, '0' AFTER 400 NS, '1' AFTER 1500 NS, '0' AFTER 1600 NS, '1' AFTER 3000 NS;
  reset <= '1', '0'AFTER 100 NS;
  x <= "11001010", "11101110" AFTER 1400 NS, "00000000" AFTER 2900 NS;
  y <= "11101100", "11101110" AFTER 1400 NS, "01111111" AFTER 2900 NS;
END test;