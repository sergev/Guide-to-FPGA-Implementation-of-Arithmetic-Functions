----------------------------------------------------------------------------
-- test_multioperand_adder_comb.vhd
--
-- section 7.6
--
-- exhaustive test bench for combinational multioperand addition
--
----------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY test_multioperand_adder_comb IS 
END test_multioperand_adder_comb;

ARCHITECTURE test OF test_multioperand_adder_comb IS
   CONSTANT m: natural:= 3;
   CONSTANT n: natural:= 4;

   --COMPONENT comb_multioperand_adder IS
   COMPONENT comb_csa_multioperand_adder IS
      GENERIC(n: NATURAL:= 64; m: NATURAL:= 16);
   PORT(
   x: IN STD_LOGIC_VECTOR(n*m-1 DOWNTO 0);
   z: OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0) );
   END COMPONENT;
   
   SIGNAL x: STD_LOGIC_VECTOR(n*m-1 DOWNTO 0);
   SIGNAL z, zz: STD_LOGIC_VECTOR(n-1 DOWNTO 0);

   CONSTANT DELAY : time := 50 ns; 
  
BEGIN

   dut: comb_csa_multioperand_adder GENERIC MAP(n => n, m => m)
   --dut: comb_multioperand_adder GENERIC MAP(n => n, m => m)
   PORT MAP(x => x, z => z);
            
   behav_sum: PROCESS(x)
   VARIABLE acc: STD_LOGIC_VECTOR(n-1 DOWNTO 0);
   BEGIN
   acc := x(n-1 downto 0);
   FOR i IN 1 TO m-1 LOOP
     acc := acc + x((i+1)*n-1 downto i*n);
   END LOOP;
   zz <= acc;
   END PROCESS;  

   stimuli: PROCESS
   BEGIN
   FOR i IN 0 TO 2**(m*n)-1 LOOP
      x <= conv_std_logic_vector(i,m*n); 
      WAIT FOR DELAY;
      ASSERT ( z = zz ) REPORT "error in multioperand addition: " & integer'image(i) SEVERITY ERROR;
   END LOOP;
   REPORT "simulation OK";
   WAIT;
   END PROCESS;

END test;