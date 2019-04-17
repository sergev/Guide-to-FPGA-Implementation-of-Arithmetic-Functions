----------------------------------------------------------------------------
-- test_pipeline_ST.vhd
--
-- section 3.1.4
--
-- Simple test bench for Self Timed adder
--
----------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY test_adder_ST2 IS END test_adder_ST2;

ARCHITECTURE test OF test_adder_ST2 IS
  COMPONENT adder_ST2 IS
    GENERIC(n: NATURAL);
  PORT (
    x, y: IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
    c_in, reset: IN STD_LOGIC;
    z: OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0);
    c_out, done: OUT STD_LOGIC
  );
  END COMPONENT;
  SIGNAL x, y, z: STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL c_in, reset, done, c_out: STD_LOGIC;

BEGIN
  dut: adder_ST2 GENERIC MAP(n => 32)
  PORT MAP(x => x, y => y, c_in => c_in, reset => reset, z => z, c_out => c_out, done => done);

  x <= x"a79c8de9", x"abcd010f" AFTER 100 NS, x"ffffffff" AFTER 200 NS;
  y <= x"07b9c1e6", x"38cd0123" AFTER 100 NS, x"00000000" AFTER 200 NS;
  c_in <= '0', '1' AFTER 100 NS;
  reset <= '0', '1' AFTER 10 NS, '0' AFTER 20 NS, '1' AFTER 110 NS, '0' AFTER 120 NS, '1' AFTER 210 NS, '0' AFTER 220 NS;

END test;
    