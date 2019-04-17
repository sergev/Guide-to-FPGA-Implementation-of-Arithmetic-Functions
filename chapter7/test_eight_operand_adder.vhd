----------------------------------------------------------------------------
-- test_multioperand_adder_seq.vhd
--
-- section 7.6
--
-- exhaustive test bench for combinational 8-operand addition
--
----------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY test_eight_operand_adder IS 
END test_eight_operand_adder;

ARCHITECTURE test OF test_eight_operand_adder IS
   CONSTANT n: natural:= 3;

   COMPONENT eight_operand_adder IS
    GENERIC(n: NATURAL:= n);
   PORT(
    x0, x1, x2, x3, x4, x5, x6, x7: IN STD_LOGIC_VECTOR(n-1 DOWNTO 0);
    z: OUT STD_LOGIC_VECTOR(n-1 DOWNTO 0)
   );
   END COMPONENT;
   
   SIGNAL x: STD_LOGIC_VECTOR(n*8-1 DOWNTO 0);
   SIGNAL x0, x1, x2, x3, x4, x5, x6, x7: STD_LOGIC_VECTOR(n-1 DOWNTO 0);   
   SIGNAL z, zz: STD_LOGIC_VECTOR(n-1 DOWNTO 0);

   CONSTANT DELAY : time := 50 ns; 

BEGIN

   dut: eight_operand_adder GENERIC MAP(n => n)
   PORT MAP(x0 => x(n-1 downto 0), x1 => x(2*n-1 downto n), 
            x2 => x(3*n-1 downto 2*n), x3 => x(4*n-1 downto 3*n),
            x4 => x(5*n-1 downto 4*n), x5 => x(6*n-1 downto 5*n), 
            x6 => x(7*n-1 downto 6*n), x7 => x(8*n-1 downto 7*n), z => z);
  
   behav_sum: PROCESS(x)
   VARIABLE acc: STD_LOGIC_VECTOR(n-1 DOWNTO 0);
   BEGIN
   acc := x(n-1 downto 0);
   FOR i IN 1 TO 7 LOOP
     acc := acc + x((i+1)*n-1 downto i*n);
   END LOOP;
   zz <= acc;
   END PROCESS;  

   stimuli: PROCESS
   BEGIN
   FOR i IN 0 TO 2**(8*n)-1 LOOP
      x <= conv_std_logic_vector(i,8*n);  
      WAIT FOR DELAY;
      ASSERT ( z = zz ) REPORT "error in multioperand addition: " & integer'image(i) SEVERITY ERROR;
   END LOOP;
   REPORT "simulation OK";
   WAIT;
   END PROCESS;

END test;