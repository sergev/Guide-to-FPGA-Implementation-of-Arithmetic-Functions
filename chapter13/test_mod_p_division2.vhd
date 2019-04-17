
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY test_mod_p_division2 IS END test_mod_p_division2;

ARCHITECTURE test OF test_mod_p_division2 IS
  COMPONENT mod_p_division2 IS
    GENERIC(k: NATURAL; p: STD_LOGIC_VECTOR);
  PORT (
      x, y: IN STD_LOGIC_VECTOR(k-1 DOWNTO 0);
      clk, reset, start: IN STD_LOGIC;
      z: OUT STD_LOGIC_VECTOR(k-1 DOWNTO 0);
      done: OUT STD_LOGIC 
      );
  END COMPONENT;
  SIGNAL x, y, z: STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL clk: STD_LOGIC := '0';
  SIGNAL reset, start, done: STD_LOGIC;
BEGIN
  dut: mod_p_division2 GENERIC MAP(k => 8, p => x"ef")
  PORT MAP(x => x, y => y, z=> z, clk => clk, reset => reset, start => start, done => done);
  clk <= NOT(clk) AFTER 50 NS;
  reset <= '0';
  start <= '0', '1' AFTER 200 NS, '0' AFTER 300 NS, '1' AFTER 3000 NS, '0' AFTER 3100 NS, '1' AFTER 6000 NS;
  x <= x"04", x"c7" AFTER 3000 NS, x"ee" AFTER 6000 NS;
  y <= x"d9", x"ee" AFTER 3000 NS, x"80" AFTER 6000 NS;
END test;
  
  