----------------------------------------------------------------------------
-- test_Exponential.vhd
--
-- section 10.5 Exponential
--
-- Test bench for sequential Exponential
-- Generates NUM_SIM Random cases
--
----------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.MATH_REAL.ALL; -- for UNIFORM, TRUNC

ENTITY test_Exponential IS 
END test_Exponential;

ARCHITECTURE test OF test_Exponential IS
   CONSTANT n: NATURAL:= 8;
   CONSTANT p: NATURAL:= 12;
   CONSTANT m: NATURAL:= 17;
   CONSTANT NUM_SIM: NATURAL := 1000;
   CONSTANT max_error: REAL:= 0.0005;

   COMPONENT Exponential IS
     GENERIC(n, p, m: NATURAL);
   PORT(
     x: IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
     clk, reset, start:IN STD_LOGIC;
     y: OUT STD_LOGIC_VECTOR(p DOWNTO 0);
     done: OUT STD_LOGIC
   );
   END COMPONENT;

   SIGNAL x: STD_LOGIC_VECTOR(n-1 DOWNTO 0);
   SIGNAL y: STD_LOGIC_VECTOR(p DOWNTO 0);
   SIGNAL clk, reset, start, done: STD_LOGIC;

   SIGNAL end_sim : boolean := false;
   CONSTANT OFFSET : time := 10 ns;
   CONSTANT PERIOD : time := 50 ns; 
  
BEGIN

   dut: Exponential GENERIC MAP(n => n, p => p, m => m)
   PORT MAP(x => x, clk => clk, reset => reset, start=> start,
            y => y, done => done);
           
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
      VARIABLE rand, real_x, real_y, real_exp, dif: REAL;
      VARIABLE int_x, int_y : NATURAL;
   BEGIN
   end_sim <= false;
   reset <= '1';
   start <= '0';
   WAIT FOR PERIOD;
   reset <= '0';
   WAIT FOR PERIOD;
   FOR i IN 0 TO NUM_SIM LOOP
      UNIFORM(seed1, seed2, rand);
      int_x := INTEGER(TRUNC(rand*real(2**(n))));
      x <= CONV_STD_LOGIC_VECTOR(int_x,n);
      start <= '1';
      WAIT FOR PERIOD;
      start <= '0';
      WAIT UNTIL done = '1';
      WAIT FOR 2*PERIOD;
      int_y := CONV_INTEGER(y);
      real_x := REAL(int_x) / REAL(2**n);
      real_y := REAL(int_y) / REAL(2**p);
      real_exp := 2**real_x;
      dif := real_exp - real_y ; 
      ASSERT ( dif < max_error ) REPORT "error in logarithm: x: " & integer'image(int_x) & "  y: " & integer'image(int_y) 
      SEVERITY ERROR;
      ASSERT ( dif < max_error ) REPORT "error in logarithm: 2^" & REAL'image(real_x) & " /= " & REAL'image(real_y) 
                       & "  2^x = " & REAL'image(real_exp) & " dif = " & REAL'image(dif) 
      SEVERITY ERROR;
   END LOOP;
   REPORT "simulation OK";
   end_sim <= true;
   WAIT;
   END PROCESS;

END test;