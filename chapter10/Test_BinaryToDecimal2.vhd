----------------------------------------------------------------------------
-- test_BinaryToDecimal2.vhd
--
-- section 10.1 Binary to radix-B conversion. Binary to decimal.
--
-- Simple Test bench for sequential Binary to radix-B conversion
--
----------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.all;
ENTITY test_BinaryToDecimal2 IS 
END test_BinaryToDecimal2;

ARCHITECTURE test OF test_BinaryToDecimal2 IS
  COMPONENT BinaryToDecimal2 IS
    GENERIC(n, m, logn: NATURAL);
  PORT(
    x: IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
    clk, reset, start: IN STD_LOGIC;
    y: OUT STD_LOGIC_VECTOR(4*m-1 DOWNTO 0);
    done:OUT STD_LOGIC
  );
  END COMPONENT;
  SIGNAL x: STD_LOGIC_VECTOR(15 DOWNTO 0);
  SIGNAL clk: STD_LOGIC := '0';
  SIGNAL reset, start, done: STD_LOGIC;
  SIGNAL y: STD_LOGIC_VECTOR(19 DOWNTO 0);
BEGIN
  dut: BinaryToDecimal2 
       GENERIC MAP(n => 16, m => 5, logn => 4)
       PORT MAP(x => x, clk => clk, reset => reset, start => start, y => y, done => done);
  
  clk <= NOT(clk) AFTER 50 NS;

  PROCESS
    VARIABLE i, y4, y3, y2, y1, y0: NATURAL;
  BEGIN
    reset <= '1';
    start <= '0';
    WAIT FOR 100 NS;
    reset <= '0';
    FOR i IN 0 TO 2**16-1 LOOP
      x <= CONV_STD_LOGIC_VECTOR(i, 16);
      WAIT FOR 100 NS;
      start <= '1';
      WAIT FOR 100 NS;
      start <= '0';
      WAIT UNTIL done = '1';
      WAIT FOR 100 NS;
            
      y4 := CONV_INTEGER(y(19 DOWNTO 16));
      y3 := CONV_INTEGER(y(15 DOWNTO 12));
      y2 := CONV_INTEGER(y(11 DOWNTO 8));
      y1 := CONV_INTEGER(y(7 DOWNTO 4));
      y0 := CONV_INTEGER(y(3 DOWNTO 0));
      ASSERT y4*10000 + y3*1000 +y2*100 +y1*10 +y0 = i
      REPORT "uncorrect conversion"
      SEVERITY ERROR;    
    END LOOP;
    ASSERT false REPORT "No errors in simultion" SEVERITY FAILURE;
  END PROCESS;    

END test;
  