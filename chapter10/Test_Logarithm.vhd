----------------------------------------------------------------------------
-- test_Logarithm.vhd
--
-- section 10.4 Logarithm
--
-- Test bench for sequential logarithm
-- Generates NUM_SIM Random cases
--
----------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.MATH_REAL.ALL; -- for UNIFORM, TRUNC

ENTITY test_Logarithm IS 
END test_Logarithm;

ARCHITECTURE test OF test_Logarithm IS
   CONSTANT n: NATURAL:= 8;
   CONSTANT p: NATURAL:= 12;
   CONSTANT NUM_SIM: NATURAL := 1000;
   CONSTANT max_error: REAL:= 0.005;

   COMPONENT Logarithm IS
     GENERIC(n, p: NATURAL);
   PORT(
     x: IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
     clk, reset, start:IN STD_LOGIC;
     log: OUT STD_LOGIC_VECTOR(p-1 DOWNTO 0);
     done: OUT STD_LOGIC
   );
   END COMPONENT;

   SIGNAL x: STD_LOGIC_VECTOR(n-1 DOWNTO 0);
   SIGNAL log: STD_LOGIC_VECTOR(p-1 DOWNTO 0);
   SIGNAL clk, reset, start, done: STD_LOGIC;

   SIGNAL end_sim : boolean := false;
   CONSTANT OFFSET : time := 10 ns;
   CONSTANT PERIOD : time := 50 ns; 
  
BEGIN

   dut: Logarithm GENERIC MAP(n => n, p => p)
   PORT MAP(x => x, clk => clk, reset => reset, start=> start,
            log => log, done => done);
           
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
      VARIABLE rand, real_x, real_log, real_exp, dif: REAL;
      VARIABLE int_x, int_log : NATURAL;
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
      int_log := CONV_INTEGER(log);
      real_x := 1.0 + REAL(int_x) / REAL(2**n);
      real_log := REAL(int_log) / REAL(2**p);
      real_exp := 2**real_log;
      dif := real_x - real_exp;
      ASSERT ( dif < max_error ) REPORT "error in logarithm: x:" & integer'image(int_x) & "  y: " & integer'image(int_log) 
      SEVERITY ERROR;
      ASSERT ( dif < max_error ) REPORT "error in logarithm: log_2(" & REAL'image(real_x) & ") /= " & REAL'image(real_log) 
                       & " 2^log = " & REAL'image(real_exp) & " dif = " & REAL'image(dif) 
      SEVERITY ERROR;
   END LOOP;
   REPORT "simulation OK";
   end_sim <= true;
   WAIT;
   END PROCESS;

END test;