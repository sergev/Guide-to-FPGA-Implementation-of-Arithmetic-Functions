----------------------------------------------------------------------------
-- test_cordic2.vhd
--
-- section 10.6 Trigonometric function (Cordic)
--
-- Test bench for sequential trigonometric function
-- Generates NUM_SIM Random cases
--
----------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;
use IEEE.MATH_REAL.ALL; -- for UNIFORM, TRUNC

ENTITY test_cordic2 IS 
END test_cordic2;

ARCHITECTURE test OF test_cordic2 IS
   CONSTANT p: NATURAL:= 8;
   CONSTANT n: NATURAL:= 16;
   CONSTANT m: NATURAL:= 16;
   CONSTANT logn: NATURAL:= 4;
   CONSTANT NUM_SIM: NATURAL := 1000;
   CONSTANT max_error: REAL:= 0.02; -- sin^2+cos^2 - 1
   CONSTANT max_error_sin: REAL:= 0.005;
   CONSTANT max_error_cos: REAL:= 0.005;

   COMPONENT cordic2 IS
     GENERIC(p: NATURAL:=8; m: NATURAL:=16; n: NATURAL:=16; logn: NATURAL:=4);
   PORT(
     z: IN STD_LOGIC_VECTOR(p DOWNTO 0);
     clk, reset, start:IN STD_LOGIC;
     sin, cos: OUT STD_LOGIC_VECTOR(p DOWNTO 0);
     done: OUT STD_LOGIC
   );
   END COMPONENT;

   SIGNAL z: STD_LOGIC_VECTOR(p DOWNTO 0);
   SIGNAL sine, cosine: STD_LOGIC_VECTOR(p DOWNTO 0);
   SIGNAL clk, reset, start, done: STD_LOGIC;

   SIGNAL end_sim : boolean := false;
   CONSTANT OFFSET : time := 10 ns;
   CONSTANT PERIOD : time := 50 ns; 
  
BEGIN

   dut: cordic2 GENERIC MAP(p => p, n => n, m => m, logn => logn)
   PORT MAP(z => z, clk => clk, reset => reset, start=> start,
            sin => sine, cos => cosine, done => done);
           
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
      VARIABLE rand, real_sin, real_cos, real_z, s2c2, calc_sin, dif_sin, calc_cos, dif_cos: REAL;
      VARIABLE int_z, int_sin, int_cos : NATURAL;
   BEGIN
   end_sim <= false;
   reset <= '1';
   start <= '0';
   WAIT FOR PERIOD;
   reset <= '0';
   WAIT FOR PERIOD;
   FOR i IN 0 TO NUM_SIM LOOP
      UNIFORM(seed1, seed2, rand);
      int_z := INTEGER(TRUNC((rand-0.5)*real(2**(p+1))));
      z <= CONV_STD_LOGIC_VECTOR(int_z,p+1);
      start <= '1';
      WAIT FOR PERIOD;
      start <= '0';
      WAIT UNTIL done = '1';
      WAIT FOR 2*PERIOD;
      int_sin := CONV_INTEGER(sine);
      int_cos := CONV_INTEGER(cosine);
      
      real_z := REAL(int_z) / REAL(2**(p));
      real_sin := REAL(int_sin) / REAL(2**(p));
      real_cos := REAL(int_cos) / REAL(2**(p));
      calc_cos := cos(real_z); 
      calc_sin := sin(real_z);
      s2c2 := (real_sin*real_sin + real_cos*real_cos) - 1.0; 
      dif_sin := calc_sin - real_sin;
      dif_cos := calc_cos - real_cos;
      
      ASSERT ( abs(s2c2) < max_error ) REPORT "error in Trig functtion: Z:" & integer'image(int_z) & "  sin: " & integer'image(int_sin) 
                       & "  cos: " & integer'image(int_cos)
      SEVERITY ERROR;
      ASSERT ( abs(s2c2) < max_error ) REPORT "error in Trig functtion: Z:" & REAL'image(real_z) & "  sin: " & REAL'image(real_sin) 
                       & "  cos: " & REAL'image(real_cos) & " sin^2+cos^2-1 = " & REAL'image(s2c2) 
      SEVERITY ERROR;  
      ASSERT ( abs(dif_sin) < max_error_sin ) REPORT "error in Sin Z:" & REAL'image(real_z) & "  sin: " & REAL'image(real_sin) 
                       & "  true sin : " & REAL'image(calc_sin) & " dif= " & REAL'image(dif_sin)
      SEVERITY ERROR;  
      ASSERT ( abs(dif_cos) < max_error_cos ) REPORT "error in Cos Z:" & REAL'image(real_z) & "  cos: " & REAL'image(real_cos) 
                       & "  true cos : " & REAL'image(calc_cos) & " dif= " & REAL'image(dif_cos)  
      SEVERITY ERROR;    
      END LOOP;
   REPORT "simulation OK";
   end_sim <= true;
   WAIT;
   END PROCESS;

END test;