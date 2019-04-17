----------------------------------------------------------------------------
-- test_srt_csa_divider.vhd
--
-- section 9.2.4 SRT CSA divider
--
-- Test bench for sequential division
-- Generates NUM_SIM Random cases
--
----------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL; --for signed operands
use IEEE.MATH_REAL.ALL; -- for UNIFORM, TRUNC

ENTITY test_srt_csa_divider IS 
END test_srt_csa_divider;

ARCHITECTURE test OF test_srt_csa_divider IS
   CONSTANT n: NATURAL:= 8;
   CONSTANT p: NATURAL:= 6;
   CONSTANT NUM_SIM: NATURAL := 100;

   COMPONENT srt_csa_divider IS
     GENERIC(n: NATURAL:= 8; p: NATURAL:= 8);
   PORT(
     x: IN STD_LOGIC_VECTOR(n DOWNTO 0);
     y: IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
     clk, reset, start:IN STD_LOGIC;
     quotient: OUT STD_LOGIC_VECTOR(0 TO p);
     remainder: OUT STD_LOGIC_VECTOR(n DOWNTO 0);
     done: OUT STD_LOGIC
   );
   END COMPONENT;
   
   SIGNAL x, r: STD_LOGIC_VECTOR(n DOWNTO 0);
   SIGNAL y: STD_LOGIC_VECTOR(n-1 DOWNTO 0);
   SIGNAL q: STD_LOGIC_VECTOR(0 to p);
   SIGNAL clk, reset, start, done: STD_LOGIC;

   SIGNAL end_sim : boolean := false;
   CONSTANT OFFSET : time := 10 ns;
   CONSTANT PERIOD : time := 50 ns; 
  
BEGIN

   dut: srt_csa_divider GENERIC MAP(n => n, p => p)
   PORT MAP(x => x, y => y,  
            clk => clk, reset => reset, start=> start,
            quotient => q, remainder => r, done => done);
                     
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
      VARIABLE int_x,int_y, int_q, int_r: NATURAL;
   BEGIN
   end_sim <= false;
   reset <= '1';
   start <= '0';
   WAIT FOR PERIOD;
   reset <= '0';
   WAIT FOR PERIOD;
   FOR i IN 0 TO NUM_SIM LOOP
      UNIFORM(seed1, seed2, rand);
      int_x := INTEGER(TRUNC((rand-0.5)*real(2**(n+1))));
      x <= CONV_STD_LOGIC_VECTOR(int_x,n+1);
      int_y := 0;
      while ((int_y = 0) or (int_y < abs(int_x))) loop --avoid div by 0 and y >= |x|
         UNIFORM(seed1, seed2, rand);
         int_y := INTEGER(TRUNC((1.0+rand)*real(2**(n-1)))); -- gen a normalized number 1xx...xx
      end loop;
      y <= CONV_STD_LOGIC_VECTOR(int_y,n);
      start <= '1';
      WAIT FOR PERIOD;
      start <= '0';
      WAIT UNTIL done = '1';
      WAIT FOR 2*PERIOD;
      int_q := CONV_INTEGER(q);
      int_r := CONV_INTEGER(r);
      ASSERT ( int_x = (int_y*int_q + int_r)/2**(p) ) REPORT "error in division: " & integer'image(int_x) & " /= (" & integer'image(int_y) &
                                 " * " & integer'image(int_q) & " + " & integer'image(int_r) & " ) 2^" & integer'image(p)
      SEVERITY ERROR;
      ASSERT ( int_y >= abs(int_r) ) REPORT "rem > divisor: r= " & integer'image(int_r) & " y= " & integer'image(int_y)
      SEVERITY ERROR;    
   END LOOP;
   REPORT "simulation OK";
   end_sim <= true;
   WAIT;
   END PROCESS;

END test;