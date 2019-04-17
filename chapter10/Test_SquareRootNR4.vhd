----------------------------------------------------------------------------
-- test_SquareRootNR4.vhd
--
-- section 10.3 Square Rooters. Newton-Raphson Algorithm (10.3.4)
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

ENTITY test_SquareRootNR4 IS 
END test_SquareRootNR4;

ARCHITECTURE test OF test_SquareRootNR4 IS
   CONSTANT n: NATURAL:= 8;
   CONSTANT p: NATURAL:= 4;
   CONSTANT NUM_SIM: NATURAL := 1000;

   COMPONENT SquareRootNR4 IS
     GENERIC(n: NATURAL:= n; p: NATURAL:= p);
   PORT(
     x: IN STD_LOGIC_VECTOR(2*n-1 DOWNTO 0);
     clk, reset, start:IN STD_LOGIC;
     root: OUT STD_LOGIC_VECTOR(n+p-1 DOWNTO 0);
     done: OUT STD_LOGIC
   );
   END COMPONENT;

   SIGNAL x: STD_LOGIC_VECTOR(2*n-1 DOWNTO 0);
   SIGNAL x_long_l, x_long_h: STD_LOGIC_VECTOR(2*(n+p)-1 DOWNTO 0);
   SIGNAL xx_l, xx_h: STD_LOGIC_VECTOR(2*n-1 DOWNTO 0);
   SIGNAL root: STD_LOGIC_VECTOR(n+p-1 DOWNTO 0);
   SIGNAL clk, reset, start, done: STD_LOGIC;

   SIGNAL end_sim : boolean := false;
   CONSTANT OFFSET : time := 10 ns;
   CONSTANT PERIOD : time := 50 ns; 
  
BEGIN

   dut: SquareRootNR4 GENERIC MAP(n => n)
   PORT MAP(x => x, clk => clk, reset => reset, start=> start,
            root => root, done => done);
           
   x_long_l <= root*root;
   x_long_h <= (root+1)*(root+1)-1;
   xx_l <= x_long_l(2*(n+p)-1 DOWNTO 2*p);
   xx_h <= x_long_h(2*(n+p)-1 DOWNTO 2*p);
   
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
      VARIABLE rand, real_root, real_sqrt: REAL;
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
      real_root := real(CONV_INTEGER(root)) / real(2**p); 
      real_sqrt := sqrt(real(int_x));
      ASSERT ( x <= xx_h and x >= xx_l ) 
      REPORT "error in square root: " & integer'image(int_x) & " /= (" & integer'image(int_root) & "/2^" & integer'image(p) &") ^2 " &
             "    root=" & real'image(real_root) & " true sqrt= " & real'image(real_sqrt) & "  " 
      SEVERITY ERROR;
   END LOOP;
   REPORT "simulation OK";
   end_sim <= true;
   WAIT;
   END PROCESS;

END test;