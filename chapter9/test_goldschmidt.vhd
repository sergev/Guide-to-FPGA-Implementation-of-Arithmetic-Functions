----------------------------------------------------------------------------
-- test_goldschmidt.vhd
--
-- section 9.4 convergence algorithm
--
-- Test bench for sequential division
-- Generates NUM_SIM Random cases
--
----------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL; --for unsigned operands
use IEEE.MATH_REAL.ALL; -- for UNIFORM, TRUNC

ENTITY test_goldschmidt IS 
END test_goldschmidt;

ARCHITECTURE test OF test_goldschmidt IS
   CONSTANT n: NATURAL:= 8;
   CONSTANT p: NATURAL:= 10;
   CONSTANT m: NATURAL:= 4;
   CONSTANT NUM_SIM: NATURAL := 10000;

   COMPONENT goldschmidt IS
     GENERIC(n: NATURAL:= n; p: NATURAL:= p; m: NATURAL:= m);
   PORT(
     x: IN STD_LOGIC_VECTOR(n DOWNTO 0);
     y: IN STD_LOGIC_VECTOR(n DOWNTO 0);
     clk, reset, start:IN STD_LOGIC;
     quotient: OUT STD_LOGIC_VECTOR(0 TO p);
     done: OUT STD_LOGIC
   );
   END COMPONENT;
   
   SIGNAL x: STD_LOGIC_VECTOR(n DOWNTO 0);
   SIGNAL y: STD_LOGIC_VECTOR(n DOWNTO 0);
   SIGNAL q: STD_LOGIC_VECTOR(0 to p);
   SIGNAL clk, reset, start, done: STD_LOGIC;

   SIGNAL end_sim : boolean := false;
   CONSTANT OFFSET : time := 10 ns;
   CONSTANT PERIOD : time := 50 ns; 
  
BEGIN

   dut: goldschmidt GENERIC MAP(n => n, p => p, m => m)
   PORT MAP(x => x, y => y,  
            clk => clk, reset => reset, start=> start,
            quotient => q, done => done);
                     
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
      VARIABLE int_x,int_y, int_q, mult, dif: NATURAL;
   BEGIN
   end_sim <= false;
   reset <= '1';
   start <= '0';
   WAIT FOR PERIOD;
   reset <= '0';
   WAIT FOR PERIOD;
   FOR i IN 0 TO NUM_SIM LOOP
      UNIFORM(seed1, seed2, rand);
      int_x := INTEGER(TRUNC((rand)*real(2**n)));
      x <= '1' & CONV_STD_LOGIC_VECTOR(int_x,n); --1 <= x < 2
      int_x := int_x + 2**n;
      UNIFORM(seed1, seed2, rand);
      int_y := INTEGER(TRUNC((1.0+rand)*real(2**n))); --1 <= y < 2
      y <= CONV_STD_LOGIC_VECTOR(int_y,n+1);
      start <= '1';
      WAIT FOR PERIOD;
      start <= '0';
      WAIT UNTIL done = '1';
      WAIT FOR 2*PERIOD;
      int_q := CONV_INTEGER(q);
      mult := (int_y*int_q)/2**(p);
      dif := int_x - mult;
      ASSERT ( abs(dif) <= 2 ) REPORT "error in division: " & integer'image(int_x) & " /= (" & integer'image(int_y) &
                                 " * " & integer'image(int_q) & " )/ 2^" & integer'image(p) & " = " & integer'image(mult) & " dif: " & integer'image(dif)
      SEVERITY ERROR;
   END LOOP;
   REPORT "simulation OK";
   end_sim <= true;
   WAIT;
   END PROCESS;

END test;