----------------------------------------------------------------------------
-- test_multioperand_adder_comb.vhd
--
-- section 7.6
--
-- Test bench for combinational multioperand addition
-- Generates NUM_SIM Random cases
--
----------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.MATH_REAL.ALL; -- for UNIFORM, TRUNC
use IEEE.NUMERIC_STD.ALL; -- for TO_UNSIGNED

ENTITY test_twenty_four_operand_adder IS 
END test_twenty_four_operand_adder;

ARCHITECTURE test OF test_twenty_four_operand_adder IS
   CONSTANT n: NATURAL:= 8;
   CONSTANT m: NATURAL:= 24; --fix to 24 in this case
   CONSTANT NUM_SIM: NATURAL := 100;

   COMPONENT twenty_four_operand_adder IS
      GENERIC(n: NATURAL:= n);
   PORT(
   x: IN STD_LOGIC_VECTOR(m*n-1 DOWNTO 0);
   z: OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0) );
   END COMPONENT;
      
   SIGNAL x: STD_LOGIC_VECTOR(n*m-1 DOWNTO 0) := (others => '0');
   SIGNAL z, zz: STD_LOGIC_VECTOR(n-1 DOWNTO 0);

   CONSTANT DELAY : time := 50 ns; 
  
BEGIN

   dut: twenty_four_operand_adder GENERIC MAP(n => n)
   PORT MAP(x => x, z => z);
            
   behav_sum: PROCESS(x)
   VARIABLE acc: STD_LOGIC_VECTOR(n-1 DOWNTO 0);
   BEGIN
   acc := x(n-1 downto 0);
   FOR i IN 1 TO m-1 LOOP
     acc := acc + x((i+1)*n-1 DOWNTO i*n);
   END LOOP;
   zz <= acc;
   END PROCESS;  

   stimuli: PROCESS
      VARIABLE seed1, seed2: NATURAL := 3;
      VARIABLE rand: REAL;
      VARIABLE int_rand: NATURAL;
   BEGIN

   FOR i IN 0 TO NUM_SIM LOOP
      FOR j IN 0 TO m-1 LOOP
         UNIFORM(seed1, seed2, rand);
         int_rand := INTEGER(TRUNC(rand*real(2**n)));
         x((j+1)*n-1 DOWNTO j*n) <= CONV_STD_LOGIC_VECTOR(int_rand,n);
         --REPORT "i: " & integer'image(i) & " rand: " & real'image(rand);
      END LOOP;
       
      WAIT FOR DELAY;
      ASSERT ( z = zz ) REPORT "error in multioperand addition: " & integer'image(i) SEVERITY ERROR;
   END LOOP;
   REPORT "simulation OK";
   WAIT;
   END PROCESS;

END test;