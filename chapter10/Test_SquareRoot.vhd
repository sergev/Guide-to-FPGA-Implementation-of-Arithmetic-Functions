----------------------------------------------------------------------------
-- test_SquareRoot.vhd
--
-- section 10.3 Square Rooters. Restoring Algorithm (10.3.1)
--
-- Test bench for sequential Square Rooters
-- Generates NUM_SIM Random cases
--
----------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.MATH_REAL.ALL; -- for UNIFORM, TRUNC

ENTITY test_SquareRoot IS 
END test_SquareRoot;

ARCHITECTURE test OF test_SquareRoot IS
   CONSTANT n: NATURAL:= 8;
   CONSTANT NUM_SIM: NATURAL := 1000;

   COMPONENT SquareRoot IS
     GENERIC(n: NATURAL);
   PORT(
     x: IN STD_LOGIC_VECTOR(2*n-1 DOWNTO 0);
     clk, reset, start:IN STD_LOGIC;
     root: OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0);
     remainder: OUT STD_LOGIC_VECTOR(n DOWNTO 0);
     done: OUT STD_LOGIC
   );
   END COMPONENT;

   SIGNAL x, xx: STD_LOGIC_VECTOR(2*n-1 DOWNTO 0);
   SIGNAL root: STD_LOGIC_VECTOR(n-1 DOWNTO 0);
   SIGNAL remainder: STD_LOGIC_VECTOR(n DOWNTO 0);
   SIGNAL clk, reset, start, done: STD_LOGIC;

   SIGNAL end_sim : boolean := false;
   CONSTANT OFFSET : time := 10 ns;
   CONSTANT PERIOD : time := 50 ns; 
  
BEGIN

   dut: SquareRoot GENERIC MAP(n => n)
   PORT MAP(x => x, clk => clk, reset => reset, start=> start,
            root => root, remainder => remainder, done => done);
           
   xx <= root*root + remainder;

   clk_generation: process
   begin
   wait for OFFSET;
   while not end_sim loop
      clk <= '0';
      wait for PERIOD/2;
      clk <= '1';
      wait for PERIOD/2;
   end loop;
   wait;
   end process;   

   stimuli: PROCESS
      VARIABLE seed1: NATURAL := 844396720;
      VARIABLE seed2: NATURAL := 821616997;  
      VARIABLE rand: REAL;
      VARIABLE int_x, int_root, int_rem : NATURAL;
   BEGIN
   end_sim <= false;
   reset <= '1';
   start <= '0';
   WAIT FOR PERIOD;
   reset <= '0';
   WAIT FOR PERIOD;
   FOR i IN 0 TO NUM_SIM LOOP
      UNIFORM(seed1, seed2, rand);
      int_x := INTEGER(TRUNC(rand*real(2**(2*n))));
      x <= CONV_STD_LOGIC_VECTOR(int_x,2*n);
      start <= '1';
      WAIT FOR PERIOD;
      start <= '0';
      WAIT UNTIL done = '1';
      WAIT FOR 2*PERIOD;
      int_root := CONV_INTEGER(root);      
      int_rem := CONV_INTEGER(remainder);      
      ASSERT ( x = xx ) REPORT "error in square root: " & integer'image(int_x) & " /= " & integer'image(int_root) &
                                 " ^2 +  " & integer'image(int_rem) 
      SEVERITY ERROR;
      ASSERT ( 2*int_root >= int_rem) REPORT "error in remainder of square root. X= " & integer'image(int_x) & "  rem: " & 
                                      integer'image(int_rem) & " > 2*root (2*" & integer'image(int_root) & ")"
      SEVERITY ERROR;
   END LOOP;
   REPORT "simulation OK";
   end_sim <= true;
   WAIT;
   END PROCESS;

END test;