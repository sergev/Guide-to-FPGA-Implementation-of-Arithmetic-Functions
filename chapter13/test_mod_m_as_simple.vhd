----------------------------------------------------------------------------
-- test_mod_m_AS.vhd
--
-- section 13.1.1 mod m adder subtractor
--
-- Simple test bench for modular addition subtraction
--
----------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.all;
ENTITY test_mod_m_AS IS END test_mod_m_AS;

ARCHITECTURE test OF test_mod_m_AS IS
  COMPONENT mod_m_AS IS
    GENERIC(k: NATURAL; m: STD_LOGIC_VECTOR);
  PORT (
    x, y: IN STD_LOGIC_VECTOR(k-1 DOWNTO 0);
    operation: STD_LOGIC;
    z: OUT STD_LOGIC_VECTOR(k-1 DOWNTO 0)
  );
  END COMPONENT;
  SIGNAL x, y, z: STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL operation: STD_LOGIC;
BEGIN
  dut: mod_m_AS GENERIC MAP(k => 8, m => x"EF")
  PORT MAP(x => x, y => y, operation => operation, z => z);
  x <= "01101111", "11010111" AFTER 200 NS, "11101110" AFTER 400 NS, "00000000" AFTER 600 NS;
  y <= "10010110", "11100011" AFTER 200 NS, "11101110" AFTER 400 NS, "00000000" AFTER 600 NS;
  operation <= '0', '1' AFTER 10 NS, '0' AFTER 300 NS, '1' AFTER 500 NS, '0' AFTER 700 NS;
END test;