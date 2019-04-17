----------------------------------------------------------------------------
-- mod_m_AS.vhd
--
-- section 13.1.1 mod m adder-subtractor
--
-- z = (x + y) mod m if operation = 0
-- z = (x - y) mod m if operation = 1
--
----------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.all;
ENTITY mod_m_AS IS
  GENERIC(k: NATURAL:=8; m: STD_LOGIC_VECTOR:=x"EF");
PORT (
  x, y: IN STD_LOGIC_VECTOR(k-1 DOWNTO 0);
  operation: STD_LOGIC;
  z: OUT STD_LOGIC_VECTOR(k-1 DOWNTO 0)
);
END mod_m_AS;

ARCHITECTURE circuit OF mod_m_AS IS
  SIGNAL s1, s2: STD_LOGIC_VECTOR(k DOWNTO 0);
  SIGNAL c: STD_LOGIC;
BEGIN
  WITH operation SELECT s1 <= ('0'&x) + y WHEN '0', ('0'&x) - y WHEN OTHERS;
  WITH operation SELECT s2 <= s1 + m WHEN '1', s1 - m WHEN OTHERS;  
  c <= (NOT(operation) AND s2(k)) OR (operation AND NOT(s1(k)));
  WITH c SELECT z <= s1(k-1 DOWNTO 0) WHEN '1', s2(k-1 DOWNTO 0) WHEN OTHERS; 
END circuit;
