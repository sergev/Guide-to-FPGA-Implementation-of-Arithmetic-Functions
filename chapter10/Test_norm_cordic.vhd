----------------------------------------------------------------------------
-- norm_cordic.vhd
--
-- section 10.6 Trigonometric function (norm_Cordic)
--
-- Test bench for sequential trigonometric function
-- Generates NUM_SIM Random cases
--
----------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.MATH_REAL.ALL; -- for UNIFORM, TRUNC

ENTITY test_norm_cordic IS 
END test_norm_cordic;

ARCHITECTURE test OF test_norm_cordic IS
   CONSTANT p: NATURAL:= 8;
   CONSTANT n: NATURAL:= 16;
   CONSTANT m: NATURAL:= 8;
   CONSTANT NUM_SIM: NATURAL := 1000;
   CONSTANT max_error: NATURAL:= 8; --in units

   COMPONENT norm_cordic IS
     GENERIC(p, m, n: NATURAL);
   PORT(
     x, y: IN STD_LOGIC_VECTOR(p-1 DOWNTO 0);
     clk, reset, start:IN STD_LOGIC;
     z: OUT STD_LOGIC_VECTOR(p DOWNTO 0);
     done: OUT STD_LOGIC
   );
   END COMPONENT;

   SIGNAL x, y: STD_LOGIC_VECTOR(p-1 DOWNTO 0);
   SIGNAL x2y2: STD_LOGIC_VECTOR(2*p DOWNTO 0);
   SIGNAL z2, z2_m_e, z2_p_e: STD_LOGIC_VECTOR(2*p+1 DOWNTO 0);
   SIGNAL z: STD_LOGIC_VECTOR(p DOWNTO 0);
   SIGNAL clk, reset, start, done: STD_LOGIC;

   SIGNAL end_sim : boolean := false;
   CONSTANT OFFSET : time := 10 ns;
   CONSTANT PERIOD : time := 50 ns; 
  
BEGIN

   dut: norm_cordic GENERIC MAP(p => p, n => n, m => m)
   PORT MAP(x => x, y => y, clk => clk, reset => reset, start=> start,
            z => z, done => done);
   
   x2y2 <= ('0' & x*x) + y*y;
   z2 <= z*z;
   z2_m_e <= (z-max_error)*(z-max_error) when (z > max_error) else (others => '0');
   z2_p_e <= (z+max_error)*(z+max_error);
           
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
      VARIABLE rand, real_dist: REAL;
      VARIABLE int_x, int_y, int_z: NATURAL;
   BEGIN
   end_sim <= false;
   reset <= '1';
   start <= '0';
   WAIT FOR PERIOD;
   reset <= '0';
   WAIT FOR PERIOD;
   FOR i IN 0 TO NUM_SIM LOOP
      UNIFORM(seed1, seed2, rand);
      int_x := INTEGER(TRUNC((rand)*real(2**(p))));
      x <= CONV_STD_LOGIC_VECTOR(int_x,p);
      UNIFORM(seed1, seed2, rand);
      int_y := INTEGER(TRUNC((rand)*real(2**(p))));
      y <= CONV_STD_LOGIC_VECTOR(int_y,p);
      start <= '1';
      WAIT FOR PERIOD;
      start <= '0';
      WAIT UNTIL done = '1';
      WAIT FOR 2*PERIOD;
      int_z := CONV_INTEGER(z) ;
      real_dist := sqrt(real(CONV_INTEGER(x2y2)));
      ASSERT ( (z2_m_e <= x2y2) and (z2_p_e >= x2y2) ) 
      REPORT "error in Trig function (x^2+y^2)^0.5:  Z= " & integer'image(int_z) & "  x= " & integer'image(int_x) 
             & "  y= " & integer'image(int_y) & "  true Z= " & real'image(real_dist)
      SEVERITY ERROR;

      END LOOP;
   REPORT "simulation OK";
   end_sim <= true;
   WAIT;
   END PROCESS;

END test;