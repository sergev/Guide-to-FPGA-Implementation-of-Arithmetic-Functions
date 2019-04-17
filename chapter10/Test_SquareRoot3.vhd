----------------------------------------------------------------------------
-- test_SquareRoot3.vhd
--
-- section 10.3 Square Rooters. Non-Restoring Algorithm (10.3.2)
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

ENTITY test_SquareRoot3 IS 
END test_SquareRoot3;

ARCHITECTURE test OF test_SquareRoot3 IS
   CONSTANT n: NATURAL:= 8;
   CONSTANT NUM_SIM: NATURAL := 1000;

   COMPONENT SquareRoot3 IS
     GENERIC(n: NATURAL);
   PORT(
     x: IN STD_LOGIC_VECTOR(2*n-1 DOWNTO 0);
     clk, reset, start:IN STD_LOGIC;
     root: OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0);
     remainder: OUT STD_LOGIC_VECTOR(n DOWNTO 0);
     done: OUT STD_LOGIC
   );
   END COMPONENT;

   SIGNAL x, xx_l, xx_h: STD_LOGIC_VECTOR(2*n-1 DOWNTO 0);
   SIGNAL root: STD_LOGIC_VECTOR(n-1 DOWNTO 0);
   SIGNAL remainder: STD_LOGIC_VECTOR(n DOWNTO 0);
   SIGNAL clk, reset, start, done: STD_LOGIC;

   SIGNAL end_sim : boolean := false;
   CONSTANT OFFSET : time := 10 ns;
   CONSTANT PERIOD : time := 50 ns; 
  
BEGIN

   dut: SquareRoot3 GENERIC MAP(n => n)
   PORT MAP(x => x, clk => clk, reset => reset, start=> start,
            root => root, remainder => remainder, done => done);
           
   xx_l <= root*root;
   xx_h <= (root+1)*(root+1)-1;

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
      VARIABLE int_x, int_root : NATURAL;
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
      ASSERT ( x <= xx_h and x >= xx_l ) REPORT "error in square root: " & integer'image(int_x) & " /= " & integer'image(int_root) & " ^2 " 
      SEVERITY ERROR;
   END LOOP;
   REPORT "simulation OK";
   end_sim <= true;
   WAIT;
   END PROCESS;

END test;