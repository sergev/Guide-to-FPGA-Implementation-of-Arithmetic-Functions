----------------------------------------------------------------------------
-- test_shift_and_add_multiplier2.vhd
--
-- section 8.3 sequential multipiers.
--
-- Test bench for sequential multiplication
-- Generates NUM_SIM Random cases
--
----------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.MATH_REAL.ALL; -- for UNIFORM, TRUNC

ENTITY test_shift_and_add_multiplier2 IS 
END test_shift_and_add_multiplier2;

ARCHITECTURE test OF test_shift_and_add_multiplier2 IS
   CONSTANT n: NATURAL:= 8;
   CONSTANT m: NATURAL:= 6;
   CONSTANT NUM_SIM: NATURAL := 100;

   COMPONENT shift_and_add_multiplier2 IS
     GENERIC(n, m: NATURAL);
   PORT(
     x, u: IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
     y: IN STD_LOGIC_VECTOR(m-1 DOWNTO 0);
     clk, reset, start: IN STD_LOGIC;
     z: OUT STD_LOGIC_VECTOR(n+m-1 DOWNTO 0);
     done: OUT STD_LOGIC
   );
   END COMPONENT;

   SIGNAL x, u: STD_LOGIC_VECTOR(n-1 DOWNTO 0);
   SIGNAL y: STD_LOGIC_VECTOR(m-1 DOWNTO 0);
   SIGNAL z, zz: STD_LOGIC_VECTOR(n+m-1 DOWNTO 0);
   SIGNAL clk, reset, start, done: STD_LOGIC;

   SIGNAL end_sim : boolean := false;
   CONSTANT OFFSET : time := 10 ns;
   CONSTANT PERIOD : time := 50 ns; 
  
BEGIN

   dut: shift_and_add_multiplier2 GENERIC MAP(n => n, m => m)
   PORT MAP(x => x, y => y, u => u, 
            clk => clk, reset => reset, start=> start,
            z => z, done => done);
           
   zz <= x*y + u;

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
      VARIABLE int_rand1,int_rand2,int_rand3 : NATURAL;
   BEGIN
   end_sim <= false;
   reset <= '1';
   start <= '0';
   WAIT FOR PERIOD;
   reset <= '0';
   WAIT FOR PERIOD;
   FOR i IN 0 TO NUM_SIM LOOP
      UNIFORM(seed1, seed2, rand);
      int_rand1 := INTEGER(TRUNC(rand*real(2**n)));
      x <= CONV_STD_LOGIC_VECTOR(int_rand1,n);
      UNIFORM(seed1, seed2, rand);
      int_rand2 := INTEGER(TRUNC(rand*real(2**m)));
      y <= CONV_STD_LOGIC_VECTOR(int_rand2,m);
      UNIFORM(seed1, seed2, rand);
      int_rand3 := INTEGER(TRUNC(rand*real(2**n)));
      u <= CONV_STD_LOGIC_VECTOR(int_rand3,n);
      start <= '1';
      WAIT FOR PERIOD;
      start <= '0';
      WAIT UNTIL done = '1';
      WAIT FOR 2*PERIOD;     

      ASSERT ( z = zz ) REPORT "error in multiplication: " & integer'image(int_rand1) & " * " & integer'image(int_rand2) &
                                 " + " & integer'image(int_rand3)
      SEVERITY ERROR;
   END LOOP;
   REPORT "simulation OK";
   end_sim <= true;
   WAIT;
   END PROCESS;

END test;