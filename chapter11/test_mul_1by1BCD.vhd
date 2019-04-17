--------------------------------------------------------------------------------
-- Testbench mult 1 by 1 BCD
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
use IEEE.std_logic_arith.all;
 
ENTITY test_mul_1by1 IS
END test_mul_1by1;
 
ARCHITECTURE behavior OF test_mul_1by1 IS 
 
    COMPONENT bcd_mul_arith1
--    COMPONENT bcd_mul_arith2
--    COMPONENT bcd_mul_mem1
--    COMPONENT bcd_mul_mem2
    PORT(
         a : IN  std_logic_vector(3 downto 0);
         b : IN  std_logic_vector(3 downto 0);
         c : OUT  std_logic_vector(3 downto 0);
         d : OUT  std_logic_vector(3 downto 0)
        );
    END COMPONENT;

   --Inputs
   signal a : std_logic_vector(3 downto 0) := (others => '0');
   signal b : std_logic_vector(3 downto 0) := (others => '0');

  --Outputs
   signal c : std_logic_vector(3 downto 0);
   signal d : std_logic_vector(3 downto 0);


BEGIN
 
  -- Instantiate the Unit Under Test (UUT)
   uut: bcd_mul_arith1 PORT MAP (
--   uut: bcd_mul_arith2 PORT MAP (
--   uut: bcd_mul_mem1 PORT MAP (
--   uut: bcd_mul_mem2 PORT MAP (
          a => a, b => b, c => c, d => d     );

  process
  variable m1, m2: integer;
  begin
  a <= "0000"; b <= "0000"; 
  wait for 100 ns;
  for i in 0 to 9 loop
    for j in 0 to 9 loop
      a <= conv_std_logic_vector(i,4); 
      b <= conv_std_logic_vector(j,4);
      wait for 100 ns;
      m1 := i*j;
      m2 := conv_integer(d)*10 + conv_integer(c);
      ASSERT (m1 = m2) REPORT "error mult: " & integer'image(i) & " * " & integer'image(j) & " = " & integer'image(m1) & " /= " & integer'image(m2) SEVERITY ERROR;
    end loop;
  end loop;
  ASSERT (FALSE) REPORT "NOT ERROR: end of simulation" SEVERITY FAILURE;

end process;

END;
