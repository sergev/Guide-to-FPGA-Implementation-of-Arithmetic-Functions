----------------------------------------------------------------------------
-- test_integer_csa_multiplier.vhd
--
-- section 8.4 Integer multipiers.
--
-- Test bench for combinational multiplication
-- Generates NUM_SIM Random cases
--
----------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL; --For signed operatations
use IEEE.MATH_REAL.ALL; -- for UNIFORM, TRUNC

ENTITY test_integer_csa_multiplier IS 
END test_integer_csa_multiplier;

ARCHITECTURE test OF test_integer_csa_multiplier IS
   CONSTANT n: NATURAL:= 4;
   CONSTANT m: NATURAL:= 6;
   CONSTANT NUM_SIM: NATURAL := 100;

   COMPONENT integer_csa_multiplier IS
     GENERIC(n: NATURAL:= 8; m: NATURAL:= 8);
   PORT(
     x, u: IN STD_LOGIC_VECTOR(n DOWNTO 0);
     y, v: IN STD_LOGIC_VECTOR(m DOWNTO 0);
     z: OUT STD_LOGIC_VECTOR(n+m+1 DOWNTO 0)
   );
   END COMPONENT;

   SIGNAL x, u: STD_LOGIC_VECTOR(n DOWNTO 0);
   SIGNAL y, v: STD_LOGIC_VECTOR(m DOWNTO 0);
   SIGNAL z, zz: STD_LOGIC_VECTOR(n+m+1 DOWNTO 0);

   CONSTANT DELAY : time := 50 ns; 
  
BEGIN

   dut: integer_csa_multiplier GENERIC MAP(n => n, m => m)
   PORT MAP(x => x, y => y, u => u, v => v, z => z);
           
   zz <= x*y + u + v;           

   stimuli: PROCESS
      VARIABLE seed1: NATURAL := 844396720;
      VARIABLE seed2: NATURAL := 821616997;  
      VARIABLE rand: REAL;
      VARIABLE int_rand1,int_rand2,int_rand3,int_rand4 : NATURAL;
   BEGIN

   FOR i IN 0 TO NUM_SIM LOOP
      UNIFORM(seed1, seed2, rand);
      int_rand1 := INTEGER(TRUNC(rand*real(2**(n+1))));
      x <= CONV_STD_LOGIC_VECTOR(int_rand1,n+1);
      UNIFORM(seed1, seed2, rand);
      int_rand2 := INTEGER(TRUNC(rand*real(2**(m+1))));
      y <= CONV_STD_LOGIC_VECTOR(int_rand2,m+1);
      UNIFORM(seed1, seed2, rand);
      int_rand3 := INTEGER(TRUNC(rand*real(2**(n+1))));
      u <= CONV_STD_LOGIC_VECTOR(int_rand3,n+1);
      UNIFORM(seed1, seed2, rand);
      int_rand4 := INTEGER(TRUNC(rand*real(2**(m+1))));
      v <= CONV_STD_LOGIC_VECTOR(int_rand4,m+1);
      WAIT FOR DELAY;
      ASSERT ( z = zz ) REPORT "error in multiplication: " & integer'image(int_rand1) & " * " & integer'image(int_rand2) &
                                 " + " & integer'image(int_rand3) & " + " & integer'image(int_rand4)
      SEVERITY ERROR;
   END LOOP;
   REPORT "simulation OK";
   WAIT;
   END PROCESS;

END test;