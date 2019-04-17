----------------------------------------------------------------------------
-- test_restoring.vhd
--
-- section 3.2
--
-- Simple test bench for Self Timed scalar product in GF(2**m)
--
----------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY test_restoring IS
END test_restoring;

ARCHITECTURE test OF test_restoring IS
  COMPONENT restoring IS
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
  dut: restoring GENERIC MAP(n => 8, p => 10)
    PORT MAP(x => x, y => y, clk => clk, reset => reset, start => start, done => done, quotient => quotient, remainder => remainder);
 
END test;