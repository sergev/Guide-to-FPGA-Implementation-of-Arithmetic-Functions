----------------------------------------------------------------------------
-- test_restoringDS_ST.vhd
--
-- Simple test bench for restoringDS.
--
----------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY test_restoringDS IS
END test_restoringDS;

ARCHITECTURE test OF test_restoringDS IS
  COMPONENT restoringDS IS
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
  dut: restoringDS GENERIC MAP(n => 8, p => 10)
    PORT MAP(x => x, y => y, clk => clk, reset => reset, start => start, done => done, quotient => quotient, remainder => remainder);
END test;